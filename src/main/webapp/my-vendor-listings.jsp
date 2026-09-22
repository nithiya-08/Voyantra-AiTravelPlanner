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

    ArrayList<Object[]> listings = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT v.vendor_id, v.business_name, v.category, v.city, v.status, v.rejection_reason, "
                       + "(SELECT COUNT(*) FROM vendor_inquiries i WHERE i.vendor_id = v.vendor_id) AS inquiry_count, "
                       + "(SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS avg_rating, "
                       + "(SELECT COUNT(*) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS review_count "
                       + "FROM vendors v WHERE v.user_id = ? ORDER BY v.vendor_id DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                listings.add(new Object[] {
                    rs.getInt("vendor_id"),
                    rs.getString("business_name"),
                    rs.getString("category"),
                    rs.getString("city"),
                    rs.getString("status"),
                    rs.getString("rejection_reason"),
                    rs.getInt("inquiry_count"),
                    rs.getObject("avg_rating"),
                    rs.getInt("review_count")
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
<title>My vendor listings — Voyantra</title>
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
  .trip-tag.status-approved { background: rgba(79,195,176,0.14); color: var(--teal); }
  .trip-tag.status-rejected { background: rgba(226,112,79,0.14); color: var(--coral); }
  .reject-reason { font-size: 0.8rem; color: var(--coral); margin-bottom: 14px; }
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
    <a href="dashboard.jsp" class="btn btn-ghost">My trips</a>
    <a href="LogoutServlet" class="btn btn-ghost">Log out</a>
  </div>
</header>

<main>
  <div class="page-head">
    <div>
      <h1>My vendor listings</h1>
      <p>Manage the businesses you've listed on Voyantra.</p>
    </div>
    <a href="vendor-form.jsp" class="btn btn-primary">+ Add listing</a>
  </div>

  <% if (listings.isEmpty()) { %>
      <div class="empty-state">
          <p>You haven't listed a business yet.</p>
          <a href="vendor-form.jsp" class="btn btn-primary">List your business &rarr;</a>
      </div>
  <% } else { %>
      <div class="trip-grid">
      <% for (Object[] v : listings) {
          int vendorId = (int) v[0];
          String businessName = (String) v[1];
          String category = (String) v[2];
          String city = (String) v[3];
          String status = (String) v[4];
          String rejectionReason = (String) v[5];
          int inquiryCount = (int) v[6];
          Object avgRatingObj = v[7];
          int reviewCount = (int) v[8];
          String statusClass = "APPROVED".equals(status) ? "status-approved" : ("REJECTED".equals(status) || "SUSPENDED".equals(status) ? "status-rejected" : "");
      %>
          <div class="trip-card">
              <h3><%= businessName %></h3>
              <div class="trip-meta">
                  <span class="trip-tag"><%= category %></span>
                  <span class="trip-tag"><%= city %></span>
                  <span class="trip-tag <%= statusClass %>"><%= status %></span>
              </div>
              <div class="trip-interests">
                  <%= inquiryCount %> inquir<%= inquiryCount == 1 ? "y" : "ies" %>
                  &middot;
                  <% if (avgRatingObj != null) { %>&#9733; <%= String.format("%.1f", (Double) avgRatingObj) %> (<%= reviewCount %> reviews)<% } else { %>no reviews yet<% } %>
              </div>
              <% if ("REJECTED".equals(status) && rejectionReason != null && !rejectionReason.trim().isEmpty()) { %>
              <div class="reject-reason">Reason: <%= rejectionReason %></div>
              <% } %>
              <div class="trip-actions">
                  <a href="vendor-details.jsp?vendorId=<%= vendorId %>">View</a>
                  <a href="vendor-form.jsp?vendorId=<%= vendorId %>">Edit</a>
                  <a href="vendor-inquiries.jsp?vendorId=<%= vendorId %>">Inquiries</a>
              </div>
              <div class="trip-actions" style="margin-top:10px;">
                  <form action="VendorDeleteServlet" method="POST" style="flex:1; margin:0;">
                      <input type="hidden" name="vendorId" value="<%= vendorId %>">
                      <button type="submit" class="delete-btn" style="width:100%;"
                              onclick="return confirm('Delete this listing?');">Delete</button>
                  </form>
              </div>
          </div>
      <% } %>
      </div>
  <% } %>
</main>

</body>
</html>
