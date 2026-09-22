package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import com.voyantra.db.DBConnection;

/**
 * Same credential check as LoginServlet, but only ever succeeds for an
 * account with is_admin = 1 — used by admin-login.html so a regular
 * tourist/vendor account can never end up in the admin area from there.
 */
@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            fail(out, "Please enter both email and password.");
            return;
        }

        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            fail(out, "Please enter a valid email address.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                fail(out, "Database connection failed.");
                return;
            }

            String sql = "SELECT user_id, name, password, is_admin, is_blocked FROM users WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (!rs.next()) {
                fail(out, "Invalid email or password.");
                return;
            }

            String storedHash = rs.getString("password");
            String enteredHash = hashPassword(password);

            if (!storedHash.equals(enteredHash)) {
                fail(out, "Invalid email or password.");
                return;
            }

            if (rs.getBoolean("is_blocked")) {
                fail(out, "Your account has been blocked. Contact support.");
                return;
            }

            if (!rs.getBoolean("is_admin")) {
                fail(out, "This login is for administrators only.");
                return;
            }

            int userId = rs.getInt("user_id");
            String userName = rs.getString("name");

            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);
            session.setAttribute("isAdmin", true);
            session.setAttribute("isVendor", false);

            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("redirect", "admin-dashboard.jsp");
            out.print(json.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            fail(out, "Something went wrong: " + e.getMessage());
        }
    }

    private void fail(PrintWriter out, String message) {
        JSONObject json = new JSONObject();
        json.put("success", false);
        json.put("message", message);
        out.print(json.toString());
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return password;
        }
    }
}
