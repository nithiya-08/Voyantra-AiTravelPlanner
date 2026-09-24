package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
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

@WebServlet("/ResendOtpServlet")
public class ResendOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            fail(out, "Missing email. Please try registering again.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                fail(out, "Database connection failed.");
                return;
            }

            String selectSql = "SELECT user_id, is_verified FROM users WHERE email = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setString(1, email);
            ResultSet rs = selectStmt.executeQuery();

            if (!rs.next()) {
                fail(out, "No account found for this email.");
                return;
            }

            if (rs.getBoolean("is_verified")) {
                fail(out, "This account is already verified — please log in.");
                return;
            }

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
                fail(out, "Could not send the email: " + mailError.getMessage());
                return;
            }

            JSONObject json = new JSONObject();
            json.put("success", true);
            json.put("message", "A new code has been sent.");
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

    private String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
