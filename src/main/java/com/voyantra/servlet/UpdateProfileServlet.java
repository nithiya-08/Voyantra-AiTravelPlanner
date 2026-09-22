package com.voyantra.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.db.DBConnection;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");

        if (name == null || name.trim().isEmpty() ||
            phone == null || !phone.matches("^[6-9][0-9]{9}$")) {
            response.sendRedirect("profile.jsp?profileError=1");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE users SET name = ?, phone = ? WHERE user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, name);
                stmt.setString(2, phone);
                stmt.setInt(3, userId);
                stmt.executeUpdate();
                session.setAttribute("userName", name);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?profileError=1");
            return;
        }

        response.sendRedirect("profile.jsp?profileSuccess=1");
    }
}
