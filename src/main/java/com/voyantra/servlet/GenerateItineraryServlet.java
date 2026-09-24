package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import com.voyantra.ai.GeminiItineraryClient;
import com.voyantra.db.DBConnection;

@WebServlet("/GenerateItineraryServlet")
public class GenerateItineraryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String tripIdStr = request.getParameter("tripId");
        if (tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                out.println("<h2>Database connection failed.</h2>");
                return;
            }

            String selectSql = "SELECT destination, budget, num_days, travel_style, interests "
                             + "FROM trips WHERE trip_id = ? AND user_id = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, tripId);
            selectStmt.setInt(2, userId);
            ResultSet rs = selectStmt.executeQuery();

            if (!rs.next()) {
                out.println("<h2>Trip not found.</h2>");
                out.println("<a href='dashboard.jsp'>Back to dashboard</a>");
                return;
            }

            String destination = rs.getString("destination");
            double budget = rs.getDouble("budget");
            int numDays = rs.getInt("num_days");
            String travelStyle = rs.getString("travel_style");
            String interests = rs.getString("interests");

            // ---- Look up a real approved Voyantra vendor for this destination, if one exists,
            //      so the AI itinerary can point at an actual bookable local listing. ----
            Integer hotelVendorId = null;
            String hotelVendorName = null;
            Integer foodVendorId = null;
            String foodVendorName = null;

            String vendorSql = "SELECT vendor_id, business_name FROM vendors "
                + "WHERE status = 'APPROVED' AND category IN ('HOTEL', 'HOMESTAY') "
                + "AND (city LIKE ? OR ? LIKE CONCAT('%', city, '%')) "
                + "ORDER BY (SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = vendors.vendor_id) DESC "
                + "LIMIT 1";
            PreparedStatement vendorStmt = conn.prepareStatement(vendorSql);
            vendorStmt.setString(1, "%" + destination + "%");
            vendorStmt.setString(2, destination);
            ResultSet vendorRs = vendorStmt.executeQuery();
            if (vendorRs.next()) {
                hotelVendorId = vendorRs.getInt("vendor_id");
                hotelVendorName = vendorRs.getString("business_name");
            }

            String foodVendorSql = "SELECT vendor_id, business_name FROM vendors "
                + "WHERE status = 'APPROVED' AND category = 'RESTAURANT' "
                + "AND (city LIKE ? OR ? LIKE CONCAT('%', city, '%')) "
                + "ORDER BY (SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = vendors.vendor_id) DESC "
                + "LIMIT 1";
            PreparedStatement foodVendorStmt = conn.prepareStatement(foodVendorSql);
            foodVendorStmt.setString(1, "%" + destination + "%");
            foodVendorStmt.setString(2, destination);
            ResultSet foodVendorRs = foodVendorStmt.executeQuery();
            if (foodVendorRs.next()) {
                foodVendorId = foodVendorRs.getInt("vendor_id");
                foodVendorName = foodVendorRs.getString("business_name");
            }

            GeminiItineraryClient aiClient = new GeminiItineraryClient();
            JSONArray days = aiClient.generateItinerary(destination, budget, numDays, travelStyle, interests,
                hotelVendorName, foodVendorName);

            String deleteSql = "DELETE FROM itineraries WHERE trip_id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, tripId);
            deleteStmt.executeUpdate();

            String insertSql = "INSERT INTO itineraries (trip_id, day_number, activities, food_suggestions, "
                              + "hotel_suggestion, weather_info, suggested_hotel_vendor_id, suggested_food_vendor_id) "
                              + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);

            for (int i = 0; i < days.length(); i++) {
                JSONObject day = days.getJSONObject(i);
                insertStmt.setInt(1, tripId);
                insertStmt.setInt(2, day.optInt("day", i + 1));
                insertStmt.setString(3, day.optString("activities", ""));
                insertStmt.setString(4, day.optString("food", ""));
                insertStmt.setString(5, day.optString("hotel", ""));
                insertStmt.setString(6, day.optString("weather", ""));
                if (hotelVendorId != null) insertStmt.setInt(7, hotelVendorId); else insertStmt.setNull(7, java.sql.Types.INTEGER);
                if (foodVendorId != null) insertStmt.setInt(8, foodVendorId); else insertStmt.setNull(8, java.sql.Types.INTEGER);
                insertStmt.executeUpdate();
            }

            response.sendRedirect("trip-details.jsp?tripId=" + tripId);

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2>Database error.</h2><p>" + e.getMessage() + "</p>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h2>AI generation failed.</h2><p>" + e.getMessage() + "</p>");
            out.println("<a href='trip-details.jsp?tripId=" + tripId + "'>Back to trip</a>");
        }
    }

}
