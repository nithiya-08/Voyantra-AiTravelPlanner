package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.ai.GeocodingService;
import com.voyantra.ai.RouteOptimizer;
import com.voyantra.db.DBConnection;

@WebServlet("/TripServlet")
public class TripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            out.println("<h2>Please log in first</h2>");
            out.println("<p>You need to be logged in to create a trip.</p>");
            out.println("<a href='login.html'>Go to login</a>");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        // ---- Read the multiple stop names ----
        String[] stopNames = request.getParameterValues("stops");
        String budgetStr = request.getParameter("budget");
        String numDaysStr = request.getParameter("numDays");
        String travelStyle = request.getParameter("travelStyle");
        String[] interestsArray = request.getParameterValues("interests");
        String startDateStr = request.getParameter("startDate"); // optional
        String foodPreference = request.getParameter("foodPreference"); // optional: VEG, NON_VEG
        if (foodPreference != null && !("VEG".equals(foodPreference) || "NON_VEG".equals(foodPreference))) {
            foodPreference = null;
        }

        if (stopNames == null || stopNames.length == 0 ||
            budgetStr == null || numDaysStr == null ||
            travelStyle == null || travelStyle.trim().isEmpty() ||
            interestsArray == null || interestsArray.length == 0) {

            out.println("<h2>Trip creation failed</h2>");
            out.println("<p>Please fill all fields, add at least one destination, and select at least one interest.</p>");
            out.println("<a href='trip-form.html'>Go back</a>");
            return;
        }

        // Remove any blank stop entries
        List<String> cleanStops = new ArrayList<>();
        for (String s : stopNames) {
            if (s != null && s.trim().length() > 0) cleanStops.add(s.trim());
        }
        if (cleanStops.isEmpty()) {
            out.println("<h2>Trip creation failed</h2>");
            out.println("<p>Please enter at least one destination.</p>");
            out.println("<a href='trip-form.html'>Go back</a>");
            return;
        }

        double budget;
        int numDays;
        try {
            budget = Double.parseDouble(budgetStr);
            numDays = Integer.parseInt(numDaysStr);
        } catch (NumberFormatException e) {
            out.println("<h2>Trip creation failed</h2>");
            out.println("<p>Budget and number of days must be valid numbers.</p>");
            out.println("<a href='trip-form.html'>Go back</a>");
            return;
        }

        Date startDate = null;
        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            try {
                startDate = Date.valueOf(startDateStr.trim()); // expects yyyy-MM-dd from <input type="date">
            } catch (IllegalArgumentException ignored) {}
        }

        String interests = String.join(", ", interestsArray);
        // Use the first stop as the trip's "main" destination (for AI prompt + display)
        String mainDestination = cleanStops.get(0);

        // ---- Geocode each stop into coordinates (and pick up the main stop's country) ----
        List<RouteOptimizer.Stop> stopsWithCoords = new ArrayList<>();
        String countryCode = null;
        for (String stopName : cleanStops) {
            GeocodingService.Coordinates coords = GeocodingService.getCoordinates(stopName);
            if (coords != null) {
                stopsWithCoords.add(new RouteOptimizer.Stop(stopName, coords.latitude, coords.longitude));
                if (countryCode == null) countryCode = coords.countryCode;
            } else {
                // If a place can't be geocoded, still keep it with 0,0 so it's not lost
                stopsWithCoords.add(new RouteOptimizer.Stop(stopName, 0, 0));
            }
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                out.println("<h2>Database connection failed.</h2>");
                return;
            }

            // ---- Step 1: Insert the trip itself ----
            String sql = "INSERT INTO trips (user_id, destination, budget, num_days, travel_style, interests, "
                       + "start_date, country_code, food_preference) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, userId);
            stmt.setString(2, mainDestination);
            stmt.setDouble(3, budget);
            stmt.setInt(4, numDays);
            stmt.setString(5, travelStyle);
            stmt.setString(6, interests);
            if (startDate != null) stmt.setDate(7, startDate); else stmt.setNull(7, java.sql.Types.DATE);
            stmt.setString(8, countryCode);
            stmt.setString(9, foodPreference);

            int rows = stmt.executeUpdate();

            if (rows > 0) {
                ResultSet keys = stmt.getGeneratedKeys();
                int newTripId = 0;
                if (keys.next()) {
                    newTripId = keys.getInt(1);
                }

                // ---- Step 2: Optimize the visiting order ----
                List<RouteOptimizer.Stop> optimizedRoute = RouteOptimizer.optimizeRoute(stopsWithCoords);

                // ---- Step 3: Save each stop with its visit order ----
                String stopSql = "INSERT INTO trip_stops (trip_id, stop_name, latitude, longitude, visit_order) "
                               + "VALUES (?, ?, ?, ?, ?)";
                PreparedStatement stopStmt = conn.prepareStatement(stopSql);

                int order = 1;
                for (RouteOptimizer.Stop stop : optimizedRoute) {
                    stopStmt.setInt(1, newTripId);
                    stopStmt.setString(2, stop.name);
                    stopStmt.setDouble(3, stop.latitude);
                    stopStmt.setDouble(4, stop.longitude);
                    stopStmt.setInt(5, order);
                    stopStmt.executeUpdate();
                    order++;
                }

                response.sendRedirect("trip-details.jsp?tripId=" + newTripId);
            } else {
                out.println("<h2>Trip creation failed. Please try again.</h2>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2>Something went wrong.</h2>");
            out.println("<p>" + e.getMessage() + "</p>");
        }
    }
}
