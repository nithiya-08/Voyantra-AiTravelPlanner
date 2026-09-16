package com.voyantra.servlet;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
 
import com.voyantra.db.DBConnection;
 
@WebServlet("/DeleteTripServlet")
public class DeleteTripServlet  extends HttpServlet {
	   private static final long serialVersionUID = 1L;
	   
	    protected void doPost(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {
	 
	        // ---- Step 1: Must be logged in ----
	        HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("userId") == null) {
	            response.sendRedirect("login.html");
	            return;
	        }
	        int userId = (int) session.getAttribute("userId");
	 
	        // ---- Step 2: Read which trip to delete ----
	        String tripIdStr = request.getParameter("tripId");
	        if (tripIdStr == null) {
	            response.sendRedirect("dashboard.jsp");
	            return;
	        }
	        int tripId = Integer.parseInt(tripIdStr);
	 
	        // ---- Step 3: Delete only if it belongs to the logged-in user ----
	        // (the "AND user_id = ?" check stops one user deleting another user's trip)
	        try (Connection conn = DBConnection.getConnection()) {
	            if (conn != null) {
	                String sql = "DELETE FROM trips WHERE trip_id = ? AND user_id = ?";
	                PreparedStatement stmt = conn.prepareStatement(sql);
	                stmt.setInt(1, tripId);
	                stmt.setInt(2, userId);
	                stmt.executeUpdate();
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	 
	        // ---- Step 4: Go back to the dashboard ----
	        response.sendRedirect("dashboard.jsp");
	    }

}
