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

@WebServlet("/AdminVendorVerifyServlet")
public class AdminVendorVerifyServlet extends HttpServlet {

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

        String vendorIdStr = request.getParameter("vendorId");
        String action = request.getParameter("action");
        if (vendorIdStr == null || action == null ||
            !("VERIFY".equals(action) || "UNVERIFY".equals(action))) {
            response.sendRedirect("admin-vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE vendors SET is_verified = ? WHERE vendor_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setBoolean(1, "VERIFY".equals(action));
                stmt.setInt(2, vendorId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("admin-vendors.jsp");
    }
}
