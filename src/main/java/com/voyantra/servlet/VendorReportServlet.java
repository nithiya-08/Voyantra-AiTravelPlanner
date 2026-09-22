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

@WebServlet("/VendorReportServlet")
public class VendorReportServlet extends HttpServlet {

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

        String vendorIdStr = request.getParameter("vendorId");
        String reason = request.getParameter("reason");
        if (vendorIdStr == null || reason == null || reason.trim().isEmpty()) {
            response.sendRedirect("vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String insertSql = "INSERT INTO vendor_reports (vendor_id, user_id, reason) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(insertSql);
                stmt.setInt(1, vendorId);
                stmt.setInt(2, userId);
                stmt.setString(3, reason);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId + "&reportSent=1");
    }
}
