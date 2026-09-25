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

    ArrayList<Object[]> users = new ArrayList<>();
    java.util.Map<Integer, Integer> tripCounts = new java.util.HashMap<>();
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT user_id, name, email, is_admin, is_vendor, is_blocked FROM users ORDER BY user_id DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                users.add(new Object[] {
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getBoolean("is_admin"),
                    rs.getBoolean("is_vendor"),
                    rs.getBoolean("is_blocked")
                });
            }

            Statement tripSt = conn.createStatement();
            ResultSet tripRs = tripSt.executeQuery("SELECT user_id, COUNT(*) c FROM trips GROUP BY user_id");
            while (tripRs.next()) {
                tripCounts.put(tripRs.getInt("user_id"), tripRs.getInt("c"));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Users — Voyantra</title>
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
  .user-row {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px;
    padding: 16px 20px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;
  }
  .user-row .name { font-weight: 700; }
  .user-row .meta { font-size: 0.8rem; color: var(--muted); }
  .trip-tag { font-size: 0.74rem; font-weight: 600; padding: 4px 10px; border-radius: 999px; background: var(--gold-soft); color: var(--gold); margin-right: 6px; }
  .trip-tag.blocked { background: rgba(226,112,79,0.14); color: var(--coral); }
  .user-row button {
    padding: 9px 16px; border-radius: 8px; border: 1px solid var(--line-strong); background: transparent;
    color: var(--paper); font-weight: 600; font-size: 0.82rem; cursor: pointer;
  }
  .user-row button.block:hover { border-color: var(--coral); color: var(--coral); }
  .user-row button.unblock:hover { border-color: var(--teal); color: var(--teal); }
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
  <a href="admin-dashboard.jsp" class="back-link" data-i18n="adminusers_backdash">&larr; Admin dashboard</a>
</header>

<main>
  <h1 data-i18n="adminusers_heading">Users</h1>
  <p class="sub" data-i18n="adminusers_sub">See how many trips each tourist has planned, block or unblock accounts.</p>

  <% for (Object[] u : users) {
      int rowUserId = (int) u[0];
      boolean rowIsAdmin = (boolean) u[3];
      boolean rowIsVendor = (boolean) u[4];
      boolean rowIsBlocked = (boolean) u[5];
      int rowTripCount = tripCounts.containsKey(rowUserId) ? tripCounts.get(rowUserId) : 0;
  %>
    <div class="user-row">
      <div>
        <div class="name"><%= u[1] %></div>
        <div class="meta"><%= u[2] %></div>
        <div style="margin-top:8px;">
          <% if (rowIsAdmin) { %><span class="trip-tag" data-i18n="adminusers_admin_badge">Admin</span><% } %>
          <% if (rowIsVendor) { %><span class="trip-tag" data-i18n="adminusers_vendor_badge">Vendor</span><% } %>
          <% if (rowIsBlocked) { %><span class="trip-tag blocked" data-i18n="adminusers_blocked_badge">Blocked</span><% } %>
          <span class="trip-tag"><%= rowTripCount %> <span data-i18n="admindash_trips_word">trips</span> <span data-i18n="adminusers_planned">planned</span></span>
        </div>
      </div>
      <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
        <% if (rowTripCount > 0) { %>
        <a href="admin-user-trips.jsp?userId=<%= rowUserId %>" style="border:1px solid var(--line-strong); padding:9px 16px; border-radius:8px; font-size:0.82rem; font-weight:600;" data-i18n="adminusers_viewtrips">View trips</a>
        <% } %>
        <% if (!rowIsAdmin) { %>
        <form action="AdminToggleUserBlockServlet" method="POST" style="margin:0;">
          <input type="hidden" name="userId" value="<%= rowUserId %>">
          <input type="hidden" name="action" value="<%= rowIsBlocked ? "UNBLOCK" : "BLOCK" %>">
          <button type="submit" class="<%= rowIsBlocked ? "unblock" : "block" %>" data-i18n="<%= rowIsBlocked ? "adminusers_unblock" : "adminusers_block" %>"><%= rowIsBlocked ? "Unblock" : "Block" %></button>
        </form>
        <% } %>
      </div>
    </div>
  <% } %>
</main>

<script src="js/i18n.js?v=5"></script>
</body>
</html>
