<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    ArrayList<Object[]> inquiries = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT i.vendor_id, v.business_name, i.message, i.travel_dates, i.created_at, i.status "
                       + "FROM vendor_inquiries i JOIN vendors v ON i.vendor_id = v.vendor_id "
                       + "WHERE i.user_id = ? ORDER BY i.inquiry_id DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                inquiries.add(new Object[] {
                    rs.getInt("vendor_id"),
                    rs.getString("business_name"),
                    rs.getString("message"),
                    rs.getString("travel_dates"),
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
<title>My inquiries — Voyantra</title>
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
  .header-right { display: flex; align-items: center; gap: 16px; }
  .greeting { font-size: 0.88rem; color: var(--muted); }
  .greeting strong { color: var(--paper); }
  .btn { display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border-radius: 999px; font-weight: 600; font-size: 0.86rem; cursor: pointer; border: none; }
  .btn-ghost { border: 1px solid var(--line-strong); color: var(--paper); }
  .btn-ghost:hover { border-color: var(--paper); }
  main { max-width: 800px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; margin-bottom: 8px; }
  .sub { color: var(--muted); margin-bottom: 34px; }
  .inquiry-row { background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px; padding: 18px 20px; margin-bottom: 12px; }
  .inquiry-row .top { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; flex-wrap: wrap; gap: 8px; }
  .inquiry-row .name { font-weight: 700; }
  .inquiry-row .meta { font-size: 0.78rem; color: var(--muted); }
  .inquiry-row .msg { font-size: 0.9rem; margin-bottom: 8px; }
  .status-badge { font-size: 0.76rem; font-weight: 700; padding: 4px 10px; border-radius: 999px; }
  .status-new { background: rgba(231,169,76,0.14); color: var(--gold); }
  .status-accepted { background: rgba(79,195,176,0.14); color: var(--teal); }
  .status-declined { background: rgba(226,112,79,0.14); color: var(--coral); }
  .empty-state { text-align: center; padding: 60px 20px; background: var(--ink-2); border: 1px dashed var(--line-strong); border-radius: 16px; color: var(--muted); }
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
    <span class="greeting"><span data-i18n="nav_hi">Hi,</span> <strong><%= userName %></strong></span>
    <a href="vendors.jsp" class="btn btn-ghost" data-i18n="vendors_heading">Local vendors</a>
    <a href="dashboard.jsp" class="btn btn-ghost" data-i18n="nav_mytrips">My trips</a>
    <a href="LogoutServlet" class="btn btn-ghost" data-i18n="nav_logout">Log out</a>
  </div>
</header>

<main>
  <h1 data-i18n="myinquiries_heading">My inquiries</h1>
  <p class="sub" data-i18n="myinquiries_sub">Requests you've sent to local vendors.</p>

  <% if (inquiries.isEmpty()) { %>
    <div class="empty-state"><span data-i18n="myinquiries_empty_pre">You haven't contacted any vendors yet.</span> <a href="vendors.jsp" style="color:var(--gold);" data-i18n="savedvendors_empty_link">Browse local vendors &rarr;</a></div>
  <% } else { for (Object[] inq : inquiries) {
      int vendorId = (int) inq[0];
      String status = (String) inq[5];
      String statusClass = "ACCEPTED".equals(status) ? "status-accepted" : ("DECLINED".equals(status) ? "status-declined" : "status-new");
  %>
    <div class="inquiry-row">
      <div class="top">
        <a href="vendor-details.jsp?vendorId=<%= vendorId %>" class="name"><%= inq[1] %></a>
        <span class="status-badge <%= statusClass %>"><%= status %></span>
      </div>
      <div class="msg"><%= inq[2] %></div>
      <% if (inq[3] != null && !((String) inq[3]).trim().isEmpty()) { %>
        <div class="meta"><span data-i18n="myinquiries_dates_label">Travel dates:</span> <%= inq[3] %></div>
      <% } %>
      <div class="meta" style="margin-top:6px;"><%= inq[4] %></div>
    </div>
  <% } } %>
</main>

<script src="js/i18n.js?v=5"></script>
<script src="js/chatbot.js?v=3"></script>
</body>
</html>
