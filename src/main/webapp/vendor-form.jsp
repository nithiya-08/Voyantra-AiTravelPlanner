<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String vendorIdStr = request.getParameter("vendorId");
    boolean editMode = vendorIdStr != null;
    int vendorId = 0;

    String businessName = "";
    String category = "";
    String description = "";
    String city = "";
    String state = "";
    String address = "";
    String phone = "";
    String vendorEmail = "";
    String priceRange = "";
    String photoUrl = "";
    String websiteUrl = "";
    String dietType = "";
    String signatureDish = "";

    if (editMode) {
        vendorId = Integer.parseInt(vendorIdStr);
        boolean found = false;
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sql = "SELECT business_name, category, description, city, state, address, phone, email, "
                           + "price_range, photo_url, website_url, diet_type, signature_dish "
                           + "FROM vendors WHERE vendor_id = ? AND user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, vendorId);
                stmt.setInt(2, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
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
                    websiteUrl = rs.getString("website_url");
                    dietType = rs.getString("diet_type");
                    signatureDish = rs.getString("signature_dish");
                    found = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (!found) {
            response.sendRedirect("my-vendor-listings.jsp");
            return;
        }
    }

    if (description == null) description = "";
    if (state == null) state = "";
    if (address == null) address = "";
    if (vendorEmail == null) vendorEmail = "";
    if (priceRange == null) priceRange = "";
    if (photoUrl == null) photoUrl = "";
    if (websiteUrl == null) websiteUrl = "";
    if (dietType == null) dietType = "";
    if (signatureDish == null) signatureDish = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= editMode ? "Edit listing" : "Become a vendor" %> — Voyantra</title>
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
  .back-link { font-size: 0.85rem; color: var(--muted); display: flex; align-items: center; gap: 6px; }
  .back-link:hover { color: var(--gold); }

  main { max-width: 720px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  .page-head { margin-bottom: 40px; }
  .kicker { font-size: 0.76rem; letter-spacing: 0.14em; text-transform: uppercase; color: var(--coral); font-weight: 700; margin-bottom: 12px; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 2.1rem; margin-bottom: 10px; }
  .page-head p { color: var(--muted); font-size: 1rem; }

  .form-card {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 20px;
    padding: 32px; box-shadow: 0 24px 50px rgba(0,0,0,0.35);
  }
  .field { margin-bottom: 24px; }
  .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
  label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 9px; }
  input, select, textarea {
    width: 100%; padding: 13px 15px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.94rem;
  }
  input:focus, select:focus, textarea:focus { outline: none; border-color: var(--gold); }
  select { cursor: pointer; }
  textarea { resize: vertical; min-height: 90px; }

  button.submit {
    width: 100%; padding: 15px; border-radius: 10px; border: none; cursor: pointer;
    background: var(--gold); color: var(--ink); font-weight: 700; font-size: 0.96rem; margin-top: 10px;
  }

  @media (max-width: 600px) {
    .field-row { grid-template-columns: 1fr; }
    .form-card { padding: 24px 20px; }
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
  <a href="my-vendor-listings.jsp" class="back-link" data-i18n="vendorform_back_listings">&larr; My listings</a>
</header>

<main>
  <div class="page-head">
    <div class="kicker" data-i18n="vendors_heading">Local vendors</div>
    <h1 data-i18n="<%= editMode ? "vendorform_edit_h1" : "vendorform_add_h1" %>"><%= editMode ? "Edit your listing" : "List your business" %></h1>
    <p data-i18n="vendorform_sub">Get discovered by travellers planning trips near you.</p>
  </div>

  <div class="form-card">
    <form action="<%= editMode ? "VendorEditServlet" : "VendorSignupServlet" %>" method="POST">
      <% if (editMode) { %>
      <input type="hidden" name="vendorId" value="<%= vendorId %>">
      <% } %>

      <div class="field">
        <label for="businessName" data-i18n="vendorform_bizname">Business name</label>
        <input type="text" id="businessName" name="businessName" value="<%= businessName %>" required>
      </div>

      <div class="field-row">
        <div class="field">
          <label for="category" data-i18n="vendorform_category">Category</label>
          <select id="category" name="category" required>
            <option value="HOTEL" data-i18n="vendors_cat_hotel" <%= category.equals("HOTEL") ? "selected" : "" %>>Hotel</option>
            <option value="HOMESTAY" data-i18n="vendors_cat_homestay" <%= category.equals("HOMESTAY") ? "selected" : "" %>>Homestay</option>
            <option value="GUIDE" data-i18n="vendors_cat_guide" <%= category.equals("GUIDE") ? "selected" : "" %>>Local guide</option>
            <option value="TRANSPORT" data-i18n="vendors_cat_transport" <%= category.equals("TRANSPORT") ? "selected" : "" %>>Local transport</option>
            <option value="ACTIVITY" data-i18n="vendors_cat_activity" <%= category.equals("ACTIVITY") ? "selected" : "" %>>Activity / experience</option>
            <option value="RESTAURANT" data-i18n="vendors_cat_restaurant" <%= category.equals("RESTAURANT") ? "selected" : "" %>>Restaurant / food</option>
          </select>
        </div>
        <div class="field">
          <label for="priceRange"><span data-i18n="vendorform_pricerange">Price range</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
          <input type="text" id="priceRange" name="priceRange" value="<%= priceRange %>" data-i18n-placeholder="vendorform_pricerange_ph" placeholder="e.g. Rs. 1500 - 3000 / night">
        </div>
      </div>

      <div class="field">
        <label for="description"><span data-i18n="vendorform_desc">Description</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
        <textarea id="description" name="description" data-i18n-placeholder="vendorform_desc_ph" placeholder="What makes your place/service worth booking?"><%= description %></textarea>
      </div>

      <div class="field-row">
        <div class="field">
          <label for="city" data-i18n="vendors_city_ph">City</label>
          <input type="text" id="city" name="city" value="<%= city %>" required>
        </div>
        <div class="field">
          <label for="state"><span data-i18n="vendorform_state">State</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
          <input type="text" id="state" name="state" value="<%= state %>">
        </div>
      </div>

      <div class="field">
        <label for="address"><span data-i18n="vendorform_address">Address</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
        <input type="text" id="address" name="address" value="<%= address %>">
      </div>

      <div class="field-row">
        <div class="field">
          <label for="phone" data-i18n="vendorform_phone">Contact phone</label>
          <input type="text" id="phone" name="phone" value="<%= phone %>" required>
        </div>
        <div class="field">
          <label for="email"><span data-i18n="vendorform_email">Contact email</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
          <input type="email" id="email" name="email" value="<%= vendorEmail %>">
        </div>
      </div>

      <div class="field">
        <label for="photoUrl"><span data-i18n="vendorform_photourl">Photo URL</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_optional">(optional)</span></label>
        <input type="url" id="photoUrl" name="photoUrl" value="<%= photoUrl %>" placeholder="https://...">
      </div>

      <div class="field">
        <label for="websiteUrl"><span data-i18n="vendorform_websiteurl">Website or social media link</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_websiteurl_hint">(optional, but builds trust — travellers can check you're real)</span></label>
        <input type="url" id="websiteUrl" name="websiteUrl" value="<%= websiteUrl %>" placeholder="https://...">
      </div>

      <div id="foodFields" style="display:none;">
        <div class="field-row">
          <div class="field">
            <label for="dietType" data-i18n="vendorform_menutype">Menu type</label>
            <select id="dietType" name="dietType">
              <option value="" data-i18n="vendorform_notspecified">Not specified</option>
              <option value="VEG" data-i18n="vendorform_veg_only" <%= "VEG".equals(dietType) ? "selected" : "" %>>Vegetarian only</option>
              <option value="NON_VEG" data-i18n="vendorform_nonveg" <%= "NON_VEG".equals(dietType) ? "selected" : "" %>>Non-vegetarian available</option>
              <option value="BOTH" data-i18n="vendorform_both" <%= "BOTH".equals(dietType) ? "selected" : "" %>>Both veg &amp; non-veg</option>
            </select>
          </div>
          <div class="field">
            <label for="signatureDish"><span data-i18n="vendorform_sigdish">Signature dish</span> <span style="font-weight:400; color:var(--muted); font-size:0.8rem;" data-i18n="vendorform_sigdish_hint">(what you're famous for)</span></label>
            <input type="text" id="signatureDish" name="signatureDish" value="<%= signatureDish %>" placeholder="e.g. Chettinad Chicken">
          </div>
        </div>
      </div>

      <button type="submit" class="submit" data-i18n="<%= editMode ? "profile_save_btn" : "vendorform_submit_new" %>"><%= editMode ? "Save changes" : "Submit for approval" %></button>
    </form>
  </div>
</main>

<script src="js/i18n.js?v=5"></script>
<script src="js/chatbot.js?v=3"></script>
<script>
  (function () {
    var categorySelect = document.getElementById('category');
    var foodFields = document.getElementById('foodFields');
    function toggleFoodFields() {
      foodFields.style.display = categorySelect.value === 'RESTAURANT' ? 'block' : 'none';
    }
    categorySelect.addEventListener('change', toggleFoodFields);
    toggleFoodFields();
  })();
</script>
</body>
</html>
