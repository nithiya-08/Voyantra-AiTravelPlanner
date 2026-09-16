<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    // ---- Step 1: Check the user is logged in ----
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);

    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard — Voyantra</title>
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

  header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 6vw; border-bottom: 1px solid var(--line);
  }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand-mark { width: 28px; height: 28px; }
  .brand-word { font-family: 'Fraunces', serif; font-weight: 600; font-size: 1.15rem; }
  .brand-word .accent { color: var(--gold); font-weight: 500; font-style: italic; }
  .header-right { display: flex; align-items: center; gap: 16px; }
  .greeting { font-size: 0.88rem; color: var(--muted); }
  .greeting strong { color: var(--paper); }
  .btn {
    display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border-radius: 999px;
    font-weight: 600; font-size: 0.86rem; cursor: pointer; border: none;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }
  .btn-primary { background: var(--gold); color: var(--ink); }
  .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 22px rgba(231,169,76,0.3); }
  .btn-ghost { border: 1px solid var(--line-strong); color: var(--paper); }
  .btn-ghost:hover { border-color: var(--paper); }

  main { max-width: 1000px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  .page-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 34px; flex-wrap: wrap; gap: 16px; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; }
  .page-head p { color: var(--muted); font-size: 0.92rem; margin-top: 6px; }

  .trip-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
  .trip-card {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px;
    padding: 22px; transition: border-color 0.2s ease, transform 0.2s ease; position: relative;
  }
  .trip-card:hover { border-color: rgba(231,169,76,0.35); transform: translateY(-3px); }
  .trip-card h3 { font-family: 'Fraunces', serif; font-size: 1.25rem; margin-bottom: 12px; }
  .trip-meta { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
  .trip-tag {
    font-size: 0.76rem; font-weight: 600; padding: 5px 11px; border-radius: 999px;
    background: var(--gold-soft); color: var(--gold);
  }
  .trip-tag.shared { background: rgba(79,195,176,0.14); color: var(--teal); }
  .trip-tag.countdown { background: rgba(226,112,79,0.14); color: var(--coral); }
  .trip-interests { font-size: 0.84rem; color: var(--muted); margin-bottom: 18px; }
  .trip-actions { display: flex; gap: 10px; }
  .trip-actions a, .trip-actions button {
    flex: 1; text-align: center; padding: 9px; border-radius: 8px; font-size: 0.82rem; font-weight: 600;
    border: 1px solid var(--line-strong); background: transparent; color: var(--paper); cursor: pointer;
    transition: all 0.2s ease;
  }
  .trip-actions a:hover { border-color: var(--teal); color: var(--teal); }
  .trip-actions .delete-btn:hover { border-color: var(--coral); color: var(--coral); }

  .empty-state {
    text-align: center; padding: 60px 20px; background: var(--ink-2);
    border: 1px dashed var(--line-strong); border-radius: 16px;
  }
  .empty-state p { color: var(--muted); margin-bottom: 20px; }

  @media (max-width: 600px) {
    header { padding: 14px 5vw; }
    .greeting { display: none; }
  }
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
  <div class="header-right">
    <span class="greeting">Hi, <strong><%= userName %></strong></span>
    <% if (isAdmin) { %>
    <a href="admin-dashboard.jsp" class="btn btn-ghost" data-i18n="nav_admin">Admin</a>
    <% } %>
    <a href="LogoutServlet" class="btn btn-ghost" data-i18n="nav_logout">Log out</a>
  </div>
</header>

<main>
  <div class="page-head">
    <div>
      <h1 data-i18n="dashboard_heading">Your trips</h1>
      <p data-i18n="dashboard_sub">Every trip you've planned, in one place.</p>
    </div>
    <a href="trip-form.html" class="btn btn-primary" data-i18n="dashboard_newtrip">+ New trip</a>
  </div>

  <%
      ArrayList<Object[]> trips = new ArrayList<>();
      try (Connection conn = DBConnection.getConnection()) {
          if (conn != null) {
              String sql = "SELECT t.trip_id, t.destination, t.budget, t.num_days, t.travel_style, t.interests, "
                         + "(t.user_id != ?) AS is_shared, t.start_date "
                         + "FROM trips t LEFT JOIN trip_collaborators c ON t.trip_id = c.trip_id "
                         + "WHERE t.user_id = ? OR c.user_id = ? "
                         + "ORDER BY t.trip_id DESC";
              PreparedStatement stmt = conn.prepareStatement(sql);
              stmt.setInt(1, userId);
              stmt.setInt(2, userId);
              stmt.setInt(3, userId);
              ResultSet rs = stmt.executeQuery();
              while (rs.next()) {
                  trips.add(new Object[] {
                      rs.getInt("trip_id"),
                      rs.getString("destination"),
                      rs.getDouble("budget"),
                      rs.getInt("num_days"),
                      rs.getString("travel_style"),
                      rs.getString("interests"),
                      rs.getBoolean("is_shared"),
                      rs.getDate("start_date")
                  });
              }
          }
      } catch (Exception e) {
          e.printStackTrace();
      }
  %>

  <% if (trips.isEmpty()) { %>
      <div class="empty-state">
          <p data-i18n="dashboard_empty">You haven't planned any trips yet.</p>
          <a href="trip-form.html" class="btn btn-primary" data-i18n="dashboard_empty_cta">Plan your first trip →</a>
      </div>
  <% } else { %>
      <div class="trip-grid">
      <% for (Object[] trip : trips) {
          int tripId = (int) trip[0];
          String destination = (String) trip[1];
          double budget = (double) trip[2];
          int numDays = (int) trip[3];
          String travelStyle = (String) trip[4];
          String interests = (String) trip[5];
          boolean isShared = (boolean) trip[6];
          java.sql.Date tStartDate = (java.sql.Date) trip[7];
          Long daysUntil = null;
          if (tStartDate != null) {
              long diffMs = tStartDate.getTime() - new java.util.Date().getTime();
              daysUntil = diffMs / (1000L * 60 * 60 * 24);
          }
      %>
          <div class="trip-card">
              <h3><%= destination %></h3>
              <div class="trip-meta">
                  <span class="trip-tag"><%= numDays %> days</span>
                  <span class="trip-tag">₹<%= (int) budget %></span>
                  <span class="trip-tag"><%= travelStyle %></span>
                  <% if (isShared) { %><span class="trip-tag shared" data-i18n="dashboard_shared_badge">Shared with you</span><% } %>
                  <% if (daysUntil != null && daysUntil >= 0) { %>
                      <span class="trip-tag countdown"><%= daysUntil == 0 ? "Today!" : daysUntil + " days to go" %></span>
                  <% } %>
              </div>
              <div class="trip-interests"><%= interests %></div>
              <div class="trip-actions">
                  <a href="trip-details.jsp?tripId=<%= tripId %>" data-i18n="dashboard_view">View</a>
                  <% if (!isShared) { %>
                  <a href="edit-trip.jsp?tripId=<%= tripId %>" data-i18n="dashboard_edit">Edit</a>
                  <form action="DeleteTripServlet" method="POST" style="flex:1; margin:0;">
                      <input type="hidden" name="tripId" value="<%= tripId %>">
                      <button type="submit" class="delete-btn" style="width:100%;" data-i18n="dashboard_delete"
                              onclick="return confirm('Delete this trip?');">Delete</button>
                  </form>
                  <% } %>
              </div>
          </div>
      <% } %>
      </div>
  <% } %>
</main>

<script src="js/i18n.js?v=3"></script>
<script src="js/chatbot.js?v=3"></script>
</body>
</html>
