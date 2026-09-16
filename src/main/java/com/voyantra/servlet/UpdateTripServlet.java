package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.db.DBConnection;

@WebServlet("/UpdateTripServlet")
public class UpdateTripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // ---- Step 1: Must be logged in ----
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        // ---- Step 2: Read form data ----
        String tripIdStr = request.getParameter("tripId");
        String destination = request.getParameter("destination");
        String budgetStr = request.getParameter("budget");
        String numDaysStr = request.getParameter("numDays");
        String travelStyle = request.getParameter("travelStyle");
        String[] interestsArray = request.getParameterValues("interests");
        String startDateStr = request.getParameter("startDate"); // optional

        if (tripIdStr == null || destination == null || destination.trim().isEmpty() ||
            budgetStr == null || numDaysStr == null ||
            travelStyle == null || travelStyle.trim().isEmpty() ||
            interestsArray == null || interestsArray.length == 0) {

            out.println("<h2>Update failed</h2>");
            out.println("<p>Please fill all fields and select at least one interest.</p>");
            out.println("<a href='dashboard.jsp'>Back to dashboard</a>");
            return;
        }

        int tripId;
        double budget;
        int numDays;
        try {
            tripId = Integer.parseInt(tripIdStr);
            budget = Double.parseDouble(budgetStr);
            numDays = Integer.parseInt(numDaysStr);
        } catch (NumberFormatException e) {
            out.println("<h2>Update failed</h2>");
            out.println("<p>Invalid numbers submitted.</p>");
            out.println("<a href='dashboard.jsp'>Back to dashboard</a>");
            return;
        }

        String interests = String.join(", ", interestsArray);

        Date startDate = null;
        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            try {
                startDate = Date.valueOf(startDateStr.trim());
            } catch (IllegalArgumentException ignored) {}
        }

        // ---- Step 3: Update the trip (only if it belongs to this user) ----
        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                out.println("<h2>Database connection failed.</h2>");
                return;
            }

            String sql = "UPDATE trips SET destination = ?, budget = ?, num_days = ?, "
                       + "travel_style = ?, interests = ?, start_date = ? WHERE trip_id = ? AND user_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, destination);
            stmt.setDouble(2, budget);
            stmt.setInt(3, numDays);
            stmt.setString(4, travelStyle);
            stmt.setString(5, interests);
            if (startDate != null) stmt.setDate(6, startDate); else stmt.setNull(6, java.sql.Types.DATE);
            stmt.setInt(7, tripId);
            stmt.setInt(8, userId);

            stmt.executeUpdate();

            // ---- Step 4: Go back to the trip's details page to see the update ----
            response.sendRedirect("trip-details.jsp?tripId=" + tripId);

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2>Something went wrong.</h2>");
            out.println("<p>" + e.getMessage() + "</p>");
        }
    }
}