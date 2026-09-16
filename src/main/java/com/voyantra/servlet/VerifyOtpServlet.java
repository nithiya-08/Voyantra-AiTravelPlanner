package com.voyantra.servlet;

import java.io.IOException;
import java.io.PrintWriter;
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

@WebServlet("/VerifyOtpServlet")
public class VerifyOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String email = request.getParameter("email");
        String enteredOtp = request.getParameter("otp");

        if (email == null || enteredOtp == null || enteredOtp.trim().isEmpty()) {
            fail(out, "Missing information. Please try registering again.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            if (conn == null) {
                fail(out, "Database connection failed.");
                return;
            }

            String selectSql = "SELECT user_id, name, otp_code, is_admin FROM users WHERE email = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setString(1, email);
            ResultSet rs = selectStmt.executeQuery();

            if (!rs.next()) {
                fail(out, "No account found for this email.");
                return;
            }

            String storedOtp = rs.getString("otp_code");
            int userId = rs.getInt("user_id");
            String userName = rs.getString("name");

            if (storedOtp == null || !storedOtp.equals(enteredOtp.trim())) {
                fail(out, "The code you entered doesn't match. Please check your email and try again.");
                return;
            }

            String updateSql = "UPDATE users SET is_verified = TRUE, otp_code = NULL WHERE email = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, email);
            updateStmt.executeUpdate();

            boolean isAdmin = rs.getBoolean("is_admin");

            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);
            session.setAttribute("isAdmin", isAdmin);

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
}
