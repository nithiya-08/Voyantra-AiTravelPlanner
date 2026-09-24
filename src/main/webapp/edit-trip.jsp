<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String tripIdStr = request.getParameter("tripId");
    if (tripIdStr == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    int tripId = Integer.parseInt(tripIdStr);

    String destination = null;
    double budget = 0;
    int numDays = 0;
    String travelStyle = null;
    String interests = null;
    java.sql.Date startDate = null;
    String foodPreference = null;
    boolean found = false;

    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT destination, budget, num_days, travel_style, interests, start_date, food_preference "
                       + "FROM trips WHERE trip_id = ? AND user_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, tripId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                destination = rs.getString("destination");
                budget = rs.getDouble("budget");
                numDays = rs.getInt("num_days");
                travelStyle = rs.getString("travel_style");
                interests = rs.getString("interests");
                startDate = rs.getDate("start_date");
                foodPreference = rs.getString("food_preference");
                found = true;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    if (foodPreference == null) foodPreference = "";

    if (!found) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // Turn "Nature, Food" into a list we can check against for pre-selecting checkboxes
    java.util.List<String> interestList = java.util.Arrays.asList(interests.split(",\\s*"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit trip - Voyantra</title>
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
  input, select {
    width: 100%; padding: 13px 15px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.94rem;
  }
  input:focus, select:focus { outline: none; border-color: var(--gold); }
  select { cursor: pointer; }
  .amount-shell { position: relative; }
  .amount-shell .prefix { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: var(--muted); }
  .amount-shell input { padding-left: 30px; }

  .interest-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
  .interest-chip { position: relative; }
  .interest-chip input { position: absolute; opacity: 0; width: 100%; height: 100%; margin: 0; cursor: pointer; }
  .interest-chip .chip-body {
    display: flex; align-items: center; gap: 9px; padding: 12px 14px;
    border: 1px solid var(--line-strong); border-radius: 12px; background: var(--ink-3);
    font-size: 0.88rem; font-weight: 600;
  }
  .interest-chip input:checked + .chip-body {
    border-color: var(--gold); background: var(--gold-soft); color: var(--gold);
  }

  button.submit {
    width: 100%; padding: 15px; border-radius: 10px; border: none; cursor: pointer;
    background: var(--gold); color: var(--ink); font-weight: 700; font-size: 0.96rem; margin-top: 10px;
  }

  @media (max-width: 600px) {
    .field-row { grid-template-columns: 1fr; }
    .interest-grid { grid-template-columns: 1fr 1fr; }
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
  <a href="dashboard.jsp" class="back-link">&larr; Back to dashboard</a>
</header>

<main>
  <div class="page-head">
    <div class="kicker" data-i18n="edittrip_kicker">Edit trip</div>
    <h1 data-i18n="edittrip_heading">Update your trip</h1>
    <p data-i18n="edittrip_sub">Change any detail below and save.</p>
  </div>

  <div class="form-card">
    <form action="UpdateTripServlet" method="POST">
      <input type="hidden" name="tripId" value="<%= tripId %>">

      <div class="field">
        <label for="destination">Destination</label>
        <input type="text" id="destination" name="destination" value="<%= destination %>">
      </div>

      <div class="field-row">
        <div class="field">
          <label for="budget">Budget</label>
          <div class="amount-shell">
            <span class="prefix">Rs.</span>
            <input type="number" id="budget" name="budget" value="<%= (int) budget %>" min="500" step="100">
          </div>
        </div>
        <div class="field">
          <label for="numDays">Number of days</label>
          <input type="number" id="numDays" name="numDays" value="<%= numDays %>" min="1" max="30">
        </div>
      </div>

      <div class="field">
        <label for="startDate">Start date <span class="hint" style="font-weight:400; color:var(--muted); font-size:0.8rem;">(optional)</span></label>
        <input type="date" id="startDate" name="startDate" value="<%= startDate != null ? startDate.toString() : "" %>">
      </div>

      <div class="field">
        <label for="travelStyle">Travel style</label>
        <select id="travelStyle" name="travelStyle">
          <option value="Solo" <%= travelStyle.equals("Solo") ? "selected" : "" %>>Solo</option>
          <option value="Family" <%= travelStyle.equals("Family") ? "selected" : "" %>>Family</option>
          <option value="Friends" <%= travelStyle.equals("Friends") ? "selected" : "" %>>Friends</option>
          <option value="Couple" <%= travelStyle.equals("Couple") ? "selected" : "" %>>Couple</option>
        </select>
      </div>

      <div class="field">
        <label>Interests</label>
        <div class="interest-grid">
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Nature" <%= interestList.contains("Nature") ? "checked" : "" %>>
            <span class="chip-body">Nature</span>
          </label>
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Food" <%= interestList.contains("Food") ? "checked" : "" %>>
            <span class="chip-body">Food</span>
          </label>
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Adventure" <%= interestList.contains("Adventure") ? "checked" : "" %>>
            <span class="chip-body">Adventure</span>
          </label>
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Culture" <%= interestList.contains("Culture") ? "checked" : "" %>>
            <span class="chip-body">Culture</span>
          </label>
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Relaxation" <%= interestList.contains("Relaxation") ? "checked" : "" %>>
            <span class="chip-body">Relax</span>
          </label>
          <label class="interest-chip">
            <input type="checkbox" name="interests" value="Shopping" <%= interestList.contains("Shopping") ? "checked" : "" %>>
            <span class="chip-body">Shopping</span>
          </label>
        </div>
      </div>

      <div class="field">
        <label for="foodPreference">Food preference <span class="hint" style="font-weight:400; color:var(--muted); font-size:0.8rem;">(optional — powers restaurant recommendations)</span></label>
        <select id="foodPreference" name="foodPreference">
          <option value="" <%= foodPreference.isEmpty() ? "selected" : "" %>>No preference</option>
          <option value="VEG" <%= "VEG".equals(foodPreference) ? "selected" : "" %>>Vegetarian</option>
          <option value="NON_VEG" <%= "NON_VEG".equals(foodPreference) ? "selected" : "" %>>Non-vegetarian</option>
        </select>
      </div>

      <button type="submit" class="submit" data-i18n="edittrip_save">Save changes</button>
    </form>
  </div>
</main>

<script src="js/i18n.js?v=3"></script>
<script src="js/chatbot.js?v=3"></script>
</body>
</html>