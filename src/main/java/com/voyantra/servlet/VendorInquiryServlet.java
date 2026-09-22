package com.voyantra.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.ai.EmailService;
import com.voyantra.db.DBConnection;

@WebServlet("/VendorInquiryServlet")
public class VendorInquiryServlet extends HttpServlet {

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
        String userName = (String) session.getAttribute("userName");

        String vendorIdStr = request.getParameter("vendorId");
        String message = request.getParameter("message");
        String contactPhone = request.getParameter("contactPhone");
        String travelDates = request.getParameter("travelDates");

        if (vendorIdStr == null || message == null || message.trim().isEmpty()) {
            response.sendRedirect("vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String insertSql = "INSERT INTO vendor_inquiries (vendor_id, user_id, message, contact_phone, travel_dates) "
                    + "VALUES (?, ?, ?, ?, ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                insertStmt.setInt(1, vendorId);
                insertStmt.setInt(2, userId);
                insertStmt.setString(3, message);
                insertStmt.setString(4, contactPhone);
                insertStmt.setString(5, travelDates);
                insertStmt.executeUpdate();

                String lookupSql = "SELECT u.email, v.business_name FROM vendors v "
                    + "JOIN users u ON v.user_id = u.user_id WHERE v.vendor_id = ?";
                PreparedStatement lookupStmt = conn.prepareStatement(lookupSql);
                lookupStmt.setInt(1, vendorId);
                ResultSet rs = lookupStmt.executeQuery();
                if (rs.next()) {
                    String ownerEmail = rs.getString("email");
                    String businessName = rs.getString("business_name");
                    if (ownerEmail != null && !ownerEmail.trim().isEmpty()) {
                        try {
                            EmailService.sendPlainEmail(ownerEmail, "New inquiry for " + businessName,
                                userName + " sent you a message on Voyantra:\n\n\"" + message + "\"\n\n"
                                + "Check your Vendor Inquiries page to respond.");
                        } catch (Exception mailError) {
                            mailError.printStackTrace();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId + "&inquirySent=1");
    }
}
