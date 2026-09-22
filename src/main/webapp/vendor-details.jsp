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
    Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);

    String vendorIdStr = request.getParameter("vendorId");
    if (vendorIdStr == null) {
        response.sendRedirect("vendors.jsp");
        return;
    }
    int vendorId = Integer.parseInt(vendorIdStr);
    boolean inquirySent = "1".equals(request.getParameter("inquirySent"));

    String businessName = null, category = null, description = null, city = null, state = null,
           address = null, phone = null, vendorEmail = null, priceRange = null, photoUrl = null, status = null;
    int ownerUserId = 0;
    Double avgRating = null;
    int reviewCount = 0;
    ArrayList<Object[]> reviews = new ArrayList<>();
    Integer myRating = null;
    String myComment = null;

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT user_id, business_name, category, description, city, state, address, phone, "
                       + "email, price_range, photo_url, status FROM vendors WHERE vendor_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, vendorId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                ownerUserId = rs.getInt("user_id");
                businessName = rs.getString("business_name");
                category = rs.getString("category");
                description = rs.getString("description");
                city = rs.getString("city");
                state = rs.getString("state");
                address = rs.getString("address");
                phone = rs.getString("phone");
                vendorEmail = rs.getString("email");
                priceRange = rs.getString("price_range");
                photoUrl = rs.getString("photo_url");
                status = rs.getString("status");
            }

            boolean visible = businessName != null &&
                ("APPROVED".equals(status) || ownerUserId == userId || isAdmin);

            if (visible) {
                String ratingSql = "SELECT AVG(rating) avg_rating, COUNT(*) cnt FROM vendor_reviews WHERE vendor_id = ?";
                PreparedStatement ratingStmt = conn.prepareStatement(ratingSql);
                ratingStmt.setInt(1, vendorId);
                ResultSet ratingRs = ratingStmt.executeQuery();
                if (ratingRs.next()) {
                    Object avgObj = ratingRs.getObject("avg_rating");
                    if (avgObj != null) avgRating = ratingRs.getDouble("avg_rating");
                    reviewCount = ratingRs.getInt("cnt");
                }

                String reviewSql = "SELECT u.name, r.rating, r.comment, r.created_at, r.user_id "
                                  + "FROM vendor_reviews r JOIN users u ON r.user_id = u.user_id "
                                  + "WHERE r.vendor_id = ? ORDER BY r.review_id DESC";
                PreparedStatement reviewStmt = conn.prepareStatement(reviewSql);
                reviewStmt.setInt(1, vendorId);
                ResultSet reviewRs = reviewStmt.executeQuery();
                while (reviewRs.next()) {
                    reviews.add(new Object[] {
                        reviewRs.getString("name"),
                        reviewRs.getInt("rating"),
                        reviewRs.getString("comment"),
                        reviewRs.getTimestamp("created_at")
                    });
                    if (reviewRs.getInt("user_id") == userId) {
                        myRating = reviewRs.getInt("rating");
                        myComment = reviewRs.getString("comment");
                    }
                }
            } else {
                businessName = null;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (businessName == null) {
        response.sendRedirect("vendors.jsp");
        return;
    }
    boolean isOwner = ownerUserId == userId;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= businessName %> — Voyantra</title>
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
  .banner { background: rgba(79,195,176,0.14); color: var(--teal); border: 1px solid rgba(79,195,176,0.3); border-radius: 10px; padding: 14px 18px; margin-bottom: 24px; font-size: 0.88rem; }
  .vendor-photo { width: 100%; height: 240px; object-fit: cover; border-radius: 16px; margin-bottom: 24px; background: var(--ink-2); }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 2rem; margin-bottom: 10px; }
  .trip-meta { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 18px; }
  .trip-tag { font-size: 0.76rem; font-weight: 600; padding: 5px 11px; border-radius: 999px; background: var(--gold-soft); color: var(--gold); }
  .trip-tag.status-pending { background: rgba(231,169,76,0.14); color: var(--gold); }
  .rating-line { font-size: 0.92rem; color: var(--muted); margin-bottom: 20px; }
  .rating-line strong { color: var(--gold); }
  .description { font-size: 0.96rem; line-height: 1.6; margin-bottom: 28px; color: var(--paper); }
  .contact-card { background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px; padding: 20px; margin-bottom: 32px; font-size: 0.9rem; }
  .contact-card div { margin-bottom: 6px; }
  .section-title { font-family: 'Fraunces', serif; font-size: 1.3rem; margin-bottom: 16px; }

  .form-card { background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px; padding: 24px; margin-bottom: 32px; }
  .field { margin-bottom: 18px; }
  label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 8px; }
  input, select, textarea {
    width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.9rem;
  }
  textarea { resize: vertical; min-height: 70px; }
  input:focus, select:focus, textarea:focus { outline: none; border-color: var(--gold); }
  button.submit {
    padding: 12px 24px; border-radius: 10px; border: none; cursor: pointer;
    background: var(--gold); color: var(--ink); font-weight: 700; font-size: 0.9rem;
  }

  .review-row { background: var(--ink-2); border: 1px solid var(--line); border-radius: 12px; padding: 16px 18px; margin-bottom: 10px; }
  .review-row .top { display: flex; justify-content: space-between; margin-bottom: 6px; }
  .review-row .name { font-weight: 700; }
  .review-row .stars { color: var(--gold); }
  .review-row .comment { font-size: 0.9rem; color: var(--paper); }
  .empty-state { color: var(--muted); font-size: 0.9rem; margin-bottom: 20px; }
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
  <a href="vendors.jsp" class="back-link">&larr; Back to vendors</a>
</header>

<main>
  <% if (inquirySent) { %>
    <div class="banner">Your inquiry was sent — the vendor will reach out to you directly.</div>
  <% } %>

  <% if (photoUrl != null && !photoUrl.trim().isEmpty()) { %>
    <img class="vendor-photo" src="<%= photoUrl %>" alt="<%= businessName %>">
  <% } %>

  <h1><%= businessName %></h1>
  <div class="trip-meta">
    <span class="trip-tag"><%= category %></span>
    <span class="trip-tag"><%= city %><%= (state != null && !state.trim().isEmpty()) ? ", " + state : "" %></span>
    <% if (priceRange != null && !priceRange.trim().isEmpty()) { %><span class="trip-tag"><%= priceRange %></span><% } %>
    <% if (!"APPROVED".equals(status)) { %><span class="trip-tag status-pending"><%= status %></span><% } %>
  </div>
  <div class="rating-line">
    <% if (avgRating != null) { %>
      <strong>&#9733; <%= String.format("%.1f", avgRating) %></strong> (<%= reviewCount %> reviews)
    <% } else { %>
      No reviews yet
    <% } %>
  </div>

  <% if (description != null && !description.trim().isEmpty()) { %>
    <div class="description"><%= description %></div>
  <% } %>

  <div class="contact-card">
    <% if (address != null && !address.trim().isEmpty()) { %><div>&#128205; <%= address %></div><% } %>
    <div>&#128222; <%= phone %></div>
    <% if (vendorEmail != null && !vendorEmail.trim().isEmpty()) { %><div>&#9993; <%= vendorEmail %></div><% } %>
  </div>

  <% if (!isOwner) { %>
  <div class="section-title">Contact this vendor</div>
  <div class="form-card">
    <form action="VendorInquiryServlet" method="POST">
      <input type="hidden" name="vendorId" value="<%= vendorId %>">
      <div class="field">
        <label for="message">Message</label>
        <textarea id="message" name="message" placeholder="Tell them what you need..." required></textarea>
      </div>
      <div class="field">
        <label for="travelDates">Travel dates <span style="font-weight:400; color:var(--muted); font-size:0.8rem;">(optional)</span></label>
        <input type="text" id="travelDates" name="travelDates" placeholder="e.g. 12-15 Oct">
      </div>
      <div class="field">
        <label for="contactPhone">Your phone <span style="font-weight:400; color:var(--muted); font-size:0.8rem;">(optional)</span></label>
        <input type="text" id="contactPhone" name="contactPhone">
      </div>
      <button type="submit" class="submit">Send inquiry</button>
    </form>
  </div>

  <div class="section-title">Leave a review</div>
  <div class="form-card">
    <form action="VendorReviewServlet" method="POST">
      <input type="hidden" name="vendorId" value="<%= vendorId %>">
      <div class="field">
        <label for="rating">Rating</label>
        <select id="rating" name="rating" required>
          <option value="5" <%= (myRating != null && myRating == 5) ? "selected" : "" %>>&#9733;&#9733;&#9733;&#9733;&#9733; Excellent</option>
          <option value="4" <%= (myRating != null && myRating == 4) ? "selected" : "" %>>&#9733;&#9733;&#9733;&#9733; Good</option>
          <option value="3" <%= (myRating != null && myRating == 3) ? "selected" : "" %>>&#9733;&#9733;&#9733; Okay</option>
          <option value="2" <%= (myRating != null && myRating == 2) ? "selected" : "" %>>&#9733;&#9733; Poor</option>
          <option value="1" <%= (myRating != null && myRating == 1) ? "selected" : "" %>>&#9733; Bad</option>
        </select>
      </div>
      <div class="field">
        <label for="comment">Comment <span style="font-weight:400; color:var(--muted); font-size:0.8rem;">(optional)</span></label>
        <textarea id="comment" name="comment"><%= myComment != null ? myComment : "" %></textarea>
      </div>
      <button type="submit" class="submit"><%= myRating != null ? "Update review" : "Submit review" %></button>
    </form>
  </div>
  <% } %>

  <div class="section-title">Reviews</div>
  <% if (reviews.isEmpty()) { %>
    <p class="empty-state">No reviews yet — be the first to leave one.</p>
  <% } else { for (Object[] r : reviews) {
      int stars = (int) r[1];
      StringBuilder starStr = new StringBuilder();
      for (int i = 0; i < stars; i++) starStr.append("★");
      for (int i = stars; i < 5; i++) starStr.append("☆");
  %>
    <div class="review-row">
      <div class="top">
        <span class="name"><%= r[0] %></span>
        <span class="stars"><%= starStr.toString() %></span>
      </div>
      <% if (r[2] != null && !((String) r[2]).trim().isEmpty()) { %>
        <div class="comment"><%= r[2] %></div>
      <% } %>
    </div>
  <% } } %>
</main>

</body>
</html>
