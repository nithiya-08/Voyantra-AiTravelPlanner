package com.voyantra.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
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

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");

        if (currentPassword == null || currentPassword.isEmpty() ||
            newPassword == null || newPassword.length() < 8) {
            response.sendRedirect("profile.jsp?pwError=weak");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String checkSql = "SELECT password FROM users WHERE user_id = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, userId);
                ResultSet rs = checkStmt.executeQuery();
                if (!rs.next() || !rs.getString("password").equals(hashPassword(currentPassword))) {
                    response.sendRedirect("profile.jsp?pwError=wrong");
                    return;
                }

                String updateSql = "UPDATE users SET password = ? WHERE user_id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, hashPassword(newPassword));
                updateStmt.setInt(2, userId);
                updateStmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?pwError=wrong");
            return;
        }

        response.sendRedirect("profile.jsp?pwSuccess=1");
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
