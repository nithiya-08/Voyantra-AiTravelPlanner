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

import com.voyantra.db.DBConnection;

@WebServlet("/ToggleVendorFavoriteServlet")
public class ToggleVendorFavoriteServlet extends HttpServlet {

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
        String returnTo = request.getParameter("returnTo");
        if (vendorIdStr == null) {
            response.sendRedirect("vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String checkSql = "SELECT favorite_id FROM vendor_favorites WHERE user_id = ? AND vendor_id = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, vendorId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    String deleteSql = "DELETE FROM vendor_favorites WHERE user_id = ? AND vendor_id = ?";
                    PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
                    deleteStmt.setInt(1, userId);
                    deleteStmt.setInt(2, vendorId);
                    deleteStmt.executeUpdate();
                } else {
                    String insertSql = "INSERT INTO vendor_favorites (user_id, vendor_id) VALUES (?, ?)";
                    PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setInt(1, userId);
                    insertStmt.setInt(2, vendorId);
                    insertStmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if ("saved".equals(returnTo)) {
            response.sendRedirect("saved-vendors.jsp");
        } else {
            response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId);
        }
    }
}
