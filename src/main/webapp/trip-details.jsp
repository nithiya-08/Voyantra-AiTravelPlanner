<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%@ page import="com.voyantra.ai.WeatherService" %>
<%@ page import="com.voyantra.ai.MediaService" %>
<%@ page import="com.voyantra.ai.RouteOptimizer" %>
<%@ page import="com.voyantra.util.BudgetBreakdown" %>
<%@ page import="com.voyantra.ai.CurrencyService" %>
<%@ page import="com.voyantra.ai.EmergencyInfoService" %>
<%@ page import="com.voyantra.util.ChecklistTemplates" %>
<%@ page import="com.voyantra.ai.GoogleMapsService" %>
<%@ page import="com.voyantra.ai.NearbyRecommendationService" %>
<%@ page import="com.voyantra.ai.GooglePlacesService" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
    Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);

    String tripIdStr = request.getParameter("tripId");
    if (tripIdStr == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    int tripId = Integer.parseInt(tripIdStr);

    String destination = null;
    double budget = 0;
    int numDays = 0;
    String travelStyle = null;
    String interests = null;
    java.sql.Date startDate = null;
    String countryCode = null;
    String foodPreference = null;
    boolean found = false;
    boolean isOwner = false;

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT destination, budget, num_days, travel_style, interests, user_id, "
                       + "start_date, country_code, food_preference "
                       + "FROM trips WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                       + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, tripId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                destination = rs.getString("destination");
                budget = rs.getDouble("budget");
                numDays = rs.getInt("num_days");
                travelStyle = rs.getString("travel_style");
                interests = rs.getString("interests");
                isOwner = rs.getInt("user_id") == userId;
                startDate = rs.getDate("start_date");
                countryCode = rs.getString("country_code");
                foodPreference = rs.getString("food_preference");
                found = true;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (!found) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    WeatherService.WeatherInfo weather = WeatherService.getCurrentWeather(destination);
    List<WeatherService.WeatherInfo> forecast = WeatherService.getForecast(destination, numDays);
    String[] destImages = MediaService.getDestinationImages(destination);
    String destVideoId = MediaService.getDestinationVideoId(destination);
    BudgetBreakdown breakdown = BudgetBreakdown.forTrip(budget, travelStyle);

    boolean isInternational = countryCode != null && !countryCode.equalsIgnoreCase("IN");

    Long daysUntilTrip = null;
    if (startDate != null) {
        long diffMs = startDate.getTime() - new java.util.Date().getTime();
        daysUntilTrip = diffMs / (1000L * 60 * 60 * 24);
    }

    String localCurrency = CurrencyService.currencyForCountry(countryCode);
    Double convertedBudget = localCurrency != null ? CurrencyService.convertFromInr(budget, localCurrency) : null;

    // ---- Real tourist photos of this destination (shared across all trips to it) ----
    ArrayList<Object[]> touristPhotos = new ArrayList<>();
    try (Connection photosConn = DBConnection.getConnection()) {
        if (photosConn != null) {
            String photosSql = "SELECT dp.photo_id, dp.photo_url, dp.caption, dp.created_at, dp.user_id, u.name "
                + "FROM destination_photos dp JOIN users u ON dp.user_id = u.user_id "
                + "WHERE dp.destination = ? ORDER BY dp.photo_id DESC LIMIT 12";
            PreparedStatement photosStmt = photosConn.prepareStatement(photosSql);
            photosStmt.setString(1, destination);
            ResultSet photosRs = photosStmt.executeQuery();
            while (photosRs.next()) {
                touristPhotos.add(new Object[] {
                    photosRs.getInt("photo_id"),
                    photosRs.getString("photo_url"),
                    photosRs.getString("caption"),
                    photosRs.getTimestamp("created_at"),
                    photosRs.getInt("user_id"),
                    photosRs.getString("name")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    EmergencyInfoService.EmergencyInfo emergencyInfo = EmergencyInfoService.getEmergencyInfo(destination);

    // ---- Nearby vendor marketplace recommendations for this destination ----
    // Weather-aware: on bad weather, favor indoor categories (stay/food) over outdoor ones.
    boolean badWeather = weather != null && weather.description != null && (
        weather.description.toLowerCase().contains("rain") ||
        weather.description.toLowerCase().contains("storm") ||
        weather.description.toLowerCase().contains("snow") ||
        weather.description.toLowerCase().contains("thunder"));
    String categoryPriority = badWeather
        ? "'HOTEL', 'HOMESTAY', 'RESTAURANT', 'ACTIVITY', 'GUIDE', 'TRANSPORT'"
        : "'HOTEL', 'HOMESTAY', 'ACTIVITY', 'RESTAURANT', 'GUIDE', 'TRANSPORT'";

    ArrayList<Object[]> nearbyVendors = new ArrayList<>();
    try (Connection nearbyConn = DBConnection.getConnection()) {
        if (nearbyConn != null) {
            String nearbySql = "SELECT vendor_id, business_name, category, city, price_range, photo_url, is_verified, website_url, "
                + "(SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS avg_rating "
                + "FROM vendors v WHERE status = 'APPROVED' AND (city LIKE ? OR ? LIKE CONCAT('%', city, '%')) "
                + "ORDER BY FIELD(category, " + categoryPriority + "), "
                + "avg_rating DESC LIMIT 6";
            PreparedStatement nearbyStmt = nearbyConn.prepareStatement(nearbySql);
            nearbyStmt.setString(1, "%" + destination + "%");
            nearbyStmt.setString(2, destination);
            ResultSet nearbyRs = nearbyStmt.executeQuery();
            while (nearbyRs.next()) {
                nearbyVendors.add(new Object[] {
                    nearbyRs.getInt("vendor_id"),
                    nearbyRs.getString("business_name"),
                    nearbyRs.getString("category"),
                    nearbyRs.getString("city"),
                    nearbyRs.getString("price_range"),
                    nearbyRs.getString("photo_url"),
                    nearbyRs.getBoolean("is_verified"),
                    nearbyRs.getObject("avg_rating"),
                    nearbyRs.getString("website_url")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    // No Voyantra vendor for this destination yet — try real Google-sourced hotels
    // before falling back to a generic AI text blurb.
    java.util.List<GooglePlacesService.Place> googleHotels = nearbyVendors.isEmpty()
        ? GooglePlacesService.searchPlaces("hotels in " + destination)
        : java.util.Collections.emptyList();
    String aiNearbyBlurb = (nearbyVendors.isEmpty() && googleHotels.isEmpty())
        ? NearbyRecommendationService.getAiSuggestions(destination) : null;

    // ---- Checklist: auto-seed default items the first time this trip's page is viewed ----
    try (Connection checklistConn = DBConnection.getConnection()) {
        if (checklistConn != null) {
            PreparedStatement countStmt = checklistConn.prepareStatement(
                "SELECT COUNT(*) c FROM trip_checklist_items WHERE trip_id = ?");
            countStmt.setInt(1, tripId);
            ResultSet countRs = countStmt.executeQuery();
            if (countRs.next() && countRs.getInt("c") == 0) {
                PreparedStatement insertStmt = checklistConn.prepareStatement(
                    "INSERT INTO trip_checklist_items (trip_id, item_text) VALUES (?, ?)");
                for (String item : ChecklistTemplates.defaultItems(isInternational)) {
                    insertStmt.setInt(1, tripId);
                    insertStmt.setString(2, item);
                    insertStmt.executeUpdate();
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    ArrayList<Object[]> checklistItems = new ArrayList<>();
    try (Connection checklistConn2 = DBConnection.getConnection()) {
        if (checklistConn2 != null) {
            PreparedStatement stmt = checklistConn2.prepareStatement(
                "SELECT item_id, item_text, is_checked FROM trip_checklist_items WHERE trip_id = ? ORDER BY item_id ASC");
            stmt.setInt(1, tripId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                checklistItems.add(new Object[]{ rs.getInt("item_id"), rs.getString("item_text"), rs.getBoolean("is_checked") });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ---- Journal & rating ----
    Integer journalRating = null;
    String journalNotes = null;
    try (Connection journalConn = DBConnection.getConnection()) {
        if (journalConn != null) {
            PreparedStatement stmt = journalConn.prepareStatement(
                "SELECT rating, notes FROM trip_journal WHERE trip_id = ?");
            stmt.setInt(1, tripId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int r = rs.getInt("rating");
                journalRating = rs.wasNull() ? null : r;
                journalNotes = rs.getString("notes");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ---- Fetch this trip's stops in their optimized order ----
    ArrayList<Object[]> stops = new ArrayList<>();
    try (Connection stopsConn = DBConnection.getConnection()) {
        if (stopsConn != null) {
            String stopsSql = "SELECT stop_name, latitude, longitude, visit_order "
                             + "FROM trip_stops WHERE trip_id = ? ORDER BY visit_order ASC";
            PreparedStatement stopsStmt = stopsConn.prepareStatement(stopsSql);
            stopsStmt.setInt(1, tripId);
            ResultSet stopsRs = stopsStmt.executeQuery();
            while (stopsRs.next()) {
                stops.add(new Object[] {
                    stopsRs.getString("stop_name"),
                    stopsRs.getDouble("latitude"),
                    stopsRs.getDouble("longitude")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ---- Recommended restaurants: veg/non-veg aware, ranked by rating, with real
    //      distance (from the trip's first stop) and each vendor's signature dish. ----
    ArrayList<Object[]> recommendedRestaurants = new ArrayList<>();
    Double tripLat = null, tripLon = null;
    if (!stops.isEmpty()) {
        double firstLat = (double) stops.get(0)[1];
        double firstLon = (double) stops.get(0)[2];
        if (firstLat != 0 || firstLon != 0) {
            tripLat = firstLat;
            tripLon = firstLon;
        }
    }
    try (Connection restConn = DBConnection.getConnection()) {
        if (restConn != null) {
            StringBuilder restSql = new StringBuilder(
                "SELECT vendor_id, business_name, diet_type, signature_dish, price_range, latitude, longitude, website_url, "
                + "(SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS avg_rating, "
                + "(SELECT COUNT(*) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS review_count "
                + "FROM vendors v WHERE status = 'APPROVED' AND category = 'RESTAURANT' "
                + "AND (city LIKE ? OR ? LIKE CONCAT('%', city, '%'))");
            if ("VEG".equals(foodPreference)) {
                restSql.append(" AND diet_type IN ('VEG', 'BOTH')");
            }
            restSql.append(" ORDER BY avg_rating DESC LIMIT 3");
            PreparedStatement restStmt = restConn.prepareStatement(restSql.toString());
            restStmt.setString(1, "%" + destination + "%");
            restStmt.setString(2, destination);
            ResultSet restRs = restStmt.executeQuery();
            while (restRs.next()) {
                Object vLatObj = restRs.getObject("latitude");
                Object vLonObj = restRs.getObject("longitude");
                Double distanceKm = null;
                if (tripLat != null && vLatObj != null && vLonObj != null) {
                    distanceKm = RouteOptimizer.haversineDistance(tripLat, tripLon, restRs.getDouble("latitude"), restRs.getDouble("longitude"));
                }
                recommendedRestaurants.add(new Object[] {
                    restRs.getInt("vendor_id"),
                    restRs.getString("business_name"),
                    restRs.getString("diet_type"),
                    restRs.getString("signature_dish"),
                    restRs.getString("price_range"),
                    restRs.getObject("avg_rating"),
                    restRs.getInt("review_count"),
                    distanceKm,
                    restRs.getString("website_url")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // No approved Voyantra restaurant for this destination yet — try real
    // Google-sourced restaurants (veg-aware query) before showing nothing.
    java.util.List<GooglePlacesService.Place> googleRestaurants = java.util.Collections.emptyList();
    if (recommendedRestaurants.isEmpty()) {
        String placesQuery = "VEG".equals(foodPreference)
            ? "vegetarian restaurants in " + destination
            : "restaurants in " + destination;
        googleRestaurants = GooglePlacesService.searchPlaces(placesQuery);
    }

    // ---- Build map marker data (skip stops that couldn't be geocoded, i.e. 0,0) ----
    StringBuilder mapStopsJsonBuilder = new StringBuilder("[");
    boolean firstMapStop = true;
    for (Object[] stop : stops) {
        String sName = (String) stop[0];
        double sLat = (double) stop[1];
        double sLon = (double) stop[2];
        if (sLat == 0 && sLon == 0) continue;
        if (!firstMapStop) mapStopsJsonBuilder.append(",");
        firstMapStop = false;
        mapStopsJsonBuilder.append("{\"name\":\"")
            .append(sName.replace("\\", "\\\\").replace("\"", "\\\""))
            .append("\",\"lat\":").append(sLat)
            .append(",\"lon\":").append(sLon).append("}");
    }
    mapStopsJsonBuilder.append("]");
    String mapStopsJson = mapStopsJsonBuilder.toString();
    boolean hasMapStops = !firstMapStop;

    // ---- If a Google Maps Embed API key is configured, prefer a real Google Maps
    //      embed over the free Leaflet map (same pattern as the YouTube embed). ----
    String googleMapEmbedUrl = null;
    if (hasMapStops && GoogleMapsService.isConfigured()) {
        try {
            List<double[]> mapPoints = new ArrayList<>();
            for (Object[] stop : stops) {
                double sLat = (double) stop[1];
                double sLon = (double) stop[2];
                if (sLat == 0 && sLon == 0) continue;
                mapPoints.add(new double[]{ sLat, sLon });
            }
            googleMapEmbedUrl = GoogleMapsService.directionsEmbedUrl(mapPoints);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ---- Fetch expenses ----
    ArrayList<Object[]> expenses = new ArrayList<>();
    double totalSpent = 0;
    try (Connection expConn = DBConnection.getConnection()) {
        if (expConn != null) {
            String expSql = "SELECT expense_id, category, description, amount FROM expenses "
                           + "WHERE trip_id = ? ORDER BY created_at DESC";
            PreparedStatement expStmt = expConn.prepareStatement(expSql);
            expStmt.setInt(1, tripId);
            ResultSet expRs = expStmt.executeQuery();
            while (expRs.next()) {
                double amt = expRs.getDouble("amount");
                totalSpent += amt;
                expenses.add(new Object[] {
                    expRs.getInt("expense_id"), expRs.getString("category"),
                    expRs.getString("description"), amt
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    double spentPct = budget > 0 ? Math.min(100, (totalSpent / budget) * 100) : 0;

    String collabMsg = request.getParameter("collabMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Trip details - Voyantra</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="">
<style>
  :root {
    --ink: #0D1526; --ink-2: #131F38; --ink-3: #1B2A45;
    --paper: #F6F2E9; --gold: #E7A94C; --gold-soft: rgba(231,169,76,0.14);
    --coral: #E2704F; --teal: #4FC3B0;
    --line: rgba(246,242,233,0.14); --line-strong: rgba(246,242,233,0.28); --muted: rgba(246,242,233,0.6);
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: var(--ink); color: var(--paper); font-family: 'Inter', sans-serif; min-height: 100vh; }
  a { color: inherit; text-decoration: none; }

  header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 6vw; border-bottom: 1px solid var(--line);
  }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand-mark { width: 28px; height: 28px; }
  .brand-word { font-family: 'Fraunces', serif; font-weight: 600; font-size: 1.15rem; }
  .brand-word .accent { color: var(--gold); font-weight: 500; font-style: italic; }
  .back-link { font-size: 0.85rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
  .back-link:hover { color: var(--gold); }

  main { max-width: 800px; margin: 0 auto; padding: 6vh 6vw 10vh; }

  .media-block {
    margin-bottom: 28px; border-radius: 16px; overflow: hidden;
    border: 1px solid var(--line);
  }
  .media-block img { width: 100%; height: 280px; object-fit: cover; display: block; }
  .media-block iframe { width: 100%; height: 280px; border: none; display: block; }

  .trip-hero {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 20px;
    padding: 32px; margin-bottom: 28px; box-shadow: 0 24px 50px rgba(0,0,0,0.35);
  }
  .kicker { font-size: 0.76rem; letter-spacing: 0.14em; text-transform: uppercase; color: var(--coral); font-weight: 700; margin-bottom: 12px; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 2.1rem; margin-bottom: 20px; }

  .stat-row { display: flex; flex-wrap: wrap; gap: 14px; margin-bottom: 20px; }
  .stat-box {
    background: var(--ink-3); border: 1px solid var(--line); border-radius: 12px;
    padding: 14px 18px; flex: 1; min-width: 130px;
  }
  .stat-box .k { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); font-weight: 600; }
  .stat-box .v { font-family: 'Fraunces', serif; font-size: 1.3rem; margin-top: 5px; color: var(--gold); }

  .interests-line { font-size: 0.92rem; color: var(--muted); }
  .interests-line strong { color: var(--paper); }
  .countdown-banner {
    display: inline-block; background: rgba(226,112,79,0.14); color: var(--coral);
    border: 1px solid var(--coral); padding: 8px 14px; border-radius: 999px;
    font-size: 0.84rem; font-weight: 600; margin-bottom: 18px;
  }

  .section-title {
    font-family: 'Fraunces', serif; font-size: 1.4rem; margin-bottom: 18px; margin-top: 8px;
  }
  .action-btn {
    background: var(--ink-2); border: 1px solid var(--line-strong); color: var(--paper);
    padding: 10px 18px; border-radius: 999px; font-size: 0.84rem; font-weight: 600;
    display: inline-flex; align-items: center; gap: 8px; cursor: pointer;
  }
  .action-btn:hover { border-color: var(--gold); color: var(--gold); }
  .action-row { display:flex; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom: 18px; }

  .day-card {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px;
    padding: 24px; margin-bottom: 18px; transition: border-color 0.2s ease;
  }
  .day-card:hover { border-color: rgba(231,169,76,0.35); }
  .day-card-head { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; flex-wrap: wrap; }
  .day-badge {
    font-family: 'Fraunces', serif; font-weight: 600; font-size: 1rem; color: var(--ink);
    background: var(--gold); width: 42px; height: 42px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  }
  .day-card-head h3 { font-family: 'Fraunces', serif; font-size: 1.15rem; font-weight: 500; }
  .day-forecast-badge {
    font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em;
    padding: 4px 10px; border-radius: 999px; margin-left: auto;
  }
  .day-forecast-badge.forecast { background: rgba(79,195,176,0.14); color: var(--teal); }
  .day-forecast-badge.seasonal { background: rgba(246,242,233,0.08); color: var(--muted); }
  .fav-star {
    background: none; border: none; color: var(--line-strong); font-size: 1.3rem; cursor: pointer;
    line-height: 1; padding: 0 2px;
  }
  .fav-star.active { color: var(--gold); }
  .fav-star:hover { color: var(--gold); }
  .day-rows { display: flex; flex-direction: column; gap: 14px; }
  .day-row { display: flex; gap: 12px; align-items: flex-start; }
  .day-row .ic {
    width: 32px; height: 32px; border-radius: 9px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: 0.95rem;
  }
  .day-row.activities .ic { background: var(--gold-soft); color: var(--gold); }
  .day-row.food .ic { background: rgba(226,112,79,0.14); color: var(--coral); }
  .day-row.hotel .ic { background: rgba(79,195,176,0.14); color: var(--teal); }
  .day-row.weather .ic { background: rgba(246,242,233,0.08); color: var(--muted); }
  .day-row-text .lbl { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); font-weight: 600; margin-bottom: 3px; }
  .day-row-text .val { font-size: 0.9rem; color: var(--paper); line-height: 1.55; }

  .empty-itinerary {
    text-align: center; padding: 50px 24px; background: var(--ink-2);
    border: 1px dashed var(--line-strong); border-radius: 16px;
  }
  .empty-itinerary p { color: var(--muted); margin-bottom: 8px; }
  .empty-itinerary .sub { font-size: 0.86rem; }

  .panel {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px;
    padding: 24px; margin-top: 30px;
  }
  #tripMap {
    height: 320px; border-radius: 12px; margin-top: 16px;
    border: 1px solid var(--line); background: var(--ink-3);
  }
  .leaflet-popup-content-wrapper, .leaflet-popup-tip { background: var(--ink-2); color: var(--paper); }
  .map-pin-badge {
    background: var(--gold); color: var(--ink); font-family: 'Fraunces', serif; font-weight: 700;
    width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
    font-size: 0.8rem; border: 2px solid var(--ink); box-shadow: 0 2px 6px rgba(0,0,0,0.4);
  }
  .bar-track { display: flex; height: 14px; border-radius: 999px; overflow: hidden; margin-bottom: 14px; background: var(--ink-3); }
  .bar-seg.stay { background: var(--gold); }
  .bar-seg.food { background: var(--coral); }
  .bar-seg.activities { background: var(--teal); }
  .bar-seg.transport { background: rgba(246,242,233,0.4); }
  .legend { display: flex; flex-wrap: wrap; gap: 16px; font-size: 0.84rem; color: var(--muted); }
  .legend .dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; margin-right: 6px; }
  .legend .dot.stay { background: var(--gold); } .legend .dot.food { background: var(--coral); }
  .legend .dot.activities { background: var(--teal); } .legend .dot.transport { background: rgba(246,242,233,0.4); }

  .progress-track { height: 10px; border-radius: 999px; background: var(--ink-3); overflow: hidden; margin: 10px 0 16px; }
  .progress-fill { height: 100%; background: var(--gold); }
  .progress-fill.over { background: var(--coral); }
  .expense-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--line); font-size: 0.88rem; }
  .expense-row:last-child { border-bottom: none; }
  .expense-row .meta { color: var(--muted); font-size: 0.78rem; }
  .expense-row .del { background: none; border: none; color: var(--muted); cursor: pointer; font-size: 0.8rem; }
  .expense-row .del:hover { color: var(--coral); }
  .mini-form { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 16px; }
  .mini-form input, .mini-form select {
    padding: 10px 12px; border-radius: 8px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.85rem;
  }
  .mini-form input[name="description"] { flex: 1; min-width: 140px; }
  .mini-form button {
    background: var(--gold); color: var(--ink); border: none; border-radius: 8px;
    padding: 10px 16px; font-weight: 700; font-size: 0.85rem; cursor: pointer;
  }

  .collab-msg { background: var(--gold-soft); color: var(--gold); border: 1px solid var(--gold); padding: 10px 14px; border-radius: 10px; margin-bottom: 16px; font-size: 0.86rem; }

  .star-rating { display: flex; gap: 6px; }
  .star-rating label { cursor: pointer; }
  .star-lbl { font-size: 1.6rem; color: var(--line-strong); transition: color 0.15s ease; }
  .star-lbl.on { color: var(--gold); }

  .modal-overlay {
    display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 400;
    align-items: center; justify-content: center;
  }
  .modal-overlay.open { display: flex; }
  .modal-box {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px;
    padding: 26px; width: 90%; max-width: 420px;
  }
  .modal-box h3 { font-family: 'Fraunces', serif; margin-bottom: 14px; }
  .modal-box input {
    width: 100%; padding: 11px 13px; border-radius: 8px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.86rem; margin-bottom: 12px;
  }
  .modal-box .close-modal { background: none; border: none; color: var(--muted); cursor: pointer; float: right; }

  @media (max-width: 600px) {
    .trip-hero { padding: 22px 18px; }
    h1 { font-size: 1.6rem; }
  }
</style>
</head>
<body>

<header>
  <a href="index.jsp" class="brand">
    <svg class="brand-mark" viewBox="0 0 40 40" fill="none">
      <circle cx="20" cy="20" r="18.5" stroke="#E7A94C" stroke-width="1.4" opacity="0.4"/>
      <path d="M20 5 L24.5 17.5 L20 20 L15.5 17.5 Z" fill="#E7A94C"/>
      <path d="M20 35 L15.5 22.5 L20 20 L24.5 22.5 Z" fill="#F6F2E9" opacity="0.85"/>
      <circle cx="20" cy="20" r="3" fill="#0D1526" stroke="#E7A94C" stroke-width="1.4"/>
    </svg>
    <span class="brand-word">Voy<span class="accent">antra</span></span>
  </a>
  <a href="dashboard.jsp" class="back-link">&larr; Back to dashboard</a>
</header>

<main>
  <% if (collabMsg != null && !collabMsg.trim().isEmpty()) { %>
    <div class="collab-msg"><%= collabMsg %></div>
  <% } %>

  <% if (destImages != null && destImages.length > 0) { %>
  <div class="media-block" id="carousel" style="position:relative;">
      <% for (int i = 0; i < destImages.length; i++) { %>
      <img src="<%= destImages[i] %>" alt="<%= destination %>"
           class="carousel-slide<%= i == 0 ? " active" : "" %>"
           style="position:<%= i == 0 ? "relative" : "absolute" %>; top:0; left:0;
                  opacity:<%= i == 0 ? "1" : "0" %>; transition:opacity 0.8s ease;">
      <% } %>
  </div>
  <script>
    (function() {
      const slides = document.querySelectorAll('#carousel .carousel-slide');
      if (slides.length <= 1) return;
      let current = 0;
      setInterval(() => {
        slides[current].style.opacity = '0';
        current = (current + 1) % slides.length;
        slides[current].style.opacity = '1';
      }, 3000);
    })();
  </script>
  <% } %>

  <% if (destVideoId != null) { %>
  <div class="media-block">
      <iframe src="https://www.youtube.com/embed/<%= destVideoId %>" allowfullscreen></iframe>
  </div>
  <% } %>

  <!-- Real tourist photos of this destination — separate from the stock carousel above -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">&#128248; Real tourist photos of <%= destination %></div>
    <p style="font-size:0.82rem; color:var(--muted); margin-top:-10px; margin-bottom:16px;">Shared by travellers who've actually been here — not stock photos.</p>
    <% if (!touristPhotos.isEmpty()) { %>
      <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(150px,1fr)); gap:12px; margin-bottom:20px;">
      <% for (Object[] tp : touristPhotos) {
          int photoId = (int) tp[0];
          String photoUrl = (String) tp[1];
          String caption = (String) tp[2];
          int photoOwnerId = (int) tp[4];
          String uploaderName = (String) tp[5];
      %>
        <div style="position:relative;">
          <img src="<%= photoUrl %>" alt="Photo of <%= destination %>" style="width:100%; height:120px; object-fit:cover; border-radius:10px; display:block;">
          <div style="font-size:0.72rem; color:var(--muted); margin-top:4px;">by <%= uploaderName %></div>
          <% if (caption != null && !caption.trim().isEmpty()) { %>
          <div style="font-size:0.76rem; color:var(--paper); margin-top:2px;"><%= caption %></div>
          <% } %>
          <% if (isAdmin || photoOwnerId == userId) { %>
          <form action="DeleteDestinationPhotoServlet" method="POST" style="margin-top:4px;">
            <input type="hidden" name="photoId" value="<%= photoId %>">
            <input type="hidden" name="tripId" value="<%= tripId %>">
            <button type="submit" style="background:none; border:none; color:var(--muted); font-size:0.72rem; cursor:pointer; padding:0;" onclick="return confirm('Delete this photo?');">Delete</button>
          </form>
          <% } %>
        </div>
      <% } %>
      </div>
    <% } else { %>
      <p class="empty-state" style="margin-bottom:20px;">No tourist photos yet — be the first to add one.</p>
    <% } %>
    <form action="UploadDestinationPhotoServlet" method="POST" enctype="multipart/form-data" class="mini-form">
      <input type="hidden" name="tripId" value="<%= tripId %>">
      <input type="file" name="photo" accept="image/jpeg,image/png,image/webp,image/gif" required>
      <input type="text" name="caption" placeholder="Caption (optional)" style="flex:1; min-width:140px;">
      <button type="submit">Add photo</button>
    </form>
  </div>

  <div class="trip-hero">
    <div class="kicker" data-i18n="td_kicker">Trip details</div>
    <h1><%= destination %>
      <% if (!stops.isEmpty()) {
           double firstLat = (double) stops.get(0)[1];
           double firstLon = (double) stops.get(0)[2];
      %>
      <a href="https://www.google.com/maps/dir/?api=1&destination=<%= firstLat %>,<%= firstLon %>" target="_blank" rel="noopener"
         style="font-size:0.85rem; color:var(--teal); vertical-align:middle; margin-left:10px; text-decoration:none;">&#128663; Directions</a>
      <% } %>
    </h1>

    <% if (daysUntilTrip != null && daysUntilTrip >= 0) { %>
    <div class="countdown-banner">
        <%= daysUntilTrip == 0 ? "Your trip starts today!" : daysUntilTrip + " days until this trip starts" %>
    </div>
    <% } %>

    <div class="stat-row">
      <div class="stat-box"><div class="k" data-i18n="td_budget_label">Budget</div><div class="v">Rs. <%= (int) budget %></div>
        <% if (convertedBudget != null) { %>
        <div style="font-size:0.76rem; color:var(--muted); margin-top:2px;">&asymp; <%= String.format("%.0f", convertedBudget) %> <%= localCurrency %></div>
        <% } %>
      </div>
      <div class="stat-box"><div class="k" data-i18n="td_duration_label">Duration</div><div class="v"><%= numDays %> days</div></div>
      <div class="stat-box"><div class="k" data-i18n="td_style_label">Style</div><div class="v"><%= travelStyle %></div></div>
    </div>

    <div class="interests-line"><strong data-i18n="td_interests_label">Interests:</strong> <%= interests %></div>
        <% if (stops.size() > 1) { %>
    <div style="margin-top:16px; padding-top:16px; border-top:1px solid var(--line);">
        <strong style="font-size:0.9rem; color:var(--paper);" data-i18n="td_route_heading">Optimized route:</strong>
        <div style="margin-top:10px; display:flex; flex-wrap:wrap; align-items:center; gap:8px; font-size:0.88rem; color:var(--muted);">
        <%
            double totalDistance = 0;
            for (int i = 0; i < stops.size(); i++) {
                String stopName = (String) stops.get(i)[0];
                double stopLat = (double) stops.get(i)[1];
                double stopLon = (double) stops.get(i)[2];
        %>
            <span style="background:var(--ink-3); padding:6px 12px; border-radius:999px; color:var(--paper); display:inline-flex; align-items:center; gap:6px;">
                <%= (i + 1) %>. <%= stopName %>
                <a href="https://www.google.com/maps/dir/?api=1&destination=<%= stopLat %>,<%= stopLon %>" target="_blank" rel="noopener" style="color:var(--teal); text-decoration:none;" title="Directions">&#128663;</a>
            </span>
        <%
                if (i < stops.size() - 1) {
                    double lat1 = (double) stops.get(i)[1];
                    double lon1 = (double) stops.get(i)[2];
                    double lat2 = (double) stops.get(i + 1)[1];
                    double lon2 = (double) stops.get(i + 1)[2];
                    double dist = RouteOptimizer.haversineDistance(lat1, lon1, lat2, lon2);
                    totalDistance += dist;
        %>
            <span style="color:var(--gold);">&rarr; <%= Math.round(dist) %> km &rarr;</span>
        <%
                }
            }
        %>
        </div>
        <div style="margin-top:10px; font-size:0.82rem;"><span data-i18n="td_total_distance">Total distance:</span> <%= Math.round(totalDistance) %> km</div>
    </div>
    <% } %>

    <% if (weather != null) { %>
    <div style="margin-top:16px; padding-top:16px; border-top:1px solid var(--line); font-size:0.9rem; color:var(--muted);">
        <strong style="color:var(--paper);"><span data-i18n="td_current_weather">Current weather in</span> <%= destination %>:</strong>
        <%= Math.round(weather.temperature) %>&deg;C, <%= weather.description %>, <%= weather.humidity %>% humidity
    </div>
    <% } %>
  </div>

  <!-- Interactive map of the trip's stops -->
  <% if (hasMapStops) { %>
  <div class="panel">
    <div class="section-title" style="margin-top:0;">&#128506; Map</div>
    <% if (googleMapEmbedUrl != null) { %>
      <iframe style="width:100%; height:320px; border:0; border-radius:12px;"
              loading="lazy" allowfullscreen referrerpolicy="no-referrer-when-downgrade"
              src="<%= googleMapEmbedUrl %>"></iframe>
    <% } else { %>
      <div id="tripMap"></div>
    <% } %>
  </div>
  <% } %>

  <!-- Estimated budget breakdown (feature) -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;" data-i18n="td_budget_breakdown">Estimated budget breakdown</div>
    <div class="bar-track">
      <div class="bar-seg stay" style="width:<%= (breakdown.stay/budget)*100 %>%"></div>
      <div class="bar-seg food" style="width:<%= (breakdown.food/budget)*100 %>%"></div>
      <div class="bar-seg activities" style="width:<%= (breakdown.activities/budget)*100 %>%"></div>
      <div class="bar-seg transport" style="width:<%= (breakdown.transport/budget)*100 %>%"></div>
    </div>
    <div class="legend">
      <span><span class="dot stay"></span><span data-i18n="td_stay">Stay</span>: Rs. <%= Math.round(breakdown.stay) %></span>
      <span><span class="dot food"></span><span data-i18n="td_food">Food</span>: Rs. <%= Math.round(breakdown.food) %></span>
      <span><span class="dot activities"></span><span data-i18n="td_activities">Activities</span>: Rs. <%= Math.round(breakdown.activities) %></span>
      <span><span class="dot transport"></span>Transport: Rs. <%= Math.round(breakdown.transport) %></span>
    </div>
  </div>

  <!-- Local emergency info (AI-generated general guidance, not a verified directory) -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">&#9888; Emergency &amp; safety info</div>
    <% if (emergencyInfo != null) { %>
      <div style="font-size:0.9rem; line-height:1.7;">
        <div><strong style="color:var(--paper);">Emergency number:</strong> <%= emergencyInfo.emergencyNumber %></div>
        <div style="margin-top:6px; color:var(--muted);"><%= emergencyInfo.hospitalNote %></div>
        <div style="margin-top:6px; color:var(--muted);"><%= emergencyInfo.embassyNote %></div>
      </div>
      <div style="margin-top:12px; font-size:0.76rem; color:var(--muted); font-style:italic;">
        AI-generated general guidance — verify locally before you travel.
      </div>
    <% } else { %>
      <p style="color:var(--muted); font-size:0.88rem;">Emergency info isn't available right now.</p>
    <% } %>
  </div>

  <!-- Recommended restaurants: veg/non-veg aware, ranked, with distance and signature dish -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">&#127860; Where to eat</div>
    <% if (foodPreference == null) { %>
      <div style="font-size:0.82rem; color:var(--muted); margin-bottom:14px;">
        No food preference set for this trip — <a href="edit-trip.jsp?tripId=<%= tripId %>" style="color:var(--gold);">tell us veg or non-veg</a> for better matches.
      </div>
    <% } %>
    <% if (!recommendedRestaurants.isEmpty()) { %>
      <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(230px,1fr)); gap:14px;">
      <% for (Object[] rr : recommendedRestaurants) {
          int rrId = (int) rr[0];
          String rrDiet = (String) rr[2];
          String rrDish = (String) rr[3];
          String rrPrice = (String) rr[4];
          Object rrRatingObj = rr[5];
          int rrReviewCount = (int) rr[6];
          Double rrDistance = (Double) rr[7];
          String rrWebsite = (String) rr[8];
      %>
        <div style="background:var(--ink-3); border:1px solid var(--line); border-radius:12px; padding:16px; transition:border-color 0.2s ease;">
          <a href="vendor-details.jsp?vendorId=<%= rrId %>" style="display:block; font-weight:700; font-size:0.94rem; margin-bottom:6px;"><%= rr[1] %></a>
          <% if (rrDish != null && !rrDish.trim().isEmpty()) { %>
          <div style="font-size:0.82rem; color:var(--gold); margin-bottom:6px;">&#127859; Famous for: <%= rrDish %></div>
          <% } %>
          <div style="display:flex; flex-wrap:wrap; gap:6px; margin-bottom:6px;">
            <% if ("VEG".equals(rrDiet)) { %><span class="trip-tag" style="background:rgba(79,195,176,0.14); color:var(--teal);">Vegetarian</span><% } %>
            <% if ("NON_VEG".equals(rrDiet)) { %><span class="trip-tag" style="background:rgba(226,112,79,0.14); color:var(--coral);">Non-vegetarian</span><% } %>
            <% if ("BOTH".equals(rrDiet)) { %><span class="trip-tag">Veg &amp; Non-veg</span><% } %>
            <% if (rrPrice != null && !rrPrice.trim().isEmpty()) { %><span class="trip-tag"><%= rrPrice %></span><% } %>
          </div>
          <div style="font-size:0.8rem; color:var(--muted); margin-bottom:<%= (rrWebsite != null && !rrWebsite.trim().isEmpty()) ? "8" : "0" %>px;">
            <% if (rrRatingObj != null) { %>&#9733; <%= String.format("%.1f", (Double) rrRatingObj) %> (<%= rrReviewCount %>)<% } else { %>No reviews yet<% } %>
            <% if (rrDistance != null) { %> &middot; <%= String.format("%.1f", rrDistance) %> km away<% } %>
          </div>
          <% if (rrWebsite != null && !rrWebsite.trim().isEmpty()) { %>
          <a href="<%= rrWebsite %>" target="_blank" rel="noopener noreferrer" style="font-size:0.78rem; color:var(--teal);">&#128279; Visit their website &#8599;</a>
          <% } %>
        </div>
      <% } %>
      </div>
    <% } else if (!googleRestaurants.isEmpty()) { %>
      <div style="font-size:0.78rem; color:var(--muted); margin-bottom:10px;">No Voyantra-listed restaurants here yet — showing real places from Google:</div>
      <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(230px,1fr)); gap:14px;">
      <% for (GooglePlacesService.Place gp : googleRestaurants) { %>
        <a href="<%= gp.mapsUrl() %>" target="_blank" rel="noopener noreferrer" style="display:block; background:var(--ink-3); border:1px solid var(--line); border-radius:12px; padding:16px;">
          <div style="font-weight:700; font-size:0.94rem; margin-bottom:6px;"><%= gp.name %></div>
          <div style="font-size:0.78rem; color:var(--muted); margin-bottom:6px;"><%= gp.address %></div>
          <div style="font-size:0.8rem; color:var(--muted);">
            <% if (gp.rating >= 0) { %>&#9733; <%= gp.rating %> (Google)<% } else { %>No Google rating<% } %>
          </div>
        </a>
      <% } %>
      </div>
      <div style="margin-top:12px; font-size:0.76rem; color:var(--muted); font-style:italic;">From Google, not a verified Voyantra listing.</div>
    <% } else { %>
      <p style="color:var(--muted); font-size:0.88rem;">No matching restaurants listed on Voyantra for <%= destination %> yet<%= "VEG".equals(foodPreference) ? " with a vegetarian menu" : "" %>. <a href="vendor-form.jsp" style="color:var(--gold);">Know one? List it &rarr;</a></p>
    <% } %>
  </div>

  <!-- Nearby vendor marketplace recommendations -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">&#127968; Recommended near <%= destination %></div>
    <% if (badWeather && !nearbyVendors.isEmpty()) { %>
      <div style="font-size:0.82rem; color:var(--muted); margin-bottom:12px;">&#127783; Weather looks rough right now, so we're showing indoor options first.</div>
    <% } %>
    <% if (!nearbyVendors.isEmpty()) { %>
      <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(220px,1fr)); gap:14px;">
      <% for (Object[] nv : nearbyVendors) {
          int nvId = (int) nv[0];
          boolean nvVerified = (boolean) nv[6];
          Object nvRatingObj = nv[7];
          String nvWebsite = (String) nv[8];
      %>
        <div style="background:var(--ink-3); border:1px solid var(--line); border-radius:12px; padding:14px; transition:border-color 0.2s ease;">
          <a href="vendor-details.jsp?vendorId=<%= nvId %>" style="display:block; font-weight:700; font-size:0.92rem; margin-bottom:6px;"><%= nv[1] %><% if (nvVerified) { %> <span style="color:var(--teal); font-size:0.78rem;">&#10003; Verified</span><% } %></a>
          <div style="font-size:0.78rem; color:var(--muted); margin-bottom:4px;"><%= nv[2] %> &middot; <%= nv[3] %></div>
          <% if (nv[4] != null) { %><div style="font-size:0.78rem; color:var(--gold);"><%= nv[4] %></div><% } %>
          <% if (nvRatingObj != null) { %><div style="font-size:0.78rem; color:var(--muted); margin-top:4px;">&#9733; <%= String.format("%.1f", (Double) nvRatingObj) %></div><% } %>
          <% if (nvWebsite != null && !nvWebsite.trim().isEmpty()) { %>
          <a href="<%= nvWebsite %>" target="_blank" rel="noopener noreferrer" style="display:block; margin-top:6px; font-size:0.76rem; color:var(--teal);">&#128279; Visit their website &#8599;</a>
          <% } %>
        </div>
      <% } %>
      </div>
      <div style="margin-top:14px;"><a href="vendors.jsp" style="color:var(--gold); font-size:0.84rem;">Browse all local vendors &rarr;</a></div>
    <% } else if (!googleHotels.isEmpty()) { %>
      <div style="font-size:0.78rem; color:var(--muted); margin-bottom:10px;">No Voyantra-listed vendors here yet — showing real places from Google:</div>
      <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(220px,1fr)); gap:14px;">
      <% for (GooglePlacesService.Place gp : googleHotels) { %>
        <a href="<%= gp.mapsUrl() %>" target="_blank" rel="noopener noreferrer" style="display:block; background:var(--ink-3); border:1px solid var(--line); border-radius:12px; padding:14px;">
          <div style="font-weight:700; font-size:0.92rem; margin-bottom:6px;"><%= gp.name %></div>
          <div style="font-size:0.78rem; color:var(--muted); margin-bottom:4px;"><%= gp.address %></div>
          <div style="font-size:0.78rem; color:var(--muted);">
            <% if (gp.rating >= 0) { %>&#9733; <%= gp.rating %> (Google)<% } else { %>No Google rating<% } %>
          </div>
        </a>
      <% } %>
      </div>
      <div style="margin-top:12px; font-size:0.76rem; color:var(--muted); font-style:italic;">From Google, not a verified Voyantra listing.</div>
      <div style="margin-top:10px;"><a href="vendor-form.jsp" style="color:var(--gold); font-size:0.84rem;">Know a great local business here? List it on Voyantra &rarr;</a></div>
    <% } else if (aiNearbyBlurb != null) { %>
      <p style="font-size:0.9rem; line-height:1.7; color:var(--paper);"><%= aiNearbyBlurb %></p>
      <div style="margin-top:12px; font-size:0.76rem; color:var(--muted); font-style:italic;">
        AI-generated general guidance, not a verified listing — verify locally before you book.
      </div>
      <div style="margin-top:10px;"><a href="vendor-form.jsp" style="color:var(--gold); font-size:0.84rem;">Know a great local business here? List it on Voyantra &rarr;</a></div>
    <% } else { %>
      <p style="color:var(--muted); font-size:0.88rem;">No recommendations available right now.</p>
    <% } %>
  </div>

  <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; margin-top:34px;">
      <div class="section-title" style="margin-bottom:0;" data-i18n="td_itinerary_heading">Day-wise itinerary</div>
      <div class="action-row" style="margin-bottom:0;">
          <a href="DownloadPdfServlet?tripId=<%= tripId %>" class="action-btn">
              <span data-i18n="td_download">&#11015; Download as PDF</span>
          </a>
          <form action="GenerateItineraryServlet" method="POST" style="margin:0;" onsubmit="return confirm('Regenerate this itinerary? The current plan will be replaced.');">
              <input type="hidden" name="tripId" value="<%= tripId %>">
              <button type="submit" class="action-btn" data-i18n="td_regenerate">&#8635; Regenerate itinerary</button>
          </form>
          <button type="button" class="action-btn" id="shareBtn" data-i18n="td_share">&#128279; Share trip</button>
      </div>
  </div>
  <div style="height:18px;"></div>

  <%
      boolean hasItinerary = false;
      try (Connection conn2 = DBConnection.getConnection()) {
          if (conn2 != null) {
              String sql2 = "SELECT i.day_number, i.activities, i.food_suggestions, i.hotel_suggestion, i.weather_info, i.is_favorite, "
                         + "i.suggested_hotel_vendor_id, hv.business_name AS hotel_vendor_name, "
                         + "i.suggested_food_vendor_id, fv.business_name AS food_vendor_name "
                         + "FROM itineraries i "
                         + "LEFT JOIN vendors hv ON i.suggested_hotel_vendor_id = hv.vendor_id AND hv.status = 'APPROVED' "
                         + "LEFT JOIN vendors fv ON i.suggested_food_vendor_id = fv.vendor_id AND fv.status = 'APPROVED' "
                         + "WHERE i.trip_id = ? ORDER BY i.day_number ASC";
              PreparedStatement stmt2 = conn2.prepareStatement(sql2);
              stmt2.setInt(1, tripId);
              ResultSet rs2 = stmt2.executeQuery();
  %>
      <% boolean any = false; %>
      <div class="itinerary-list">
      <% while (rs2.next()) { any = true; hasItinerary = true;
             int dayNum = rs2.getInt("day_number");
             boolean isFavDay = rs2.getBoolean("is_favorite");
             WeatherService.WeatherInfo dayForecast = (dayNum - 1 < forecast.size()) ? forecast.get(dayNum - 1) : null;
             int hotelVendorIdForDay = rs2.getInt("suggested_hotel_vendor_id");
             String hotelVendorNameForDay = rs2.getString("hotel_vendor_name");
             int foodVendorIdForDay = rs2.getInt("suggested_food_vendor_id");
             String foodVendorNameForDay = rs2.getString("food_vendor_name");
      %>
          <div class="day-card" id="day-<%= dayNum %>">
              <div class="day-card-head">
                  <div class="day-badge"><%= dayNum %></div>
                  <h3>Day <%= dayNum %></h3>
                  <% if (dayForecast != null) { %>
                      <span class="day-forecast-badge forecast" data-i18n="td_forecast_badge">Forecast</span>
                  <% } else { %>
                      <span class="day-forecast-badge seasonal" data-i18n="td_seasonal_badge">Seasonal estimate</span>
                  <% } %>
                  <form action="ToggleFavoriteDayServlet" method="POST" style="margin:0;">
                      <input type="hidden" name="tripId" value="<%= tripId %>">
                      <input type="hidden" name="dayNumber" value="<%= dayNum %>">
                      <button type="submit" class="fav-star<%= isFavDay ? " active" : "" %>" title="Mark as favorite day">
                          <%= isFavDay ? "★" : "☆" %>
                      </button>
                  </form>
              </div>
              <div class="day-rows">
                  <div class="day-row activities">
                      <span class="ic">&#127958;</span>
                      <div class="day-row-text">
                          <div class="lbl" data-i18n="td_activities">Activities</div>
                          <div class="val"><%= rs2.getString("activities") %></div>
                      </div>
                  </div>
                  <div class="day-row food">
                      <span class="ic">&#127860;</span>
                      <div class="day-row-text">
                          <div class="lbl" data-i18n="td_food">Food</div>
                          <div class="val"><%= rs2.getString("food_suggestions") %></div>
                          <% if (foodVendorNameForDay != null) { %>
                          <a href="vendor-details.jsp?vendorId=<%= foodVendorIdForDay %>" style="display:inline-block; margin-top:6px; font-size:0.78rem; color:var(--teal);">&#128205; Real listing on Voyantra: <%= foodVendorNameForDay %> &rarr;</a>
                          <% } %>
                      </div>
                  </div>
                  <div class="day-row hotel">
                      <span class="ic">&#127976;</span>
                      <div class="day-row-text">
                          <div class="lbl" data-i18n="td_stay">Stay</div>
                          <div class="val"><%= rs2.getString("hotel_suggestion") %></div>
                          <% if (hotelVendorNameForDay != null) { %>
                          <a href="vendor-details.jsp?vendorId=<%= hotelVendorIdForDay %>" style="display:inline-block; margin-top:6px; font-size:0.78rem; color:var(--teal);">&#128205; Real listing on Voyantra: <%= hotelVendorNameForDay %> &rarr;</a>
                          <% } %>
                      </div>
                  </div>
                  <div class="day-row weather">
                      <span class="ic">&#9728;</span>
                      <div class="day-row-text">
                          <div class="lbl" data-i18n="td_weather">Weather</div>
                          <div class="val">
                          <% if (dayForecast != null) { %>
                              <%= Math.round(dayForecast.temperature) %>&deg;C, <%= dayForecast.description %>, <%= dayForecast.humidity %>% humidity
                          <% } else { %>
                              <%= rs2.getString("weather_info") %>
                          <% } %>
                          </div>
                      </div>
                  </div>
              </div>
          </div>
      <% } %>
      </div>
  <%
          }
      } catch (Exception e) {
          e.printStackTrace();
      }

      if (!hasItinerary) {
  %>
      <div class="empty-itinerary">
          <p data-i18n="td_empty_p1">No AI itinerary generated yet for this trip.</p>
          <p class="sub" style="margin-bottom:20px;" data-i18n="td_empty_p2">Click below and the AI will build your day-wise plan.</p>
          <form action="GenerateItineraryServlet" method="POST" id="genForm">
              <input type="hidden" name="tripId" value="<%= tripId %>">
              <button type="submit" class="btn btn-primary" id="genBtn"
                      style="background: var(--gold); color: var(--ink); border:none; padding:13px 26px;
                             border-radius:999px; font-weight:700; cursor:pointer; font-size:0.9rem;
                             display:inline-flex; align-items:center; gap:9px;">
                  <span id="genSpinner" style="display:none; width:14px; height:14px; border-radius:50%;
                        border:2px solid rgba(13,21,38,0.3); border-top-color:var(--ink);
                        animation:spin 0.7s linear infinite;"></span>
                  <span id="genBtnText" data-i18n="td_generate_btn">Generate itinerary with AI</span>
              </button>
              <p class="sub" style="margin-top:14px; display:none;" id="genWaitNote" data-i18n="td_generate_wait">
                  This can take up to 20-30 seconds — please don't close this tab.
              </p>
          </form>
      </div>
      <style>@keyframes spin { to { transform: rotate(360deg); } }</style>
      <script>
        document.getElementById('genForm').addEventListener('submit', function () {
          document.getElementById('genSpinner').style.display = 'inline-block';
          document.getElementById('genBtnText').textContent = 'Generating your itinerary...';
          document.getElementById('genBtn').disabled = true;
          document.getElementById('genBtn').style.opacity = '0.75';
          document.getElementById('genWaitNote').style.display = 'block';
        });
      </script>
  <% } %>

  <!-- Expense tracker -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;" data-i18n="td_expenses_heading">Expenses</div>
    <div style="font-size:0.86rem; color:var(--muted);">
      <span data-i18n="td_expense_spent">Spent so far</span>: Rs. <%= Math.round(totalSpent) %> / Rs. <%= (int) budget %>
    </div>
    <div class="progress-track">
      <div class="progress-fill<%= spentPct >= 100 ? " over" : "" %>" style="width:<%= spentPct %>%;"></div>
    </div>

    <% for (Object[] exp : expenses) { %>
      <div class="expense-row">
        <div>
          <div><%= exp[2] %> <span class="meta">(<%= exp[1] %>)</span></div>
        </div>
        <div style="display:flex; align-items:center; gap:12px;">
          <span>Rs. <%= Math.round((double) exp[3]) %></span>
          <form action="DeleteExpenseServlet" method="POST" style="margin:0;">
            <input type="hidden" name="expenseId" value="<%= exp[0] %>">
            <input type="hidden" name="tripId" value="<%= tripId %>">
            <button type="submit" class="del">✕</button>
          </form>
        </div>
      </div>
    <% } %>

    <form action="AddExpenseServlet" method="POST" class="mini-form">
      <input type="hidden" name="tripId" value="<%= tripId %>">
      <select name="category">
        <option value="Stay">Stay</option>
        <option value="Food">Food</option>
        <option value="Activities">Activities</option>
        <option value="Transport">Transport</option>
        <option value="Other">Other</option>
      </select>
      <input type="text" name="description" placeholder="Description" data-i18n-placeholder="td_expense_desc" required>
      <input type="number" name="amount" placeholder="Amount" min="0" step="1" data-i18n-placeholder="td_expense_amount" required>
      <button type="submit" data-i18n="td_expense_add">Add expense</button>
    </form>
  </div>

  <!-- Pre-trip checklist -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">Pre-trip checklist</div>
    <% for (Object[] item : checklistItems) {
         int itemId = (int) item[0];
         String itemText = (String) item[1];
         boolean checked = (boolean) item[2];
    %>
      <div class="expense-row">
        <form action="ToggleChecklistItemServlet" method="POST" style="margin:0; display:flex; align-items:center; gap:10px; flex:1;">
          <input type="hidden" name="tripId" value="<%= tripId %>">
          <input type="hidden" name="itemId" value="<%= itemId %>">
          <button type="submit" style="background:none; border:1px solid var(--line-strong); border-radius:6px; width:20px; height:20px; cursor:pointer; color:var(--gold); flex-shrink:0; padding:0;">
              <%= checked ? "✓" : "" %>
          </button>
          <span style="<%= checked ? "text-decoration:line-through; color:var(--muted);" : "" %>"><%= itemText %></span>
        </form>
        <form action="DeleteChecklistItemServlet" method="POST" style="margin:0;">
          <input type="hidden" name="tripId" value="<%= tripId %>">
          <input type="hidden" name="itemId" value="<%= itemId %>">
          <button type="submit" class="del">✕</button>
        </form>
      </div>
    <% } %>

    <form action="AddChecklistItemServlet" method="POST" class="mini-form">
      <input type="hidden" name="tripId" value="<%= tripId %>">
      <input type="text" name="itemText" placeholder="Add an item..." style="flex:1; min-width:160px;" required>
      <button type="submit">Add</button>
    </form>
  </div>

  <!-- Trip journal & rating -->
  <div class="panel">
    <div class="section-title" style="margin-top:0;">Trip journal &amp; rating</div>
    <form action="SaveJournalServlet" method="POST">
      <input type="hidden" name="tripId" value="<%= tripId %>">
      <div class="star-rating">
        <% for (int s = 1; s <= 5; s++) { %>
          <label>
            <input type="radio" name="rating" value="<%= s %>" style="display:none;" <%= (journalRating != null && journalRating == s) ? "checked" : "" %>
                   onclick="this.closest('form').querySelectorAll('.star-lbl').forEach((el,i)=>el.classList.toggle('on', i < <%= s %>));">
            <span class="star-lbl<%= (journalRating != null && journalRating >= s) ? " on" : "" %>">&#9733;</span>
          </label>
        <% } %>
      </div>
      <textarea name="notes" rows="3" placeholder="How was the trip? Notes for next time..."
                style="width:100%; margin-top:12px; padding:12px; border-radius:8px; border:1px solid var(--line-strong); background:var(--ink-3); color:var(--paper); font-family:inherit; font-size:0.88rem; resize:vertical;"><%= journalNotes != null ? journalNotes : "" %></textarea>
      <button type="submit" style="margin-top:12px; background:var(--gold); color:var(--ink); border:none; border-radius:8px; padding:10px 18px; font-weight:700; font-size:0.85rem; cursor:pointer;">Save journal entry</button>
    </form>
  </div>

  <!-- Collaborators (owner only can invite) -->
  <% if (isOwner) { %>
  <div class="panel">
    <div class="section-title" style="margin-top:0;" data-i18n="td_collab_heading">Collaborators</div>
    <form action="AddCollaboratorServlet" method="POST" class="mini-form">
      <input type="hidden" name="tripId" value="<%= tripId %>">
      <input type="email" name="email" placeholder="Collaborator's email" data-i18n-placeholder="td_collab_invite" style="flex:1; min-width:200px;" required>
      <button type="submit" data-i18n="td_collab_add">Invite</button>
    </form>
  </div>
  <% } %>
</main>

<!-- Share trip modal -->
<div class="modal-overlay" id="shareModal">
  <div class="modal-box">
    <button class="close-modal" id="closeShareModal">✕</button>
    <h3 data-i18n="td_share">Share trip</h3>
    <input type="text" id="shareUrlInput" readonly placeholder="Generating link...">
    <button type="button" class="action-btn" id="copyShareUrl" style="width:100%; justify-content:center;">Copy link</button>
  </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<script src="js/i18n.js?v=4"></script>
<script src="js/chatbot.js?v=3"></script>
<script>
  const tripMapStops = <%= mapStopsJson %>;
  const tripMapEl = document.getElementById('tripMap');
  if (tripMapEl && tripMapStops.length > 0 && window.L) {
    const map = L.map('tripMap');
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
      maxZoom: 19
    }).addTo(map);

    const latLngs = [];
    tripMapStops.forEach((stop, i) => {
      const ll = [stop.lat, stop.lon];
      latLngs.push(ll);
      const icon = L.divIcon({
        className: '',
        html: '<div class="map-pin-badge">' + (i + 1) + '</div>',
        iconSize: [26, 26],
        iconAnchor: [13, 13]
      });
      L.marker(ll, { icon: icon }).addTo(map).bindPopup(stop.name);
    });

    if (latLngs.length > 1) {
      L.polyline(latLngs, { color: '#E7A94C', weight: 3, dashArray: '6 6' }).addTo(map);
      map.fitBounds(latLngs, { padding: [30, 30] });
    } else {
      map.setView(latLngs[0], 12);
    }
  }

  const shareBtn = document.getElementById('shareBtn');
  const shareModal = document.getElementById('shareModal');
  const shareUrlInput = document.getElementById('shareUrlInput');
  const copyBtn = document.getElementById('copyShareUrl');

  shareBtn.addEventListener('click', () => {
    shareModal.classList.add('open');
    shareUrlInput.value = 'Generating link...';
    fetch('ShareTripServlet', { method: 'POST', body: new URLSearchParams({ tripId: '<%= tripId %>' }) })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          shareUrlInput.value = data.url;
        } else {
          shareUrlInput.value = 'Could not create link: ' + data.message;
        }
      })
      .catch(() => { shareUrlInput.value = 'Could not reach the server.'; });
  });
  document.getElementById('closeShareModal').addEventListener('click', () => shareModal.classList.remove('open'));
  copyBtn.addEventListener('click', () => {
    shareUrlInput.select();
    navigator.clipboard.writeText(shareUrlInput.value).then(() => {
      copyBtn.textContent = 'Copied!';
      setTimeout(() => { copyBtn.textContent = 'Copy link'; }, 1500);
    }).catch(() => {});
  });
</script>

</body>
</html>
