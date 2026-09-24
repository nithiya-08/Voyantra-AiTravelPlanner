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

    String category = request.getParameter("category");
    String city = request.getParameter("city");
    if (category == null) category = "";
    if (city == null) city = "";

    ArrayList<Object[]> vendors = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            StringBuilder sql = new StringBuilder(
                "SELECT v.vendor_id, v.business_name, v.category, v.city, v.price_range, v.photo_url, "
                + "(SELECT AVG(rating) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS avg_rating, "
                + "(SELECT COUNT(*) FROM vendor_reviews r WHERE r.vendor_id = v.vendor_id) AS review_count, "
                + "v.is_verified, v.website_url "
                + "FROM vendors v WHERE v.status = 'APPROVED'");
            if (!category.isEmpty()) sql.append(" AND v.category = ?");
            if (!city.isEmpty()) sql.append(" AND v.city LIKE ?");
            sql.append(" ORDER BY v.vendor_id DESC");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (!category.isEmpty()) stmt.setString(idx++, category);
            if (!city.isEmpty()) stmt.setString(idx++, "%" + city + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                vendors.add(new Object[] {
                    rs.getInt("vendor_id"),
                    rs.getString("business_name"),
                    rs.getString("category"),
                    rs.getString("city"),
                    rs.getString("price_range"),
                    rs.getString("photo_url"),
                    rs.getObject("avg_rating"),
                    rs.getInt("review_count"),
                    rs.getBoolean("is_verified"),
                    rs.getString("website_url")
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
<title>Local vendors — Voyantra</title>
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

  main { max-width: 1100px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  .page-head { margin-bottom: 24px; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; }
  .page-head p { color: var(--muted); font-size: 0.92rem; margin-top: 6px; }

  .filter-bar { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 32px; }
  .filter-bar select, .filter-bar input {
    padding: 11px 14px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.88rem;
  }
  .filter-bar button {
    padding: 11px 20px; border-radius: 10px; border: none; background: var(--gold); color: var(--ink);
    font-weight: 700; font-size: 0.88rem; cursor: pointer;
  }

  .vendor-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
  .vendor-card {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px;
    overflow: hidden; transition: border-color 0.2s ease, transform 0.2s ease;
  }
  .vendor-card:hover { border-color: rgba(231,169,76,0.35); transform: translateY(-3px); }
  .vendor-photo { width: 100%; height: 140px; object-fit: cover; background: var(--ink-3); display: block; }
  .vendor-body { padding: 20px; }
  .vendor-card h3 { font-family: 'Fraunces', serif; font-size: 1.2rem; margin-bottom: 10px; }
  .trip-meta { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
  .trip-tag { font-size: 0.76rem; font-weight: 600; padding: 5px 11px; border-radius: 999px; background: var(--gold-soft); color: var(--gold); }
  .rating { font-size: 0.84rem; color: var(--muted); margin-bottom: 16px; }
  .rating strong { color: var(--gold); }
  .vendor-actions { display: flex; gap: 8px; }
  .vendor-body a.view-btn {
    flex: 1; display: block; text-align: center; padding: 9px; border-radius: 8px; font-size: 0.82rem; font-weight: 600;
    border: 1px solid var(--line-strong); color: var(--paper); transition: all 0.2s ease;
  }
  .vendor-body a.view-btn:hover { border-color: var(--teal); color: var(--teal); }
  .vendor-body a.website-btn { border-color: rgba(79,195,176,0.3); color: var(--teal); }
  .vendor-body a.website-btn:hover { border-color: var(--teal); background: rgba(79,195,176,0.1); }

  .empty-state { text-align: center; padding: 60px 20px; background: var(--ink-2); border: 1px dashed var(--line-strong); border-radius: 16px; color: var(--muted); }

  @media (max-width: 600px) { header { padding: 14px 5vw; } .greeting { display: none; } }
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
    <a href="saved-vendors.jsp" class="btn btn-ghost">Saved</a>
    <a href="my-inquiries.jsp" class="btn btn-ghost">My inquiries</a>
    <a href="dashboard.jsp" class="btn btn-ghost">My trips</a>
    <a href="LogoutServlet" class="btn btn-ghost">Log out</a>
  </div>
</header>

<main>
  <div class="page-head">
    <h1>Local vendors</h1>
    <p>Homestays, guides, transport, and experiences from people who know the place.</p>
  </div>

  <form class="filter-bar" method="GET" action="vendors.jsp">
    <select name="category">
      <option value="" <%= category.isEmpty() ? "selected" : "" %>>All categories</option>
      <option value="HOTEL" <%= category.equals("HOTEL") ? "selected" : "" %>>Hotel</option>
      <option value="HOMESTAY" <%= category.equals("HOMESTAY") ? "selected" : "" %>>Homestay</option>
      <option value="GUIDE" <%= category.equals("GUIDE") ? "selected" : "" %>>Local guide</option>
      <option value="TRANSPORT" <%= category.equals("TRANSPORT") ? "selected" : "" %>>Local transport</option>
      <option value="ACTIVITY" <%= category.equals("ACTIVITY") ? "selected" : "" %>>Activity / experience</option>
      <option value="RESTAURANT" <%= category.equals("RESTAURANT") ? "selected" : "" %>>Restaurant / food</option>
    </select>
    <input type="text" name="city" placeholder="City" value="<%= city %>">
    <button type="submit">Filter</button>
  </form>

  <% if (vendors.isEmpty()) { %>
    <div class="empty-state">No vendors found. Try a different filter.</div>
  <% } else { %>
    <div class="vendor-grid">
    <% for (Object[] v : vendors) {
        int vendorId = (int) v[0];
        String businessName = (String) v[1];
        String vCategory = (String) v[2];
        String vCity = (String) v[3];
        String priceRange = (String) v[4];
        String photoUrl = (String) v[5];
        Object avgRatingObj = v[6];
        int reviewCount = (int) v[7];
        boolean vVerified = (boolean) v[8];
        String websiteUrl = (String) v[9];
    %>
        <div class="vendor-card">
            <% if (photoUrl != null && !photoUrl.trim().isEmpty()) { %>
              <img class="vendor-photo" src="<%= photoUrl %>" alt="<%= businessName %>">
            <% } %>
            <div class="vendor-body">
                <h3><%= businessName %><% if (vVerified) { %> <span style="color:var(--teal); font-size:0.76rem; font-weight:700;">&#10003; Verified</span><% } %></h3>
                <div class="trip-meta">
                    <span class="trip-tag"><%= vCategory %></span>
                    <span class="trip-tag"><%= vCity %></span>
                    <% if (priceRange != null && !priceRange.trim().isEmpty()) { %>
                      <span class="trip-tag"><%= priceRange %></span>
                    <% } %>
                </div>
                <div class="rating">
                    <% if (avgRatingObj != null) { %>
                      <strong>&#9733; <%= String.format("%.1f", (Double) avgRatingObj) %></strong> (<%= reviewCount %> reviews)
                    <% } else { %>
                      No reviews yet
                    <% } %>
                </div>
                <div class="vendor-actions">
                    <a class="view-btn" href="vendor-details.jsp?vendorId=<%= vendorId %>">View details</a>
                    <% if (websiteUrl != null && !websiteUrl.trim().isEmpty()) { %>
                    <a class="view-btn website-btn" href="<%= websiteUrl %>" target="_blank" rel="noopener noreferrer">Website &#8599;</a>
                    <% } %>
                </div>
            </div>
        </div>
    <% } %>
    </div>
  <% } %>
</main>

</body>
</html>
