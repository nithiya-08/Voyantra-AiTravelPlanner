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

@WebServlet("/AddChecklistItemServlet")
public class AddChecklistItemServlet extends HttpServlet {

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
        String itemText = request.getParameter("itemText");
        if (tripIdStr == null || itemText == null || itemText.trim().isEmpty()) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String checkSql = "SELECT trip_id FROM trips WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, tripId);
                checkStmt.setInt(2, userId);
                checkStmt.setInt(3, userId);
                if (checkStmt.executeQuery().next()) {
                    PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO trip_checklist_items (trip_id, item_text) VALUES (?, ?)");
                    stmt.setInt(1, tripId);
                    stmt.setString(2, itemText.trim());
                    stmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
