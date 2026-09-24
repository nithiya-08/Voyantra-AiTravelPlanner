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

@WebServlet("/DeleteDestinationPhotoServlet")
public class DeleteDestinationPhotoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");
        Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
        boolean isAdmin = (isAdminAttr != null && isAdminAttr);

        String photoIdStr = request.getParameter("photoId");
        String tripIdStr = request.getParameter("tripId");
        if (photoIdStr == null || tripIdStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int photoId = Integer.parseInt(photoIdStr);
        int tripId = Integer.parseInt(tripIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String selectSql = "SELECT user_id, photo_url FROM destination_photos WHERE photo_id = ?";
                PreparedStatement selectStmt = conn.prepareStatement(selectSql);
                selectStmt.setInt(1, photoId);
                ResultSet rs = selectStmt.executeQuery();

                if (rs.next()) {
                    int ownerUserId = rs.getInt("user_id");
                    String photoUrl = rs.getString("photo_url");

                    if (isAdmin || ownerUserId == userId) {
                        String deleteSql = "DELETE FROM destination_photos WHERE photo_id = ?";
                        PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
                        deleteStmt.setInt(1, photoId);
                        deleteStmt.executeUpdate();

                        if (photoUrl != null && photoUrl.startsWith("uploads/destinations/")) {
                            String realPath = getServletContext().getRealPath("/" + photoUrl);
                            if (realPath != null) {
                                try { Files.deleteIfExists(Paths.get(realPath)); } catch (Exception ignored) {}
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId);
    }
}
