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

@WebServlet("/VendorDeleteServlet")
public class VendorDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String vendorIdStr = request.getParameter("vendorId");
        if (vendorIdStr == null) {
            response.sendRedirect("my-vendor-listings.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "DELETE FROM vendors WHERE vendor_id = ? AND user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, vendorId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("my-vendor-listings.jsp");
    }
}
