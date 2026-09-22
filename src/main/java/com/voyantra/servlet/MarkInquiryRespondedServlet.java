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

@WebServlet("/MarkInquiryRespondedServlet")
public class MarkInquiryRespondedServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String inquiryIdStr = request.getParameter("inquiryId");
        String vendorIdStr = request.getParameter("vendorId");
        if (inquiryIdStr == null || vendorIdStr == null) {
            response.sendRedirect("my-vendor-listings.jsp");
            return;
        }
        int inquiryId = Integer.parseInt(inquiryIdStr);
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE vendor_inquiries i JOIN vendors v ON i.vendor_id = v.vendor_id "
                    + "SET i.status = 'RESPONDED' "
                    + "WHERE i.inquiry_id = ? AND i.vendor_id = ? AND v.user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, inquiryId);
                stmt.setInt(2, vendorId);
                stmt.setInt(3, userId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("vendor-inquiries.jsp?vendorId=" + vendorId);
    }
}
