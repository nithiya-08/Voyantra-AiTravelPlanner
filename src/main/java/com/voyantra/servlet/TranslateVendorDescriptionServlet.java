package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import com.voyantra.ai.GeminiClient;
import com.voyantra.db.DBConnection;

/**
 * On-demand AI translation of a vendor's description, into whichever
 * language the tourist already has the site set to (see js/i18n.js). Only
 * the free-text description is translated — names/addresses/phone numbers
 * stay as-is since translating those could make a real business
 * unfindable.
 */
@WebServlet("/TranslateVendorDescriptionServlet")
public class TranslateVendorDescriptionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Map<String, String> LANGUAGE_NAMES = new HashMap<>();
    static {
        LANGUAGE_NAMES.put("ta", "Tamil");
        LANGUAGE_NAMES.put("hi", "Hindi");
        LANGUAGE_NAMES.put("fr", "French");
        LANGUAGE_NAMES.put("de", "German");
        LANGUAGE_NAMES.put("es", "Spanish");
    }
    private static final Set<String> VALID_LANGS = new HashSet<>(Arrays.asList("ta", "hi", "fr", "de", "es"));

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            fail(out, "Please log in.");
            return;
        }

        String vendorIdStr = request.getParameter("vendorId");
        String lang = request.getParameter("lang");
        if (vendorIdStr == null || lang == null || !VALID_LANGS.contains(lang)) {
            fail(out, "Unsupported language.");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                fail(out, "Database connection failed.");
                return;
            }

            String sql = "SELECT description FROM vendors WHERE vendor_id = ? AND status = 'APPROVED'";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, vendorId);
            ResultSet rs = stmt.executeQuery();
            if (!rs.next() || rs.getString("description") == null || rs.getString("description").trim().isEmpty()) {
                fail(out, "Nothing to translate.");
                return;
            }
            String description = rs.getString("description");

            String prompt = "Translate the following business description into " + LANGUAGE_NAMES.get(lang)
                + ". Respond with ONLY the translated text, no notes, no quotes, no explanation.\n\n" + description;
            String translated = GeminiClient.generateRaw(prompt);

            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("translated", translated);
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            fail(out, "Translation failed. Please try again.");
        }
    }

    private void fail(PrintWriter out, String message) {
        JSONObject json = new JSONObject();
        json.put("success", false);
        json.put("message", message);
        out.print(json.toString());
    }
}
