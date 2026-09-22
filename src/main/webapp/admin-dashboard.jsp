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

    int totalUsers = 0, verifiedUsers = 0, totalTrips = 0, totalItineraryDays = 0, pendingVendors = 0, openReports = 0, blockedUsers = 0;
    double avgBudget = 0;
    double avgDays = 0;
    ArrayList<Object[]> topDestinations = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            try (Statement st = conn.createStatement()) {
                ResultSet r1 = st.executeQuery("SELECT COUNT(*) c FROM users");
                if (r1.next()) totalUsers = r1.getInt("c");

                ResultSet r2 = st.executeQuery("SELECT COUNT(*) c FROM users WHERE is_verified = TRUE");
                if (r2.next()) verifiedUsers = r2.getInt("c");

                ResultSet r3 = st.executeQuery("SELECT COUNT(*) c, AVG(budget) b, AVG(num_days) d FROM trips");
                if (r3.next()) {
                    totalTrips = r3.getInt("c");
                    avgBudget = r3.getDouble("b");
                    avgDays = r3.getDouble("d");
                }

                ResultSet r4 = st.executeQuery("SELECT COUNT(*) c FROM itineraries");
                if (r4.next()) totalItineraryDays = r4.getInt("c");

                ResultSet r4b = st.executeQuery("SELECT COUNT(*) c FROM vendors WHERE status = 'PENDING'");
                if (r4b.next()) pendingVendors = r4b.getInt("c");

                ResultSet r4c = st.executeQuery("SELECT COUNT(*) c FROM vendor_reports WHERE status = 'OPEN'");
                if (r4c.next()) openReports = r4c.getInt("c");

                ResultSet r4d = st.executeQuery("SELECT COUNT(*) c FROM users WHERE is_blocked = TRUE");
                if (r4d.next()) blockedUsers = r4d.getInt("c");

                ResultSet r5 = st.executeQuery(
                    "SELECT destination, COUNT(*) cnt FROM trips GROUP BY destination ORDER BY cnt DESC LIMIT 5");
                while (r5.next()) {
                    topDestinations.add(new Object[]{ r5.getString("destination"), r5.getInt("cnt") });
                }
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
<title>Admin — Voyantra</title>
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
  main { max-width: 1000px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; margin-bottom: 8px; }
  .sub { color: var(--muted); margin-bottom: 34px; }
  .stat-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 18px; margin-bottom: 40px; }
  .stat { background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px; padding: 20px; }
  .stat .num { font-family: 'Fraunces', serif; font-size: 1.8rem; color: var(--gold); }
  .stat .lbl { font-size: 0.8rem; color: var(--muted); margin-top: 4px; }
  .section-title { font-family: 'Fraunces', serif; font-size: 1.3rem; margin-bottom: 16px; }
  .dest-row { display: flex; justify-content: space-between; padding: 12px 16px; background: var(--ink-2); border: 1px solid var(--line); border-radius: 10px; margin-bottom: 8px; font-size: 0.9rem; }
  .dest-row .cnt { color: var(--gold); font-weight: 700; }
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
  <a href="dashboard.jsp" class="back-link">My trips &rarr;</a>
</header>

<main>
  <h1>Admin dashboard</h1>
  <p class="sub">Usage across all Voyantra users. <a href="admin-vendors.jsp" style="color:var(--gold);">Review vendor approvals &rarr;</a> &nbsp; <a href="admin-users.jsp" style="color:var(--gold);">Manage users &rarr;</a></p>

  <div class="stat-grid">
    <div class="stat"><div class="num"><%= totalUsers %></div><div class="lbl">Total users</div></div>
    <div class="stat"><div class="num"><%= verifiedUsers %></div><div class="lbl">Verified users</div></div>
    <div class="stat"><div class="num"><%= totalTrips %></div><div class="lbl">Total trips</div></div>
    <div class="stat"><div class="num"><%= totalItineraryDays %></div><div class="lbl">Itinerary days generated</div></div>
    <div class="stat"><div class="num">Rs. <%= Math.round(avgBudget) %></div><div class="lbl">Average budget</div></div>
    <div class="stat"><div class="num"><%= Math.round(avgDays * 10.0) / 10.0 %></div><div class="lbl">Average trip length (days)</div></div>
    <div class="stat"><div class="num"><%= pendingVendors %></div><div class="lbl">Pending vendor approvals</div></div>
    <div class="stat"><div class="num"><%= openReports %></div><div class="lbl">Open vendor reports</div></div>
    <div class="stat"><div class="num"><%= blockedUsers %></div><div class="lbl">Blocked users</div></div>
  </div>

  <div class="section-title">Top destinations</div>
  <% if (topDestinations.isEmpty()) { %>
    <p class="sub">No trips yet.</p>
  <% } else { for (Object[] d : topDestinations) { %>
    <div class="dest-row"><span><%= d[0] %></span><span class="cnt"><%= d[1] %> trips</span></div>
  <% } } %>
</main>

</body>
</html>
