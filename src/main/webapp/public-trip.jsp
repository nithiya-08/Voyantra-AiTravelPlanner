<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    // Read-only public view of a trip, reached via its share link. No login required.
    String token = request.getParameter("token");
    if (token == null || token.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    String destination = null;
    double budget = 0;
    int numDays = 0;
    String travelStyle = null;
    String interests = null;
    boolean found = false;
    int tripId = 0;

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT trip_id, destination, budget, num_days, travel_style, interests "
                       + "FROM trips WHERE share_token = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, token);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                tripId = rs.getInt("trip_id");
                destination = rs.getString("destination");
                budget = rs.getDouble("budget");
                numDays = rs.getInt("num_days");
                travelStyle = rs.getString("travel_style");
                interests = rs.getString("interests");
                found = true;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= found ? destination + " - Shared trip" : "Trip not found" %> — Voyantra</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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
  header { display: flex; align-items: center; justify-content: space-between; padding: 18px 6vw; border-bottom: 1px solid var(--line); }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand-mark { width: 28px; height: 28px; }
  .brand-word { font-family: 'Fraunces', serif; font-weight: 600; font-size: 1.15rem; }
  .brand-word .accent { color: var(--gold); font-weight: 500; font-style: italic; }
  .badge { font-size: 0.76rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--teal); }
  main { max-width: 800px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  .trip-hero { background: var(--ink-2); border: 1px solid var(--line); border-radius: 20px; padding: 32px; margin-bottom: 28px; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 2.1rem; margin-bottom: 20px; }
  .stat-row { display: flex; flex-wrap: wrap; gap: 14px; margin-bottom: 14px; }
  .stat-box { background: var(--ink-3); border: 1px solid var(--line); border-radius: 12px; padding: 14px 18px; flex: 1; min-width: 130px; }
  .stat-box .k { font-size: 0.72rem; text-transform: uppercase; color: var(--muted); font-weight: 600; }
  .stat-box .v { font-family: 'Fraunces', serif; font-size: 1.3rem; margin-top: 5px; color: var(--gold); }
  .interests-line { font-size: 0.92rem; color: var(--muted); }
  .day-card { background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px; padding: 24px; margin-bottom: 18px; }
  .day-badge { font-family: 'Fraunces', serif; font-weight: 600; color: var(--ink); background: var(--gold); width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center; margin-bottom: 14px; }
  .day-row { margin-bottom: 10px; font-size: 0.9rem; }
  .day-row .lbl { font-size: 0.72rem; text-transform: uppercase; color: var(--muted); font-weight: 600; }
  .section-title { font-family: 'Fraunces', serif; font-size: 1.4rem; margin-bottom: 18px; }
  .not-found { text-align: center; padding: 60px 20px; }
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
  <span class="badge">Shared trip — view only</span>
</header>

<main>
<% if (!found) { %>
  <div class="not-found">
    <h1>Trip not found</h1>
    <p style="color:var(--muted); margin-top:10px;">This share link is invalid or the trip no longer exists.</p>
  </div>
<% } else { %>
  <div class="trip-hero">
    <h1><%= destination %></h1>
    <div class="stat-row">
      <div class="stat-box"><div class="k">Budget</div><div class="v">Rs. <%= (int) budget %></div></div>
      <div class="stat-box"><div class="k">Duration</div><div class="v"><%= numDays %> days</div></div>
      <div class="stat-box"><div class="k">Style</div><div class="v"><%= travelStyle %></div></div>
    </div>
    <div class="interests-line"><strong style="color:var(--paper);">Interests:</strong> <%= interests %></div>
  </div>

  <div class="section-title">Day-wise itinerary</div>
  <%
      try (Connection conn2 = DBConnection.getConnection()) {
          if (conn2 != null) {
              String sql2 = "SELECT day_number, activities, food_suggestions, hotel_suggestion, weather_info "
                          + "FROM itineraries WHERE trip_id = ? ORDER BY day_number ASC";
              PreparedStatement stmt2 = conn2.prepareStatement(sql2);
              stmt2.setInt(1, tripId);
              ResultSet rs2 = stmt2.executeQuery();
              boolean any = false;
              while (rs2.next()) {
                  any = true;
  %>
    <div class="day-card">
      <div class="day-badge"><%= rs2.getInt("day_number") %></div>
      <div class="day-row"><div class="lbl">Activities</div><%= rs2.getString("activities") %></div>
      <div class="day-row"><div class="lbl">Food</div><%= rs2.getString("food_suggestions") %></div>
      <div class="day-row"><div class="lbl">Stay</div><%= rs2.getString("hotel_suggestion") %></div>
      <div class="day-row"><div class="lbl">Weather</div><%= rs2.getString("weather_info") %></div>
    </div>
  <%
              }
              if (!any) {
  %>
    <p style="color:var(--muted);">No itinerary has been generated for this trip yet.</p>
  <%
              }
          }
      } catch (Exception e) {
          e.printStackTrace();
      }
  %>
<% } %>
</main>

</body>
</html>
