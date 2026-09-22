<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voyantra.db.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.html");
        return;
    }

    String name = "", email = "", phone = "";
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            String sql = "SELECT name, email, phone FROM users WHERE user_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                name = rs.getString("name");
                email = rs.getString("email");
                phone = rs.getString("phone");
                if (phone == null) phone = "";
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    boolean profileSuccess = "1".equals(request.getParameter("profileSuccess"));
    boolean profileError = "1".equals(request.getParameter("profileError"));
    boolean pwSuccess = "1".equals(request.getParameter("pwSuccess"));
    String pwError = request.getParameter("pwError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My profile — Voyantra</title>
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
  main { max-width: 560px; margin: 0 auto; padding: 6vh 6vw 10vh; }
  h1 { font-family: 'Fraunces', serif; font-weight: 500; font-size: 1.9rem; margin-bottom: 8px; }
  .sub { color: var(--muted); margin-bottom: 30px; }
  .section-title { font-family: 'Fraunces', serif; font-size: 1.2rem; margin-bottom: 14px; margin-top: 30px; }
  .form-card { background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px; padding: 24px; }
  .field { margin-bottom: 18px; }
  label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 8px; }
  input {
    width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.9rem;
  }
  input:disabled { color: var(--muted); }
  input:focus { outline: none; border-color: var(--gold); }
  button.submit { padding: 12px 24px; border-radius: 10px; border: none; cursor: pointer; background: var(--gold); color: var(--ink); font-weight: 700; font-size: 0.9rem; }
  .banner { padding: 12px 16px; border-radius: 10px; margin-bottom: 20px; font-size: 0.86rem; }
  .banner-success { background: rgba(79,195,176,0.14); color: var(--teal); border: 1px solid rgba(79,195,176,0.3); }
  .banner-error { background: rgba(226,112,79,0.14); color: var(--coral); border: 1px solid rgba(226,112,79,0.3); }
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
  <h1>My profile</h1>
  <p class="sub">Manage your account details.</p>

  <% if (profileSuccess) { %><div class="banner banner-success">Profile updated.</div><% } %>
  <% if (profileError) { %><div class="banner banner-error">Please check your name and phone number (10 digits, starting 6-9).</div><% } %>
  <% if (pwSuccess) { %><div class="banner banner-success">Password changed.</div><% } %>
  <% if ("wrong".equals(pwError)) { %><div class="banner banner-error">Current password is incorrect.</div><% } %>
  <% if ("weak".equals(pwError)) { %><div class="banner banner-error">New password must be at least 8 characters.</div><% } %>

  <div class="section-title">Account details</div>
  <div class="form-card">
    <form action="UpdateProfileServlet" method="POST">
      <div class="field">
        <label for="email">Email</label>
        <input type="email" id="email" value="<%= email %>" disabled>
      </div>
      <div class="field">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" value="<%= name %>" required>
      </div>
      <div class="field">
        <label for="phone">Phone</label>
        <input type="text" id="phone" name="phone" value="<%= phone %>" required>
      </div>
      <button type="submit" class="submit">Save changes</button>
    </form>
  </div>

  <div class="section-title">Change password</div>
  <div class="form-card">
    <form action="ChangePasswordServlet" method="POST">
      <div class="field">
        <label for="currentPassword">Current password</label>
        <input type="password" id="currentPassword" name="currentPassword" required>
      </div>
      <div class="field">
        <label for="newPassword">New password <span style="font-weight:400; color:var(--muted); font-size:0.8rem;">(min 8 characters)</span></label>
        <input type="password" id="newPassword" name="newPassword" minlength="8" required>
      </div>
      <button type="submit" class="submit">Update password</button>
    </form>
  </div>
</main>

</body>
</html>
