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

            GeminiItineraryClient aiClient = new GeminiItineraryClient();
            JSONArray days = aiClient.generateItinerary(destination, budget, numDays, travelStyle, interests);

            String deleteSql = "DELETE FROM itineraries WHERE trip_id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, tripId);
            deleteStmt.executeUpdate();

            String insertSql = "INSERT INTO itineraries (trip_id, day_number, activities, food_suggestions, "
                              + "hotel_suggestion, weather_info) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);

            for (int i = 0; i < days.length(); i++) {
                JSONObject day = days.getJSONObject(i);
                insertStmt.setInt(1, tripId);
                insertStmt.setInt(2, day.optInt("day", i + 1));
                insertStmt.setString(3, day.optString("activities", ""));
                insertStmt.setString(4, day.optString("food", ""));
                insertStmt.setString(5, day.optString("hotel", ""));
                insertStmt.setString(6, day.optString("weather", ""));
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
