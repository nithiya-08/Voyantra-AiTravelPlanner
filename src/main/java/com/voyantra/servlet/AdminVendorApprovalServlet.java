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

@WebServlet("/AdminVendorApprovalServlet")
public class AdminVendorApprovalServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

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
        String rejectionReason = request.getParameter("rejectionReason");
        if (vendorIdStr == null || action == null ||
            !("APPROVE".equals(action) || "REJECT".equals(action))) {
            response.sendRedirect("admin-vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);
        String newStatus = "APPROVE".equals(action) ? "APPROVED" : "REJECTED";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String updateSql = "UPDATE vendors SET status = ?, rejection_reason = ? WHERE vendor_id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, newStatus);
                updateStmt.setString(2, "REJECTED".equals(newStatus) ? rejectionReason : null);
                updateStmt.setInt(3, vendorId);
                updateStmt.executeUpdate();

                String lookupSql = "SELECT u.email, v.business_name FROM vendors v "
                    + "JOIN users u ON v.user_id = u.user_id WHERE v.vendor_id = ?";
                PreparedStatement lookupStmt = conn.prepareStatement(lookupSql);
                lookupStmt.setInt(1, vendorId);
                ResultSet rs = lookupStmt.executeQuery();
                if (rs.next()) {
                    String ownerEmail = rs.getString("email");
                    String businessName = rs.getString("business_name");
                    try {
                        if ("APPROVED".equals(newStatus)) {
                            EmailService.sendPlainEmail(ownerEmail, "Your Voyantra listing is approved",
                                "Good news! Your listing \"" + businessName + "\" has been approved and is now "
                                + "visible to travellers on Voyantra.");
                        } else {
                            EmailService.sendPlainEmail(ownerEmail, "Your Voyantra listing needs changes",
                                "Your listing \"" + businessName + "\" was not approved."
                                + (rejectionReason != null && !rejectionReason.trim().isEmpty()
                                    ? " Reason: " + rejectionReason : "")
                                + " You can edit and resubmit it from your vendor dashboard.");
                        }
                    } catch (Exception mailError) {
                        mailError.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("admin-vendors.jsp");
    }
}
