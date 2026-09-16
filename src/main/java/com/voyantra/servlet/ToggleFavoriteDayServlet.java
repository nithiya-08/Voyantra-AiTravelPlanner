package com.voyantra.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.db.DBConnection;

@WebServlet("/ToggleFavoriteDayServlet")
public class ToggleFavoriteDayServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String tripIdStr = request.getParameter("tripId");
        String dayNumberStr = request.getParameter("dayNumber");
        if (tripIdStr == null || dayNumberStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);
        int dayNumber = Integer.parseInt(dayNumberStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE itineraries i JOIN trips t ON i.trip_id = t.trip_id "
                    + "SET i.is_favorite = NOT i.is_favorite "
                    + "WHERE i.trip_id = ? AND i.day_number = ? AND (t.user_id = ? OR t.trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, tripId);
                stmt.setInt(2, dayNumber);
                stmt.setInt(3, userId);
                stmt.setInt(4, userId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId + "#day-" + dayNumber);
    }
}
