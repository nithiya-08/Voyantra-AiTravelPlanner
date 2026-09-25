<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%@ page import="java.util.ArrayList" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
    if (isAdminAttr == null || !isAdminAttr) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String targetUserIdStr = request.getParameter("userId");
    if (targetUserIdStr == null) {
        response.sendRedirect("admin-users.jsp");
        return;
    }
    int targetUserId = Integer.parseInt(targetUserIdStr);

    String targetName = null;
    String targetEmail = null;
    ArrayList<Object[]> trips = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            PreparedStatement userStmt = conn.prepareStatement("SELECT name, email FROM users WHERE user_id = ?");
            userStmt.setInt(1, targetUserId);
            ResultSet userRs = userStmt.executeQuery();
            if (userRs.next()) {
                targetName = userRs.getString("name");
                targetEmail = userRs.getString("email");
            }

            String sql = "SELECT trip_id, destination, budget, num_days, travel_style, start_date, created_at "
                       + "FROM trips WHERE user_id = ? ORDER BY created_at DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, targetUserId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                trips.add(new Object[] {
                    rs.getInt("trip_id"),
                    rs.getString("destination"),
                    rs.getDouble("budget"),
                    rs.getInt("num_days"),
                    rs.getString("travel_style"),
                    rs.getDate("start_date"),
                    rs.getTimestamp("created_at")
                });
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (targetName == null) {
        response.sendRedirect("admin-users.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= targetName %>'s trips — Voyantra Admin</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  :root {
    --ink: #0D1526; --ink-2: #131F38; --ink-3: #1B2A45;
    --paper: #F6F2E9; --gold: #E7A94C; --gold-soft: rgba(231,169,76,0.14);
    --coral: #E2704F; --teal: #4FC3B0;
    --line: rgba(246,242,233,0.14); --line-strong: rgba(246,242,233,0.28); --muted: rgba(246,242,233,0.6);
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: var(--ink); color: var(--paper); font-family: 'Inter', sans-serif; min-height: 100vh; }
  a { color: inherit; text-decoration: none; }
  header { display: flex; align-items: center; justify-content: space-between; padding: 18px 6vw; border-bottom: 1px solid var(--line); }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand-mark { width: 28px; height: 28px; }
  .brand-word { font-family: 'Fraunces', serif; font-weight: 600; font-size: 1.15rem; }
  .brand-word .accent { color: var(--gold); font-weight: 500; font-style: italic; }
  .back-link { font-size: 0.85rem; color: var(--muted); }
  .back-link:hover { color: var(--gold); }
  main { max-width: 900px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; margin-bottom: 8px; }
  .sub { color: var(--muted); margin-bottom: 34px; }
  .trip-row {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px;
    padding: 18px 20px; margin-bottom: 10px;
  }
  .trip-row .top { display: flex; justify-content: space-between; align-items: baseline; flex-wrap: wrap; gap: 8px; margin-bottom: 6px; }
  .trip-row .name { font-weight: 700; font-size: 1.02rem; }
  .trip-row .meta { font-size: 0.8rem; color: var(--muted); }
  .trip-row .view-link { display: inline-block; margin-top: 12px; font-size: 0.85rem; font-weight: 600; color: var(--gold); }
  .trip-row .view-link:hover { text-decoration: underline; }
  .empty-state { color: var(--muted); font-size: 0.9rem; }
</style>
</head>
<body>

<header>
  <a href="index.jsp" class="brand">
    <svg class="brand-mark" viewBox="0 0 40 40" fill="none">
      <circle cx="20" cy="20" r="18.5" stroke="#E7A94C" stroke-width="1.4" opacity="0.4"/>
      <path d="M20 5 L24.5 17.5 L20 20 L15.5 17.5 Z" fill="#E7A94C"/>
      <path d="M20 35 L15.5 22.5 L20 20 L24.5 22.5 Z" fill="#F6F2E9" opacity="0.85"/>
      <circle cx="20" cy="20" r="3" fill="#0D1526" stroke="#E7A94C" stroke-width="1.4"/>
    </svg>
    <span class="brand-word">Voy<span class="accent">antra</span></span>
  </a>
  <a href="admin-users.jsp" class="back-link" data-i18n="adminusertrips_back">&larr; All users</a>
</header>

<main>
  <h1><%= targetName %><span data-i18n="adminusertrips_possessive">'s trips</span></h1>
  <p class="sub"><%= targetEmail %> &middot; <%= trips.size() %> <span data-i18n="admindash_trips_word">trips</span> <span data-i18n="adminusers_planned">planned</span></p>

  <% if (trips.isEmpty()) { %>
    <p class="empty-state" data-i18n="adminusertrips_empty">No trips planned yet.</p>
  <% } else { for (Object[] t : trips) {
      int tripId = (int) t[0];
      double tripBudget = (double) t[2];
      int tripDays = (int) t[3];
      java.sql.Date tripStart = (java.sql.Date) t[5];
      java.sql.Timestamp tripCreated = (java.sql.Timestamp) t[6];
  %>
    <div class="trip-row">
      <div class="top">
        <span class="name"><%= t[1] %></span>
        <span class="meta"><span data-i18n="adminusertrips_plannedon">planned</span> <%= tripCreated %></span>
      </div>
      <div class="meta">
        <%= tripDays %> <span data-i18n="publictrip_days">days</span> &middot; Rs. <%= Math.round(tripBudget) %> <span data-i18n="adminusertrips_budget">budget</span>
        <% if (t[4] != null) { %> &middot; <%= t[4] %><% } %>
        <% if (tripStart != null) { %> &middot; <span data-i18n="adminusertrips_starts">starts</span> <%= tripStart %><% } %>
      </div>
      <a href="trip-details.jsp?tripId=<%= tripId %>" class="view-link" data-i18n="adminusertrips_viewfull">View full itinerary &rarr;</a>
    </div>
  <% } } %>
</main>

<script src="js/i18n.js?v=5"></script>
</body>
</html>
