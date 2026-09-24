package com.voyantra.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

/**
 * A tourist who has a trip to a destination can contribute a real photo of
 * it to a shared gallery for that destination — separate from the stock/AI
 * photo carousel (which just shows generic representative images) and from
 * vendor-review photos (which are tied to one specific vendor, not the
 * place as a whole).
 */
@WebServlet("/UploadDestinationPhotoServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class UploadDestinationPhotoServlet extends HttpServlet {

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

        String tripIdStr = request.getParameter("tripId");
        String caption = request.getParameter("caption");
        if (tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);

        // Only someone who actually has this trip (owner or collaborator) can
        // contribute a photo for its destination.
        String destination = null;
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String tripSql = "SELECT destination FROM trips WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement tripStmt = conn.prepareStatement(tripSql);
                tripStmt.setInt(1, tripId);
                tripStmt.setInt(2, userId);
                tripStmt.setInt(3, userId);
                ResultSet rs = tripStmt.executeQuery();
                if (rs.next()) destination = rs.getString("destination");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (destination == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        String uploadedPhotoUrl = null;
        try {
            Part photoPart = request.getPart("photo");
            if (photoPart != null && photoPart.getSize() > 0) {
                String extension = IMAGE_EXTENSIONS.get(photoPart.getContentType());
                if (extension != null) {
                    String uploadDir = getServletContext().getRealPath("/uploads/destinations/");
                    if (uploadDir != null) {
                        Path uploadDirPath = Paths.get(uploadDir);
                        Files.createDirectories(uploadDirPath);
                        String filename = UUID.randomUUID().toString() + extension;
                        Path targetPath = uploadDirPath.resolve(filename);
                        try (InputStream in = photoPart.getInputStream()) {
                            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
                        }
                        uploadedPhotoUrl = "uploads/destinations/" + filename;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (uploadedPhotoUrl != null) {
            try (Connection conn = DBConnection.getConnection()) {
                if (conn != null) {
                    String insertSql = "INSERT INTO destination_photos (destination, user_id, photo_url, caption) VALUES (?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(insertSql);
                    stmt.setString(1, destination);
                    stmt.setInt(2, userId);
                    stmt.setString(3, uploadedPhotoUrl);
                    stmt.setString(4, caption);
                    stmt.executeUpdate();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
