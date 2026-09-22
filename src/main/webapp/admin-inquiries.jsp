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

    ArrayList<Object[]> inquiries = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT v.business_name, u.name, u.email, i.message, i.created_at, i.status "
                       + "FROM vendor_inquiries i JOIN vendors v ON i.vendor_id = v.vendor_id "
                       + "JOIN users u ON i.user_id = u.user_id ORDER BY i.inquiry_id DESC LIMIT 100";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                inquiries.add(new Object[] {
                    rs.getString("business_name"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("message"),
                    rs.getTimestamp("created_at"),
                    rs.getString("status")
                });
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
<title>All inquiries — Voyantra</title>
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
  .inquiry-row { background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px; padding: 18px 20px; margin-bottom: 10px; }
  .inquiry-row .top { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; flex-wrap: wrap; gap: 8px; }
  .inquiry-row .name { font-weight: 700; }
  .inquiry-row .meta { font-size: 0.78rem; color: var(--muted); }
  .inquiry-row .msg { font-size: 0.9rem; margin-bottom: 6px; }
  .status-badge { font-size: 0.74rem; font-weight: 700; padding: 4px 10px; border-radius: 999px; }
  .status-new { background: rgba(231,169,76,0.14); color: var(--gold); }
  .status-accepted { background: rgba(79,195,176,0.14); color: var(--teal); }
  .status-declined { background: rgba(226,112,79,0.14); color: var(--coral); }
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
  <a href="admin-dashboard.jsp" class="back-link">&larr; Admin dashboard</a>
</header>

<main>
  <h1>All inquiries</h1>
  <p class="sub">Every booking request sent across the platform (most recent 100).</p>

  <% if (inquiries.isEmpty()) { %>
    <p class="empty-state">No inquiries yet.</p>
  <% } else { for (Object[] inq : inquiries) {
      String status = (String) inq[5];
      String statusClass = "ACCEPTED".equals(status) ? "status-accepted" : ("DECLINED".equals(status) ? "status-declined" : "status-new");
  %>
    <div class="inquiry-row">
      <div class="top">
        <span class="name"><%= inq[0] %> &larr; <%= inq[1] %></span>
        <span class="status-badge <%= statusClass %>"><%= status %></span>
      </div>
      <div class="msg"><%= inq[3] %></div>
      <div class="meta"><%= inq[2] %> &middot; <%= inq[4] %></div>
    </div>
  <% } } %>
</main>

</body>
</html>
