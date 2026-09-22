package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import com.voyantra.ai.EmailService;
import com.voyantra.db.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

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

            String sql = "SELECT user_id, name, password, is_verified, is_admin, is_vendor FROM users WHERE email = ?";
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

            boolean isVerified = rs.getBoolean("is_verified");
            if (!isVerified) {
                String otp = generateOtp();
                String updateSql = "UPDATE users SET otp_code = ? WHERE email = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, otp);
                updateStmt.setString(2, email);
                updateStmt.executeUpdate();

                try {
                    EmailService.sendOtpEmail(email, otp);
                } catch (Exception mailError) {
                    mailError.printStackTrace();
                    fail(out, "Could not send verification email: " + mailError.getMessage());
                    return;
                }

                JSONObject json = new JSONObject();
                json.put("success", true);
                json.put("redirect", "verify-otp.html?email=" + java.net.URLEncoder.encode(email, "UTF-8"));
                out.print(json.toString());
                return;
            }

            int userId = rs.getInt("user_id");
            String userName = rs.getString("name");
            boolean isAdmin = rs.getBoolean("is_admin");
            boolean isVendor = rs.getBoolean("is_vendor");

            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);
            session.setAttribute("isAdmin", isAdmin);
            session.setAttribute("isVendor", isVendor);

            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("redirect", isAdmin ? "admin-dashboard.jsp" : "dashboard.jsp");
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

    private String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
