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

@WebServlet("/DeleteExpenseServlet")
public class DeleteExpenseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String expenseIdStr = request.getParameter("expenseId");
        String tripIdStr = request.getParameter("tripId");
        if (expenseIdStr == null || tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int expenseId = Integer.parseInt(expenseIdStr);
        int tripId = Integer.parseInt(tripIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                // Delete only if this expense's trip belongs to (or is shared with) the logged-in user.
                String sql = "DELETE e FROM expenses e JOIN trips t ON e.trip_id = t.trip_id "
                    + "WHERE e.expense_id = ? AND e.trip_id = ? AND (t.user_id = ? OR t.trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, expenseId);
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
