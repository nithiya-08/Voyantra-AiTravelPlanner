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

@WebServlet("/AdminVendorReportServlet")
public class AdminVendorReportServlet extends HttpServlet {

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

        String reportIdStr = request.getParameter("reportId");
        String vendorIdStr = request.getParameter("vendorId");
        String action = request.getParameter("action");
        if (reportIdStr == null || vendorIdStr == null || action == null ||
            !("DISMISS".equals(action) || "SUSPEND".equals(action))) {
            response.sendRedirect("admin-vendors.jsp");
            return;
        }
        int reportId = Integer.parseInt(reportIdStr);
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String updateReportSql = "UPDATE vendor_reports SET status = 'RESOLVED' WHERE report_id = ?";
                PreparedStatement updateReportStmt = conn.prepareStatement(updateReportSql);
                updateReportStmt.setInt(1, reportId);
                updateReportStmt.executeUpdate();

                if ("SUSPEND".equals(action)) {
                    String suspendSql = "UPDATE vendors SET status = 'SUSPENDED' WHERE vendor_id = ?";
                    PreparedStatement suspendStmt = conn.prepareStatement(suspendSql);
                    suspendStmt.setInt(1, vendorId);
                    suspendStmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("admin-vendors.jsp");
    }
}
