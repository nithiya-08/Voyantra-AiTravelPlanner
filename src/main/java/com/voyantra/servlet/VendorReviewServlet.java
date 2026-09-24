package com.voyantra.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.voyantra.db.DBConnection;

@WebServlet("/VendorReviewServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class VendorReviewServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Map<String, String> IMAGE_EXTENSIONS = new HashMap<>();
    static {
        IMAGE_EXTENSIONS.put("image/jpeg", ".jpg");
        IMAGE_EXTENSIONS.put("image/png", ".png");
        IMAGE_EXTENSIONS.put("image/webp", ".webp");
        IMAGE_EXTENSIONS.put("image/gif", ".gif");
    }

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
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (vendorIdStr == null || ratingStr == null) {
            response.sendRedirect("vendors.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        int rating;
        try {
            rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId);
            return;
        }
        if (rating < 1 || rating > 5) {
            response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId);
            return;
        }

        // Best-effort photo attach — never blocks the review itself if it fails.
        String uploadedPhotoUrl = null;
        try {
            Part photoPart = request.getPart("photo");
            if (photoPart != null && photoPart.getSize() > 0) {
                String contentType = photoPart.getContentType();
                String extension = IMAGE_EXTENSIONS.get(contentType);
                if (extension != null) {
                    String uploadDir = getServletContext().getRealPath("/uploads/reviews/");
                    if (uploadDir != null) {
                        Path uploadDirPath = Paths.get(uploadDir);
                        Files.createDirectories(uploadDirPath);
                        String filename = UUID.randomUUID().toString() + extension;
                        Path targetPath = uploadDirPath.resolve(filename);
                        try (InputStream in = photoPart.getInputStream()) {
                            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
                        }
                        uploadedPhotoUrl = "uploads/reviews/" + filename;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String upsertSql = "INSERT INTO vendor_reviews (vendor_id, user_id, rating, comment) VALUES (?, ?, ?, ?) "
                    + "ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)";
                PreparedStatement stmt = conn.prepareStatement(upsertSql);
                stmt.setInt(1, vendorId);
                stmt.setInt(2, userId);
                stmt.setInt(3, rating);
                stmt.setString(4, comment);
                stmt.executeUpdate();

                // Only touch the photo if a new one was actually uploaded this time,
                // so editing a rating/comment never wipes an existing attached photo.
                if (uploadedPhotoUrl != null) {
                    String photoSql = "UPDATE vendor_reviews SET photo_url = ? WHERE vendor_id = ? AND user_id = ?";
                    PreparedStatement photoStmt = conn.prepareStatement(photoSql);
                    photoStmt.setString(1, uploadedPhotoUrl);
                    photoStmt.setInt(2, vendorId);
                    photoStmt.setInt(3, userId);
                    photoStmt.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("vendor-details.jsp?vendorId=" + vendorId);
    }
}
