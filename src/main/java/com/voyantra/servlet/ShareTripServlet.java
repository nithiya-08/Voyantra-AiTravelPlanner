package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import com.voyantra.db.DBConnection;

/**
 * Generates (or returns the existing) public share token for a trip the
 * logged-in user owns, so it can be viewed read-only without logging in.
 */
@WebServlet("/ShareTripServlet")
public class ShareTripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            json.put("success", false);
            json.put("message", "Please log in first.");
            out.print(json.toString());
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String tripIdStr = request.getParameter("tripId");
        if (tripIdStr == null) {
            json.put("success", false);
            json.put("message", "Missing trip.");
            out.print(json.toString());
            return;
        }
        int tripId = Integer.parseInt(tripIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                json.put("success", false);
                json.put("message", "Database connection failed.");
                out.print(json.toString());
                return;
            }

            String selectSql = "SELECT share_token FROM trips WHERE trip_id = ? AND user_id = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, tripId);
            selectStmt.setInt(2, userId);
            ResultSet rs = selectStmt.executeQuery();

            if (!rs.next()) {
                json.put("success", false);
                json.put("message", "Trip not found.");
                out.print(json.toString());
                return;
            }

            String token = rs.getString("share_token");
            if (token == null || token.isEmpty()) {
                token = UUID.randomUUID().toString().replace("-", "");
                String updateSql = "UPDATE trips SET share_token = ? WHERE trip_id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, token);
                updateStmt.setInt(2, tripId);
                updateStmt.executeUpdate();
            }

            String requestUrl = request.getRequestURL().toString();
            String baseUrl = requestUrl.substring(0, requestUrl.lastIndexOf("/ShareTripServlet"));

            json.put("success", true);
            json.put("url", baseUrl + "/public-trip.jsp?token=" + token);
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Something went wrong: " + e.getMessage());
            out.print(json.toString());
        }
    }
}
