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

@WebServlet("/AdminToggleUserBlockServlet")
public class AdminToggleUserBlockServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
        if (isAdminAttr == null || !isAdminAttr) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int adminUserId = (int) session.getAttribute("userId");

        String targetUserIdStr = request.getParameter("userId");
        String action = request.getParameter("action");
        if (targetUserIdStr == null || action == null ||
            !("BLOCK".equals(action) || "UNBLOCK".equals(action))) {
            response.sendRedirect("admin-users.jsp");
            return;
        }
        int targetUserId = Integer.parseInt(targetUserIdStr);

        if ("BLOCK".equals(action) && targetUserId == adminUserId) {
            response.sendRedirect("admin-users.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE users SET is_blocked = ? WHERE user_id = ? AND is_admin = 0";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setBoolean(1, "BLOCK".equals(action));
                stmt.setInt(2, targetUserId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("admin-users.jsp");
    }
}
