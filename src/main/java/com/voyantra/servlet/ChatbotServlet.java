package com.voyantra.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import com.voyantra.ai.GeminiClient;
import com.voyantra.db.DBConnection;

@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        StringBuilder bodyBuilder = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) bodyBuilder.append(line);
        }

        JSONObject reply = new JSONObject();
        try {
            JSONObject body = new JSONObject(bodyBuilder.toString());
            String message = body.optString("message", "").trim();
            String tripIdStr = body.optString("tripId", "").trim();

            if (message.isEmpty()) {
                reply.put("reply", "Ask me anything about planning your trip, or about how Voyantra works!");
                out.print(reply.toString());
                return;
            }

            StringBuilder prompt = new StringBuilder();
            prompt.append("You are the helpful in-app assistant for Voyantra, an AI travel planning website. ");
            prompt.append("Voyantra lets users enter a budget, number of days, travel style and interests, and ");
            prompt.append("generates a complete day-wise itinerary (activities, food, stay, weather) using AI. ");
            prompt.append("Users can save trips, edit them, download a PDF, see destination photos/videos, log expenses, ");
            prompt.append("share a trip via a public link, and invite collaborators. ");
            prompt.append("Answer the user's question conversationally, in 2-4 short sentences unless more detail is truly needed. ");
            prompt.append("If asked about a specific trip and trip details are provided below, use them. ");
            prompt.append("If you don't know something about the site, say so briefly rather than inventing details.\n\n");

            if (!tripIdStr.isEmpty()) {
                appendTripContext(request, prompt, tripIdStr);
            }

            JSONArray history = body.optJSONArray("history");
            if (history != null && history.length() > 0) {
                prompt.append("Recent conversation:\n");
                for (int i = 0; i < history.length(); i++) {
                    JSONObject turn = history.getJSONObject(i);
                    String role = turn.optString("role", "user");
                    String text = turn.optString("text", "");
                    prompt.append(role.equals("user") ? "User: " : "Assistant: ").append(text).append("\n");
                }
                prompt.append("\n");
            }

            prompt.append("User's new message: ").append(message);

            String aiReply = GeminiClient.generateRaw(prompt.toString());
            reply.put("reply", aiReply);

        } catch (Exception e) {
            e.printStackTrace();
            reply.put("reply", "Sorry, I couldn't get a response just now. Please try again in a moment.");
        }

        out.print(reply.toString());
    }

    private void appendTripContext(HttpServletRequest request, StringBuilder prompt, String tripIdStr) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) return;
            int userId = (int) session.getAttribute("userId");
            int tripId = Integer.parseInt(tripIdStr);

            try (Connection conn = DBConnection.getConnection()) {
                if (conn == null) return;

                String tripSql = "SELECT destination, budget, num_days, travel_style, interests FROM trips "
                    + "WHERE trip_id = ? AND (user_id = ? OR trip_id IN "
                    + "(SELECT trip_id FROM trip_collaborators WHERE user_id = ?))";
                PreparedStatement tripStmt = conn.prepareStatement(tripSql);
                tripStmt.setInt(1, tripId);
                tripStmt.setInt(2, userId);
                tripStmt.setInt(3, userId);
                ResultSet tripRs = tripStmt.executeQuery();

                if (!tripRs.next()) return;

                prompt.append("This trip: ").append(tripRs.getString("destination"))
                    .append(", budget Rs ").append((int) tripRs.getDouble("budget"))
                    .append(", ").append(tripRs.getInt("num_days")).append(" days, style ")
                    .append(tripRs.getString("travel_style")).append(", interests ")
                    .append(tripRs.getString("interests")).append(".\n");

                String itinSql = "SELECT day_number, activities, food_suggestions, hotel_suggestion "
                    + "FROM itineraries WHERE trip_id = ? ORDER BY day_number ASC";
                PreparedStatement itinStmt = conn.prepareStatement(itinSql);
                itinStmt.setInt(1, tripId);
                ResultSet itinRs = itinStmt.executeQuery();
                while (itinRs.next()) {
                    prompt.append("Day ").append(itinRs.getInt("day_number")).append(": activities: ")
                        .append(itinRs.getString("activities")).append("; food: ")
                        .append(itinRs.getString("food_suggestions")).append("; stay: ")
                        .append(itinRs.getString("hotel_suggestion")).append(".\n");
                }
                prompt.append("\n");
            }
        } catch (Exception e) {
            // Trip context is a nice-to-have; if it fails, just answer without it.
        }
    }
}
