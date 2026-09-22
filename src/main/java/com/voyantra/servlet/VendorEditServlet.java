package com.voyantra.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.voyantra.db.DBConnection;

@WebServlet("/VendorEditServlet")
public class VendorEditServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Set<String> VALID_CATEGORIES = new HashSet<>(Arrays.asList(
        "HOTEL", "HOMESTAY", "GUIDE", "TRANSPORT", "ACTIVITY", "RESTAURANT"));

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.html");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        String vendorIdStr = request.getParameter("vendorId");
        if (vendorIdStr == null) {
            response.sendRedirect("my-vendor-listings.jsp");
            return;
        }
        int vendorId = Integer.parseInt(vendorIdStr);

        String businessName = request.getParameter("businessName");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String priceRange = request.getParameter("priceRange");
        String photoUrl = request.getParameter("photoUrl");

        if (businessName == null || businessName.trim().isEmpty() ||
            category == null || !VALID_CATEGORIES.contains(category) ||
            city == null || city.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {
            response.sendRedirect("vendor-form.jsp?vendorId=" + vendorId);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "UPDATE vendors SET business_name = ?, category = ?, description = ?, city = ?, "
                    + "state = ?, address = ?, phone = ?, email = ?, price_range = ?, photo_url = ? "
                    + "WHERE vendor_id = ? AND user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, businessName);
                stmt.setString(2, category);
                stmt.setString(3, description);
                stmt.setString(4, city);
                stmt.setString(5, state);
                stmt.setString(6, address);
                stmt.setString(7, phone);
                stmt.setString(8, email);
                stmt.setString(9, priceRange);
                stmt.setString(10, photoUrl);
                stmt.setInt(11, vendorId);
                stmt.setInt(12, userId);
                stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("my-vendor-listings.jsp");
    }
}
