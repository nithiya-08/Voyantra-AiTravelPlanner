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

@WebServlet("/AddCollaboratorServlet")
public class AddCollaboratorServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int ownerId = (int) session.getAttribute("userId");

        String tripIdStr = request.getParameter("tripId");
        String email = request.getParameter("email");
        if (tripIdStr == null || email == null || email.trim().isEmpty()) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);
        String message;

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                message = "Database connection failed.";
            } else {
                String ownerCheckSql = "SELECT trip_id FROM trips WHERE trip_id = ? AND user_id = ?";
                PreparedStatement ownerCheckStmt = conn.prepareStatement(ownerCheckSql);
                ownerCheckStmt.setInt(1, tripId);
                ownerCheckStmt.setInt(2, ownerId);

                if (!ownerCheckStmt.executeQuery().next()) {
                    message = "Only the trip owner can invite collaborators.";
                } else {
                    String userSql = "SELECT user_id FROM users WHERE email = ? AND is_verified = TRUE";
                    PreparedStatement userStmt = conn.prepareStatement(userSql);
                    userStmt.setString(1, email.trim());
                    ResultSet userRs = userStmt.executeQuery();

                    if (!userRs.next()) {
                        message = "No verified Voyantra account found for that email.";
                    } else {
                        int collaboratorId = userRs.getInt("user_id");
                        if (collaboratorId == ownerId) {
                            message = "You already own this trip.";
                        } else {
                            String insertSql = "INSERT IGNORE INTO trip_collaborators (trip_id, user_id) VALUES (?, ?)";
                            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                            insertStmt.setInt(1, tripId);
                            insertStmt.setInt(2, collaboratorId);
                            insertStmt.executeUpdate();
                            message = "Collaborator added.";
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Something went wrong: " + e.getMessage();
        }

        response.sendRedirect("trip-details.jsp?tripId=" + tripId + "&collabMsg="
            + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}
