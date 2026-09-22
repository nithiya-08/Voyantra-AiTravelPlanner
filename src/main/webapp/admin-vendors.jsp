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

    ArrayList<Object[]> pending = new ArrayList<>();
    ArrayList<Object[]> reviewed = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT v.vendor_id, v.business_name, v.category, v.city, v.status, "
                       + "v.rejection_reason, u.name, u.email FROM vendors v "
                       + "JOIN users u ON v.user_id = u.user_id ORDER BY v.vendor_id DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Object[] row = new Object[] {
                    rs.getInt("vendor_id"),
                    rs.getString("business_name"),
                    rs.getString("category"),
                    rs.getString("city"),
                    rs.getString("status"),
                    rs.getString("rejection_reason"),
                    rs.getString("name"),
                    rs.getString("email")
                };
                if ("PENDING".equals(row[4])) pending.add(row); else reviewed.add(row);
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
<title>Vendor approvals — Voyantra</title>
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
  .section-title { font-family: 'Fraunces', serif; font-size: 1.3rem; margin-bottom: 16px; margin-top: 36px; }
  .vendor-row {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px;
    padding: 18px 20px; margin-bottom: 10px;
  }
  .vendor-row .top { display: flex; justify-content: space-between; align-items: baseline; flex-wrap: wrap; gap: 8px; margin-bottom: 6px; }
  .vendor-row .name { font-weight: 700; font-size: 1.02rem; }
  .vendor-row .meta { font-size: 0.8rem; color: var(--muted); }
  .trip-tag { font-size: 0.76rem; font-weight: 600; padding: 4px 10px; border-radius: 999px; background: var(--gold-soft); color: var(--gold); margin-right: 6px; }
  .trip-tag.status-approved { background: rgba(79,195,176,0.14); color: var(--teal); }
  .trip-tag.status-rejected { background: rgba(226,112,79,0.14); color: var(--coral); }
  .approve-form { display: flex; gap: 10px; align-items: center; margin-top: 12px; flex-wrap: wrap; }
  .approve-form input[type=text] {
    flex: 1; min-width: 180px; padding: 9px 12px; border-radius: 8px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.85rem;
  }
  .approve-form button {
    padding: 9px 16px; border-radius: 8px; border: 1px solid var(--line-strong); background: transparent;
    color: var(--paper); font-weight: 600; font-size: 0.82rem; cursor: pointer; transition: all 0.2s ease;
  }
  .approve-form button.approve:hover { border-color: var(--teal); color: var(--teal); }
  .approve-form button.reject:hover { border-color: var(--coral); color: var(--coral); }
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
  <h1>Vendor approvals</h1>
  <p class="sub">Review new vendor listings before they go live.</p>

  <div class="section-title">Pending (<%= pending.size() %>)</div>
  <% if (pending.isEmpty()) { %>
    <p class="empty-state">Nothing waiting for review.</p>
  <% } else { for (Object[] v : pending) {
      int vendorId = (int) v[0];
  %>
    <div class="vendor-row">
      <div class="top">
        <span class="name"><%= v[1] %></span>
        <span class="meta"><%= v[6] %> &middot; <%= v[7] %></span>
      </div>
      <div>
        <span class="trip-tag"><%= v[2] %></span>
        <span class="trip-tag"><%= v[3] %></span>
      </div>
      <form class="approve-form" action="AdminVendorApprovalServlet" method="POST">
        <input type="hidden" name="vendorId" value="<%= vendorId %>">
        <input type="text" name="rejectionReason" placeholder="Reason (only needed if rejecting)">
        <button type="submit" name="action" value="APPROVE" class="approve">Approve</button>
        <button type="submit" name="action" value="REJECT" class="reject">Reject</button>
      </form>
    </div>
  <% } } %>

  <div class="section-title">Reviewed</div>
  <% if (reviewed.isEmpty()) { %>
    <p class="empty-state">No listings reviewed yet.</p>
  <% } else { for (Object[] v : reviewed) {
      String status = (String) v[4];
      String statusClass = "APPROVED".equals(status) ? "status-approved" : "status-rejected";
  %>
    <div class="vendor-row">
      <div class="top">
        <span class="name"><%= v[1] %></span>
        <span class="meta"><%= v[6] %> &middot; <%= v[7] %></span>
      </div>
      <div>
        <span class="trip-tag"><%= v[2] %></span>
        <span class="trip-tag"><%= v[3] %></span>
        <span class="trip-tag <%= statusClass %>"><%= status %></span>
      </div>
      <% if ("REJECTED".equals(status) && v[5] != null && !((String) v[5]).trim().isEmpty()) { %>
        <div class="meta" style="margin-top:8px;">Reason: <%= v[5] %></div>
      <% } %>
    </div>
  <% } } %>
</main>

</body>
</html>
