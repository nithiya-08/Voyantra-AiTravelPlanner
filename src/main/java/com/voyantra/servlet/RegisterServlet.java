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

import org.json.JSONObject;

import com.voyantra.ai.EmailService;
import com.voyantra.db.DBConnection;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");

        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            password == null || password.length() < 8) {
            fail(out, "Please fill all fields correctly (password must be at least 8 characters).");
            return;
        }

        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            fail(out, "Please enter a valid email address.");
            return;
        }

        if (!phone.matches("^[6-9][0-9]{9}$")) {
            fail(out, "Please enter a valid 10-digit phone number.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                fail(out, "Database connection failed.");
                return;
            }

            String checkSql = "SELECT user_id FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                fail(out, "An account with this email already exists. Try logging in instead.");
                return;
            }

            String hashedPassword = hashPassword(password);
            String otp = generateOtp();

            String insertSql = "INSERT INTO users (name, email, phone, password, otp_code, is_verified) "
                              + "VALUES (?, ?, ?, ?, ?, FALSE)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, name);
            insertStmt.setString(2, email);
            insertStmt.setString(3, phone);
            insertStmt.setString(4, hashedPassword);
            insertStmt.setString(5, otp);

            int rows = insertStmt.executeUpdate();

            if (rows > 0) {
                try {
                    EmailService.sendOtpEmail(email, otp);
                } catch (Exception mailError) {
                    mailError.printStackTrace();
                    fail(out, "Account created, but the verification email failed to send: " + mailError.getMessage());
                    return;
                }

                JSONObject json = new JSONObject();
                json.put("success", true);
                json.put("redirect", "verify-otp.html?email=" + java.net.URLEncoder.encode(email, "UTF-8"));
                out.print(json.toString());
            } else {
                fail(out, "Registration failed. Please try again.");
            }

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
