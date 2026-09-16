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

@WebServlet("/ToggleChecklistItemServlet")
public class ToggleChecklistItemServlet extends HttpServlet {

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
        String itemIdStr = request.getParameter("itemId");
        if (tripIdStr == null || itemIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);
        int itemId = Integer.parseInt(itemIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE trip_checklist_items c JOIN trips t ON c.trip_id = t.trip_id "
                    + "SET c.is_checked = NOT c.is_checked "
                    + "WHERE c.item_id = ? AND c.trip_id = ? AND (t.user_id = ? OR t.trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, itemId);
                stmt.setInt(2, tripId);
                stmt.setInt(3, userId);
                stmt.setInt(4, userId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
