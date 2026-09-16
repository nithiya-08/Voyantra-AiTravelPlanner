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

@WebServlet("/SaveJournalServlet")
public class SaveJournalServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String tripIdStr = request.getParameter("tripId");
        String ratingStr = request.getParameter("rating");
        String notes = request.getParameter("notes");
        if (tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);
        Integer rating = null;
        if (ratingStr != null && !ratingStr.trim().isEmpty()) {
            try {
                int r = Integer.parseInt(ratingStr);
                if (r >= 1 && r <= 5) rating = r;
            } catch (NumberFormatException ignored) {}
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String checkSql = "SELECT trip_id FROM trips WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, tripId);
                checkStmt.setInt(2, userId);
                checkStmt.setInt(3, userId);
                if (checkStmt.executeQuery().next()) {
                    String upsertSql = "INSERT INTO trip_journal (trip_id, rating, notes) VALUES (?, ?, ?) "
                        + "ON DUPLICATE KEY UPDATE rating = VALUES(rating), notes = VALUES(notes)";
                    PreparedStatement stmt = conn.prepareStatement(upsertSql);
                    stmt.setInt(1, tripId);
                    if (rating != null) stmt.setInt(2, rating); else stmt.setNull(2, java.sql.Types.TINYINT);
                    stmt.setString(3, notes);
                    stmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
