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

@WebServlet("/AddExpenseServlet")
public class AddExpenseServlet extends HttpServlet {

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
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        String amountStr = request.getParameter("amount");

        if (tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);

        if (category == null || category.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            amountStr == null || amountStr.trim().isEmpty()) {
            response.sendRedirect("trip-details.jsp?tripId=" + tripId);
            return;
        }

        double amount;
        try {
            amount = Double.parseDouble(amountStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("trip-details.jsp?tripId=" + tripId);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                // Only the trip owner or a collaborator may log an expense against it.
                String checkSql = "SELECT trip_id FROM trips WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, tripId);
                checkStmt.setInt(2, userId);
                checkStmt.setInt(3, userId);
                if (checkStmt.executeQuery().next()) {
                    String insertSql = "INSERT INTO expenses (trip_id, category, description, amount) VALUES (?, ?, ?, ?)";
                    PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setInt(1, tripId);
                    insertStmt.setString(2, category);
                    insertStmt.setString(3, description);
                    insertStmt.setDouble(4, amount);
                    insertStmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
