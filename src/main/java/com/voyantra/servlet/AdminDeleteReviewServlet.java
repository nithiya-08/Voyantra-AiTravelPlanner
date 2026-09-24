package com.voyantra.servlet;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
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

@WebServlet("/AdminDeleteReviewServlet")
public class AdminDeleteReviewServlet extends HttpServlet {

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

        String reviewIdStr = request.getParameter("reviewId");
        String vendorIdStr = request.getParameter("vendorId");
        if (reviewIdStr == null || vendorIdStr == null) {
            response.sendRedirect("vendors.jsp");
            return;
        }
        int reviewId = Integer.parseInt(reviewIdStr);
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String photoSql = "SELECT photo_url FROM vendor_reviews WHERE review_id = ?";
                PreparedStatement photoStmt = conn.prepareStatement(photoSql);
                photoStmt.setInt(1, reviewId);
                ResultSet photoRs = photoStmt.executeQuery();
                String photoUrl = photoRs.next() ? photoRs.getString("photo_url") : null;

                String sql = "DELETE FROM vendor_reviews WHERE review_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, reviewId);
                stmt.executeUpdate();

                if (photoUrl != null && photoUrl.startsWith("uploads/reviews/")) {
                    String realPath = getServletContext().getRealPath("/" + photoUrl);
                    if (realPath != null) {
                        try { Files.deleteIfExists(Paths.get(realPath)); } catch (Exception ignored) {}
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId);
    }
}
