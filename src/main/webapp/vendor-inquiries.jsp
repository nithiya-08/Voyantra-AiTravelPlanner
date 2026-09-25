<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String vendorIdStr = request.getParameter("vendorId");
    if (vendorIdStr == null) {
        response.sendRedirect("my-vendor-listings.jsp");
        return;
    }
    int vendorId = Integer.parseInt(vendorIdStr);

    String businessName = null;
    ArrayList<Object[]> inquiries = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String ownerSql = "SELECT business_name FROM vendors WHERE vendor_id = ? AND user_id = ?";
            PreparedStatement ownerStmt = conn.prepareStatement(ownerSql);
            ownerStmt.setInt(1, vendorId);
            ownerStmt.setInt(2, userId);
            ResultSet ownerRs = ownerStmt.executeQuery();
            if (ownerRs.next()) {
                businessName = ownerRs.getString("business_name");

                String sql = "SELECT i.inquiry_id, u.name, u.email, i.message, i.contact_phone, i.travel_dates, i.created_at, i.status "
                           + "FROM vendor_inquiries i JOIN users u ON i.user_id = u.user_id "
                           + "WHERE i.vendor_id = ? ORDER BY i.inquiry_id DESC";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, vendorId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    inquiries.add(new Object[] {
                        rs.getInt("inquiry_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("message"),
                        rs.getString("contact_phone"),
                        rs.getString("travel_dates"),
                        rs.getTimestamp("created_at"),
                        rs.getString("status")
                    });
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (businessName == null) {
        response.sendRedirect("my-vendor-listings.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Inquiries — Voyantra</title>
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
  main { max-width: 800px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; margin-bottom: 8px; }
  .sub { color: var(--muted); margin-bottom: 34px; }
  .inquiry-row {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px;
    padding: 18px 20px; margin-bottom: 12px;
  }
  .inquiry-row .top { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; flex-wrap: wrap; gap: 8px; }
  .inquiry-row .name { font-weight: 700; }
  .inquiry-row .meta { font-size: 0.78rem; color: var(--muted); }
  .inquiry-row .msg { font-size: 0.92rem; margin-bottom: 8px; }
  .inquiry-row .contact { font-size: 0.82rem; color: var(--gold); }
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
  <a href="my-vendor-listings.jsp" class="back-link" data-i18n="vendorform_back_listings">&larr; My listings</a>
</header>

<main>
  <h1 data-i18n="listings_inquiries_link">Inquiries</h1>
  <p class="sub"><span data-i18n="vendorinq_sub_pre">Travellers who reached out about</span> "<%= businessName %>".</p>

  <% if (inquiries.isEmpty()) { %>
    <div class="empty-state" data-i18n="vendorinq_empty">No inquiries yet.</div>
  <% } else { for (Object[] inq : inquiries) {
      int inquiryId = (int) inq[0];
      String inqStatus = (String) inq[7];
  %>
    <div class="inquiry-row">
      <div class="top">
        <span class="name"><%= inq[1] %></span>
        <span class="meta"><%= inq[6] %></span>
      </div>
      <div class="msg"><%= inq[3] %></div>
      <% if (inq[5] != null && !((String) inq[5]).trim().isEmpty()) { %>
        <div class="meta"><span data-i18n="myinquiries_dates_label">Travel dates:</span> <%= inq[5] %></div>
      <% } %>
      <div class="contact">
        <%= inq[2] %><% if (inq[4] != null && !((String) inq[4]).trim().isEmpty()) { %> &middot; <%= inq[4] %><% } %>
      </div>
      <div style="margin-top:10px; display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
        <span class="meta" style="color:<%= "ACCEPTED".equals(inqStatus) ? "var(--teal)" : ("DECLINED".equals(inqStatus) ? "var(--coral)" : "var(--gold)") %>;"><%= inqStatus %></span>
        <% if ("NEW".equals(inqStatus)) { %>
        <form action="MarkInquiryRespondedServlet" method="POST" style="margin:0;">
          <input type="hidden" name="inquiryId" value="<%= inquiryId %>">
          <input type="hidden" name="vendorId" value="<%= vendorId %>">
          <button type="submit" name="action" value="ACCEPT" style="background:none; border:1px solid var(--teal); border-radius:8px; padding:6px 12px; color:var(--teal); font-size:0.78rem; cursor:pointer;" data-i18n="vendorinq_accept">Accept</button>
          <button type="submit" name="action" value="DECLINE" style="background:none; border:1px solid var(--coral); border-radius:8px; padding:6px 12px; color:var(--coral); font-size:0.78rem; cursor:pointer;" data-i18n="vendorinq_decline">Decline</button>
        </form>
        <% } %>
      </div>
    </div>
  <% } } %>
</main>

<script src="js/i18n.js?v=5"></script>
<script src="js/chatbot.js?v=3"></script>
</body>
</html>
