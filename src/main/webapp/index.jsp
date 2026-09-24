<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Integer loggedInUserId = (Integer) session.getAttribute("userId");
    boolean isLoggedIn = (loggedInUserId != null);
    Boolean isAdminAttr = (Boolean) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);
    Boolean isVendorAttr = (Boolean) session.getAttribute("isVendor");
    boolean isVendor = (isVendorAttr != null && isVendorAttr);
    String vendorCtaLink = isVendor ? "my-vendor-listings.jsp" : (isLoggedIn ? "vendor-form.jsp" : "vendor-login.html");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Voyantra — AI Travel Planner</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600;9..144,700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">


<style>
  :root {
    --ink: #0D1526;
    --ink-2: #131F38;
    --ink-3: #1B2A45;
    --paper: #F6F2E9;
    --gold: #E7A94C;
    --gold-soft: rgba(231,169,76,0.14);
    --teal: #4FC3B0;
    --coral: #E2704F;
    --line: rgba(246,242,233,0.14);
    --line-strong: rgba(246,242,233,0.28);
    --muted: rgba(246,242,233,0.6);
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) {
    html { scroll-behavior: auto; }
    * { animation-duration: 0.001ms !important; transition-duration: 0.001ms !important; }
  }
  body { background: var(--ink); color: var(--paper); font-family: 'Inter', sans-serif; overflow-x: hidden; }
  a { color: inherit; text-decoration: none; }
  img, svg { display: block; }
  ::selection { background: var(--gold); color: var(--ink); }

  /* ============ LOGO ============ */
  .brand { display: flex; align-items: center; gap: 11px; }
  .brand-mark { width: 34px; height: 34px; flex-shrink: 0; }
  .brand-word {
    font-family: 'Fraunces', serif; font-weight: 600; font-size: 1.28rem; letter-spacing: -0.01em;
  }
  .brand-word .accent { color: var(--gold); font-weight: 500; font-style: italic; }

  /* ============ NAVBAR ============ */
  header {
    position: sticky; top: 0; z-index: 100;
    display: flex; align-items: center; justify-content: space-between;
    padding: 18px 6vw;
    background: rgba(13,21,38,0.72);
    backdrop-filter: blur(14px);
    border-bottom: 1px solid var(--line);
    transition: padding 0.3s ease, background 0.3s ease;
  }
  header.scrolled { padding: 12px 6vw; background: rgba(13,21,38,0.94); }
  nav.links { display: flex; gap: 8px; align-items: center; }
  nav.links a {
    font-size: 0.9rem; color: var(--muted); font-weight: 500;
    padding: 9px 16px; border-radius: 999px;
    transition: color 0.2s ease, background 0.2s ease;
  }
  nav.links a:hover { color: var(--paper); background: rgba(246,242,233,0.06); }
  nav.links a.active { color: var(--gold); }
  .nav-panel-head { display: none; }
  .nav-ic { display: none; }
  .mobile-only-link { display: none; }
  .nav-overlay { display: none; }
  .navactions { display: flex; gap: 12px; align-items: center; }
  .btn {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 11px 22px; border-radius: 999px;
    font-weight: 600; font-size: 0.88rem;
    transition: transform 0.25s cubic-bezier(.2,.8,.2,1), box-shadow 0.25s ease, background 0.25s ease;
    cursor: pointer; border: none;
  }
  .btn-primary { background: var(--gold); color: var(--ink); }
  .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 12px 26px rgba(231,169,76,0.3); }
  .btn-ghost { border: 1px solid var(--line-strong); color: var(--paper); background: transparent; }
  .btn-ghost:hover { border-color: var(--paper); background: rgba(246,242,233,0.05); }
  .burger { display: none; flex-direction: column; gap: 5px; background: none; border: none; cursor: pointer; padding: 6px; z-index: 120; }
  .burger span { width: 22px; height: 2px; background: var(--paper); border-radius: 2px; transition: 0.25s ease; }
  .burger.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
  .burger.open span:nth-child(2) { opacity: 0; }
  .burger.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }

  /* ============ HERO ============ */
  .hero {
    position: relative; z-index: 2;
    padding: 8vh 6vw 10vh;
    display: grid; grid-template-columns: 1.05fr 0.95fr; gap: 40px;
    align-items: center; min-height: 74vh;
  }
  .reveal { opacity: 0; transform: translateY(22px); transition: opacity 0.7s cubic-bezier(.2,.7,.2,1), transform 0.7s cubic-bezier(.2,.7,.2,1); }
  .reveal.in { opacity: 1; transform: translateY(0); }
  .eyebrow {
    display: inline-flex; align-items: center; gap: 10px;
    font-size: 0.76rem; letter-spacing: 0.14em; text-transform: uppercase;
    color: var(--gold); font-weight: 700; margin-bottom: 22px;
  }
  .eyebrow::before { content: ''; width: 26px; height: 1px; background: var(--gold); }
  .pulse-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--teal); position: relative; }
  .pulse-dot::after {
    content: ''; position: absolute; inset: -6px; border-radius: 50%; border: 1px solid var(--teal);
    animation: pulse 1.8s ease-out infinite;
  }
  @keyframes pulse { 0% { transform: scale(0.6); opacity: 0.8; } 100% { transform: scale(2.2); opacity: 0; } }
  @keyframes spin { to { transform: rotate(360deg); } }
  h1 {
    font-family: 'Fraunces', serif; font-weight: 500;
    font-size: clamp(2.3rem, 4.8vw, 4rem); line-height: 1.08; letter-spacing: -0.01em;
  }
  h1 em { font-style: italic; color: var(--gold); font-weight: 400; }
  .type-line { display: block; min-height: 1.2em; }
  .type-cursor {
    display: inline-block; width: 3px; height: 0.85em; background: var(--gold);
    margin-left: 4px; vertical-align: -0.1em; animation: blink 0.85s step-end infinite;
  }
  @keyframes blink { 50% { opacity: 0; } }
  .hero p.lead { margin-top: 24px; max-width: 46ch; font-size: 1.05rem; line-height: 1.65; color: var(--muted); }
  .hero-cta { margin-top: 36px; display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
  .hero-cta .btn-primary { padding: 15px 28px; font-size: 0.95rem; }
  .micro { margin-top: 24px; font-size: 0.82rem; color: var(--muted); display: flex; align-items: center; gap: 8px; }
  .live-badge {
    display: inline-flex; align-items: center; gap: 6px;
    font-size: 0.72rem; font-weight: 700; color: var(--teal);
    text-transform: uppercase; letter-spacing: 0.06em;
  }

  /* ============ Floating input flow visual ============ */
  .hero-visual {
    position: relative; z-index: 2;
    display: flex; flex-direction: column; align-items: center;
    gap: 0; padding: 10px 20px 0;
  }
  .flow-inputs {
    display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;
    margin-bottom: 6px;
  }
  .flow-chip {
    display: flex; align-items: center; gap: 9px;
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px;
    padding: 13px 17px; box-shadow: 0 14px 30px rgba(0,0,0,0.3);
    animation: floaty 4.5s ease-in-out infinite;
  }
  .flow-chip .ic {
    width: 30px; height: 30px; border-radius: 9px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: 0.95rem;
  }
  .flow-chip .txt .t { font-size: 0.82rem; font-weight: 700; }
  .flow-chip .txt .d { font-size: 0.72rem; color: var(--muted); }
  .flow-chip.c1 { animation-delay: 0s; }
  .flow-chip.c1 .ic { background: var(--gold-soft); color: var(--gold); }
  .flow-chip.c2 { animation-delay: 0.6s; }
  .flow-chip.c2 .ic { background: rgba(79,195,176,0.14); color: var(--teal); }
  .flow-chip.c3 { animation-delay: 1.2s; }
  .flow-chip.c3 .ic { background: rgba(226,112,79,0.14); color: var(--coral); }
  @keyframes floaty { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }

  .flow-lines { width: 100%; max-width: 320px; height: 60px; margin: -4px auto 0; }
  .flow-lines path {
    fill: none; stroke: var(--line-strong); stroke-width: 1.5; stroke-dasharray: 4 5;
    animation: dash 20s linear infinite;
  }
  @keyframes dash { to { stroke-dashoffset: -300; } }

  .flow-core {
    width: 64px; height: 64px; border-radius: 50%; margin: -6px auto 0;
    display: flex; align-items: center; justify-content: center;
    background: radial-gradient(circle at 35% 30%, rgba(231,169,76,0.22), transparent 65%), var(--ink-2);
    border: 1px solid var(--line); position: relative; z-index: 2;
    box-shadow: 0 0 0 6px rgba(231,169,76,0.06);
  }
  .flow-core svg { width: 28px; height: 28px; }
  .flow-core .ring {
    position: absolute; inset: -10px; border-radius: 50%;
    border: 1px dashed var(--line-strong); animation: spin 30s linear infinite;
  }

  .flow-output {
    margin-top: -2px;
    background: var(--ink-2); border: 1px solid rgba(231,169,76,0.35); border-radius: 16px;
    padding: 16px 20px; text-align: center; max-width: 280px;
    box-shadow: 0 18px 40px rgba(0,0,0,0.35);
  }
  .flow-output .k { font-size: 0.7rem; letter-spacing: 0.06em; text-transform: uppercase; color: var(--gold); font-weight: 700; }
  .flow-output .v { font-family: 'Fraunces', serif; font-size: 1.05rem; margin-top: 5px; }
  .hero-visual-line { font-size: 0.86rem; color: var(--muted); text-align: center; max-width: 32ch; margin-top: 18px; }
  .hero-visual-line strong { color: var(--paper); }


  /* ============ Section shell ============ */
  section { padding: 9vh 6vw; position: relative; z-index: 2; }
  .section-head { max-width: 640px; margin-bottom: 52px; }
  .kicker { font-size: 0.76rem; letter-spacing: 0.14em; text-transform: uppercase; color: var(--coral); font-weight: 700; margin-bottom: 14px; }
  h2 { font-family: 'Fraunces', serif; font-weight: 500; font-size: clamp(1.8rem, 3vw, 2.5rem); line-height: 1.15; }
  .section-head p { margin-top: 16px; color: var(--muted); font-size: 1rem; line-height: 1.6; }

  /* ============ About ============ */
  .about-grid { display: grid; grid-template-columns: 0.9fr 1.1fr; gap: 60px; align-items: center; }
  .about-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; margin-top: 28px; }
  .stat { background: var(--ink-2); border: 1px solid var(--line); border-radius: 14px; padding: 20px; }
  .stat .num { font-family: 'Fraunces', serif; font-size: 1.9rem; color: var(--gold); }
  .stat .lbl { font-size: 0.8rem; color: var(--muted); margin-top: 4px; }
  .about-copy p { color: var(--muted); font-size: 0.98rem; line-height: 1.7; margin-bottom: 16px; }

  /* ============ Steps ============ */
  .steps { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1px; background: var(--line); border: 1px solid var(--line); border-radius: 18px; overflow: hidden; }
  .step { background: var(--ink); padding: 32px 24px; transition: background 0.3s ease; }
  .step:hover { background: var(--ink-2); }
  .step .tag { font-family: 'Fraunces', serif; font-style: italic; color: var(--gold); font-size: 0.95rem; margin-bottom: 16px; display: block; }
  .step h3 { font-size: 1.04rem; font-weight: 600; margin-bottom: 8px; }
  .step p { font-size: 0.88rem; color: var(--muted); line-height: 1.55; }

  /* ============ Features ============ */
  .features { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
  .feature {
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 16px; padding: 28px 24px;
    transition: border-color 0.25s ease, transform 0.25s ease, background 0.25s ease;
  }
  .feature:hover { border-color: rgba(231,169,76,0.4); transform: translateY(-4px); background: var(--ink-3); }
  .feature .icon {
    width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
    background: var(--gold-soft); color: var(--gold); margin-bottom: 16px; font-size: 1.1rem;
    transition: transform 0.25s ease;
  }
  .feature:hover .icon { transform: scale(1.1) rotate(-6deg); }
  .feature h3 { font-size: 1.02rem; font-weight: 600; margin-bottom: 8px; }
  .feature p { font-size: 0.88rem; color: var(--muted); line-height: 1.55; }

  /* ============ Contact ============ */
  .contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 50px; }
  .contact-info { display: flex; flex-direction: column; gap: 20px; }
  .contact-row { display: flex; gap: 14px; align-items: flex-start; }
  .contact-row .ic {
    width: 38px; height: 38px; border-radius: 10px; background: var(--gold-soft); color: var(--gold);
    display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 1rem;
  }
  .contact-row .t { font-size: 0.92rem; font-weight: 600; }
  .contact-row .d { font-size: 0.86rem; color: var(--muted); margin-top: 2px; }
  .contact-form { display: flex; flex-direction: column; gap: 14px; }
  .contact-form input, .contact-form textarea {
    width: 100%; padding: 13px 15px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-2); color: var(--paper); font-family: inherit; font-size: 0.9rem; resize: vertical;
  }
  .contact-form input:focus, .contact-form textarea:focus { outline: none; border-color: var(--gold); }

  /* ============ CTA band ============ */
  .cta-band {
    margin: 4vh 6vw 10vh;
    background: linear-gradient(120deg, var(--ink-3), var(--ink) 70%);
    border: 1px solid var(--line); border-radius: 22px; padding: 60px 6vw; text-align: center;
    position: relative; overflow: hidden; z-index: 2;
  }
  .cta-band h2 { max-width: 620px; margin: 0 auto 16px; }
  .cta-band p { color: var(--muted); max-width: 460px; margin: 0 auto 28px; }

  footer {
    padding: 40px 6vw 46px; border-top: 1px solid var(--line); z-index: 2; position: relative;
    display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;
  }
  footer .f-links { display: flex; gap: 22px; font-size: 0.85rem; color: var(--muted); }
  footer .f-links a:hover { color: var(--gold); }
  footer .f-bottom { font-size: 0.82rem; color: var(--muted); }

  /* ============ AI Assistant widget ============ */
  .ai-fab {
    position: fixed; right: 26px; bottom: 26px; z-index: 200;
    width: 58px; height: 58px; border-radius: 50%;
    background: linear-gradient(135deg, var(--gold), var(--coral));
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; border: none;
    box-shadow: 0 12px 30px rgba(231,169,76,0.35);
    transition: transform 0.25s cubic-bezier(.2,.8,.2,1);
  }
  .ai-fab:hover { transform: scale(1.08); }
  .ai-fab svg { width: 26px; height: 26px; }
  .ai-fab .ping { position: absolute; inset: 0; border-radius: 50%; border: 2px solid var(--gold); animation: pulse 2.2s ease-out infinite; }
  .ai-panel {
    position: fixed; right: 26px; bottom: 96px; z-index: 200;
    width: 330px; max-width: calc(100vw - 40px);
    background: var(--ink-2); border: 1px solid var(--line); border-radius: 18px; overflow: hidden;
    box-shadow: 0 30px 70px rgba(0,0,0,0.5);
    transform: translateY(16px) scale(0.97); opacity: 0; pointer-events: none;
    transition: transform 0.25s cubic-bezier(.2,.8,.2,1), opacity 0.25s ease;
  }
  .ai-panel.open { transform: translateY(0) scale(1); opacity: 1; pointer-events: auto; }
  .ai-head { display: flex; align-items: center; gap: 10px; padding: 16px 18px; border-bottom: 1px solid var(--line); background: var(--ink-3); }
  .ai-head .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--teal); }
  .ai-head .name { font-weight: 700; font-size: 0.9rem; }
  .ai-head .status { font-size: 0.74rem; color: var(--muted); }
  .ai-close { margin-left: auto; background: none; border: none; color: var(--muted); cursor: pointer; font-size: 1rem; }
  .ai-body { padding: 16px 18px; display: flex; flex-direction: column; gap: 12px; max-height: 300px; overflow-y: auto; }
  .ai-msg { font-size: 0.86rem; line-height: 1.5; max-width: 88%; padding: 10px 13px; border-radius: 12px; }
  .ai-msg.bot { background: var(--ink-3); align-self: flex-start; border-bottom-left-radius: 4px; }
  .ai-msg.user { background: var(--gold-soft); color: var(--paper); align-self: flex-end; border-bottom-right-radius: 4px; }
  .ai-chips { display: flex; flex-wrap: wrap; gap: 8px; padding: 0 18px 16px; }
  .ai-chip {
    font-size: 0.78rem; padding: 8px 12px; border-radius: 999px;
    border: 1px solid var(--line-strong); color: var(--paper); background: transparent;
    cursor: pointer; transition: all 0.2s ease;
  }
  .ai-chip:hover { border-color: var(--gold); color: var(--gold); }
  .ai-input-row { display: flex; gap: 8px; padding: 12px 16px 16px; border-top: 1px solid var(--line); }
  .ai-input-row input {
    flex: 1; padding: 11px 13px; border-radius: 10px; border: 1px solid var(--line-strong);
    background: var(--ink-3); color: var(--paper); font-family: inherit; font-size: 0.86rem;
  }
  .ai-input-row input:focus { outline: none; border-color: var(--gold); }
  .ai-send {
    width: 40px; height: 40px; border-radius: 10px; border: none; cursor: pointer;
    background: var(--gold); color: var(--ink); font-size: 1rem; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; transition: transform 0.2s ease;
  }
  .ai-send:hover { transform: scale(1.06); }
  .typing { display: flex; gap: 4px; align-self: flex-start; padding: 10px 13px; background: var(--ink-3); border-radius: 12px; border-bottom-left-radius: 4px; }
  .typing span { width: 6px; height: 6px; border-radius: 50%; background: var(--muted); animation: bounce 1.2s infinite; }
  .typing span:nth-child(2) { animation-delay: 0.15s; }
  .typing span:nth-child(3) { animation-delay: 0.3s; }
  @keyframes bounce { 0%,60%,100% { transform: translateY(0); opacity:0.5; } 30% { transform: translateY(-4px); opacity:1; } }

  /* ============ RESPONSIVE ============ */
  @media (max-width: 1024px) {
    .about-grid, .contact-grid { grid-template-columns: 1fr; gap: 34px; }
  }
  @media (max-width: 900px) {
    .hero { grid-template-columns: 1fr; padding-top: 5vh; text-align: left; }
    .hero-visual { padding: 10px; }
    .steps { grid-template-columns: 1fr 1fr; }
    .features { grid-template-columns: 1fr; }
    .about-stats { grid-template-columns: 1fr 1fr; }
  }
  @media (max-width: 720px) {
    .nav-overlay {
      display: block;
      position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 105;
      opacity: 0; pointer-events: none; transition: opacity 0.3s ease;
    }
    .nav-overlay.open { opacity: 1; pointer-events: auto; }
    nav.links {
      position: fixed; top: 0; right: 0; bottom: 0; width: 82vw; max-width: 340px;
      background: var(--ink-2); border-left: 1px solid var(--line);
      flex-direction: column; align-items: stretch; gap: 0; padding: 0;
      transform: translateX(100%); transition: transform 0.35s cubic-bezier(.2,.8,.2,1); z-index: 110;
      overflow-y: auto;
    }
    nav.links.open { transform: translateX(0); }
    .nav-panel-head { display: flex; align-items: center; justify-content: space-between;
      padding: 14px 18px; border-bottom: 1px solid var(--line); }
    .nav-close {
      width: 30px; height: 30px; border-radius: 50%; border: 1px solid var(--line-strong);
      background: none; color: var(--paper); display: flex; align-items: center; justify-content: center;
      cursor: pointer; font-size: 0.9rem; flex-shrink: 0;
    }
    .nav-close:hover { border-color: var(--coral); color: var(--coral); }
    nav.links a {
      display: flex; align-items: center; gap: 12px;
      font-size: 0.92rem; padding: 11px 18px; border-bottom: 1px solid var(--line);
      border-radius: 0; width: 100%; line-height: 1.2;
    }
    nav.links a .nav-ic {
      display: flex; width: 17px; height: 17px; flex-shrink: 0; align-items: center; justify-content: center;
      color: var(--gold);
    }
    nav.links a .nav-ic svg { width: 16px; height: 16px; }
    .mobile-only-link { display: flex; }
    nav.links a:hover { background: rgba(246,242,233,0.05); }
    nav.links a.active { color: var(--gold); background: var(--gold-soft); }
    .burger { display: flex; }
    .burger.open { visibility: hidden; }
    .navactions .btn-ghost { display: none; }
    .lang-slot { display: none; }
    .steps { grid-template-columns: 1fr; }
    footer { flex-direction: column; align-items: flex-start; }
  }
  @media (max-width: 420px) {
    .flow-chip { padding: 10px 13px; }
    .flow-core { width: 50px; height: 50px; }
    .flow-core svg { width: 22px; height: 22px; }
    section { padding: 7vh 6vw; }
  }
</style>
</head>
<body>

<header id="hdr">
  <a href="index.jsp" class="brand">
    <svg class="brand-mark" viewBox="0 0 40 40" fill="none">
      <circle cx="20" cy="20" r="18.5" stroke="#E7A94C" stroke-width="1.4" opacity="0.4"/>
      <path d="M20 5 L24.5 17.5 L20 20 L15.5 17.5 Z" fill="#E7A94C"/>
      <path d="M20 35 L15.5 22.5 L20 20 L24.5 22.5 Z" fill="#F6F2E9" opacity="0.85"/>
      <circle cx="20" cy="20" r="3" fill="#0D1526" stroke="#E7A94C" stroke-width="1.4"/>
    </svg>
    <span class="brand-word">Voy<span class="accent">antra</span></span>
  </a>

  <div class="nav-overlay" id="navOverlay"></div>
  <nav class="links" id="navlinks">
    <div class="nav-panel-head">
      <span class="brand-word" style="font-size:1.05rem;">Voy<span class="accent">antra</span></span>
      <button class="nav-close" id="navClose" aria-label="Close menu">✕</button>
    </div>
    <a href="#home" class="active">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></svg></span>
      <span data-i18n="nav_home">Home</span>
    </a>
    <a href="#about">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 16v-4M12 8h.01"/></svg></span>
      <span data-i18n="nav_about">About Us</span>
    </a>
    <a href="#how">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.6 1.6 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.6 1.6 0 00-1.8-.3 1.6 1.6 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.6 1.6 0 00-1-1.5 1.6 1.6 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.6 1.6 0 00.3-1.8 1.6 1.6 0 00-1.5-1H3a2 2 0 110-4h.1a1.6 1.6 0 001.5-1 1.6 1.6 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.6 1.6 0 001.8.3H9a1.6 1.6 0 001-1.5V3a2 2 0 114 0v.1a1.6 1.6 0 001 1.5 1.6 1.6 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.6 1.6 0 00-.3 1.8V9a1.6 1.6 0 001.5 1H21a2 2 0 110 4h-.1a1.6 1.6 0 00-1.5 1z"/></svg></span>
      <span data-i18n="nav_how">How It Works</span>
    </a>
    <a href="#features">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="14" rx="2"/><path d="M3 9h18M9 21v-3M15 21v-3"/></svg></span>
      <span data-i18n="nav_features">Features</span>
    </a>
    <a href="vendor-form.jsp">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l1-5h16l1 5"/><path d="M4 9v10h16V9"/><path d="M9 21v-6h6v6"/></svg></span>
      <span data-i18n="nav_vendors">Local Vendors</span>
    </a>
    <a href="#contact">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg></span>
      <span data-i18n="nav_contact">Contact Us</span>
    </a>
    <a href="login.html" class="mobile-only-link">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><path d="M10 17l5-5-5-5"/><path d="M15 12H3"/></svg></span>
      <span data-i18n="nav_login">Log in</span>
    </a>
    <a href="register.html" class="mobile-only-link">
      <span class="nav-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"/><path d="M3 20c0-3.5 2.7-6 6-6s6 2.5 6 6"/><path d="M17 8h4M19 6v4"/></svg></span>
      <span data-i18n="nav_getstarted">Get Started</span>
    </a>
  </nav>

  <div class="navactions">
    <div id="langSwitcherSlot" class="lang-slot"></div>
    <% if (isLoggedIn) { %>
    <% if (isAdmin) { %><a href="admin-dashboard.jsp" class="btn btn-ghost" data-i18n="nav_admin">Admin</a><% } %>
    <a href="dashboard.jsp" class="btn btn-ghost" data-i18n="nav_dashboard">Dashboard</a>
    <a href="LogoutServlet" class="btn btn-primary" data-i18n="nav_logout">Log out</a>
<% } else { %>
    <a href="login.html" class="btn btn-ghost" data-i18n="nav_login">Log in</a>
    <a href="register.html" class="btn btn-primary" data-i18n="nav_getstarted">Get Started</a>
<% } %>
    <button class="burger" id="burger" aria-label="Menu"><span></span><span></span><span></span></button>
  </div>
</header>

<section class="hero" id="home">
  <div class="reveal in">
    <div class="eyebrow"><span class="pulse-dot"></span><span data-i18n="hero_eyebrow">AI-planned, budget-first</span></div>
    <h1>Say your budget.<br><span class="type-line">Get a <em id="typeWord">finished itinerary</em><span class="type-cursor"></span>.</span></h1>
    <p class="lead" data-i18n="hero_lead">Tell us your budget, your days, and what you're into — we'll lay out the whole trip, day by day: stays, food, activities and weather, all sequenced for you.</p>
    <p class="lead" style="font-size:0.94rem; color:var(--muted);" data-i18n="hero_marketplace">New: discover and contact real local homestays, guides, transport and restaurants — verified, reviewed, and woven right into your itinerary.</p>
    <div class="hero-cta">
      <a href="<%= isLoggedIn ? "trip-form.html" : "register.html" %>" class="btn btn-primary" data-i18n="hero_cta_primary">Plan my trip →</a>
      <a href="#how" class="btn btn-ghost" data-i18n="hero_cta_secondary">See how it works</a>
    </div>
    <div class="micro"><span class="live-badge"><span class="pulse-dot"></span>AI</span> <span data-i18n="hero_micro">One form in, one complete day-wise plan out</span></div>
  </div>

  <div class="hero-visual reveal in" style="transition-delay:0.1s">
    <div class="flow-inputs">
      <div class="flow-chip c1">
        <div class="ic">₹</div>
        <div class="txt"><div class="t" data-i18n="chip_budget_t">Budget</div><div class="d" data-i18n="chip_budget_d">Any amount</div></div>
      </div>
      <div class="flow-chip c2">
        <div class="ic">◷</div>
        <div class="txt"><div class="t" data-i18n="chip_days_t">Days</div><div class="d" data-i18n="chip_days_d">Any length</div></div>
      </div>
      <div class="flow-chip c3">
        <div class="ic">♥</div>
        <div class="txt"><div class="t" data-i18n="chip_style_t">Style</div><div class="d" data-i18n="chip_style_d">Solo · family</div></div>
      </div>
    </div>

    <svg class="flow-lines" viewBox="0 0 320 60" preserveAspectRatio="none">
      <path d="M 60 0 C 60 30, 150 20, 160 40"/>
      <path d="M 160 0 C 160 20, 160 25, 160 40"/>
      <path d="M 260 0 C 260 30, 170 20, 160 40"/>
    </svg>

    <div class="flow-core">
      <span class="ring"></span>
      <svg viewBox="0 0 40 40" fill="none">
        <path d="M20 5 L24.5 17.5 L20 20 L15.5 17.5 Z" fill="#E7A94C"/>
        <path d="M20 35 L15.5 22.5 L20 20 L24.5 22.5 Z" fill="#F6F2E9" opacity="0.85"/>
        <circle cx="20" cy="20" r="3" fill="#0D1526" stroke="#E7A94C" stroke-width="1.4"/>
      </svg>
    </div>

    <svg class="flow-lines" viewBox="0 0 320 40" preserveAspectRatio="none" style="height:34px;">
      <path d="M 160 0 L 160 34"/>
    </svg>

    <div class="flow-output">
      <div class="k" data-i18n="hero_output_label">Output</div>
      <div class="v" data-i18n="hero_output_value">A complete day-wise itinerary</div>
    </div>

    <p class="hero-visual-line" data-i18n="hero_visual_line">You set the shape of the trip. <strong>The AI fills in the rest</strong> — stays, food and activities, day by day.</p>
  </div>
</section>

<section id="about">
  <div class="about-grid">
    <div class="reveal">
      <div class="kicker" data-i18n="about_kicker">About us</div>
      <h2 data-i18n="about_heading">We think travel planning should take minutes, not evenings.</h2>
      <div class="about-stats">
        <div class="stat"><div class="num">4</div><div class="lbl" data-i18n="about_stat1">inputs needed to start</div></div>
        <div class="stat"><div class="num">100%</div><div class="lbl" data-i18n="about_stat2">AI-generated, day by day</div></div>
        <div class="stat"><div class="num">2-sided</div><div class="lbl" data-i18n="about_stat3">travellers + local vendors, one platform</div></div>
      </div>
    </div>
    <div class="about-copy reveal" style="transition-delay:0.1s">
      <p data-i18n="about_p1">Voyantra plans your trip and hands you a finished itinerary. Tell us your budget, how many days you have, who you're travelling with, and what you enjoy — our AI lays out stays, food, activities and weather, sequenced day by day.</p>
      <p data-i18n="about_p2">And it doesn't stop at a plan on paper. Voyantra is also a marketplace for local homestays, guides, transport and restaurants — real businesses you can browse, review, and contact directly, approved by our team so you know they're genuine.</p>
      <p data-i18n="about_p3">Everything in one place: a complete trip plan, and the real people who'll make it happen — ready whenever you are.</p>
    </div>
  </div>
</section>

<section id="how">
  <div class="section-head reveal">
    <div class="kicker" data-i18n="how_kicker">How it works</div>
    <h2 data-i18n="how_heading">Four inputs. One complete plan.</h2>
    <p data-i18n="how_sub">Everything downstream — hotels, food, activities, weather — is generated from what you tell us up front.</p>
  </div>
  <div class="steps reveal">
    <div class="step"><span class="tag">01</span><h3 data-i18n="step1_t">Set your budget</h3><p data-i18n="step1_d">Total spend for the trip. Every suggestion after this is built to fit inside it.</p></div>
    <div class="step"><span class="tag">02</span><h3 data-i18n="step2_t">Pick your days</h3><p data-i18n="step2_d">How long you're travelling — from a quick weekend to a two-week trip.</p></div>
    <div class="step"><span class="tag">03</span><h3 data-i18n="step3_t">Tell us the style</h3><p data-i18n="step3_d">Solo, family, or with friends. It shapes the pace and the stays we suggest.</p></div>
    <div class="step"><span class="tag">04</span><h3 data-i18n="step4_t">Get your itinerary</h3><p data-i18n="step4_d">A day-by-day plan with food, stays and things to do — ready to save or download.</p></div>
  </div>
  <p class="reveal" style="text-align:center; color:var(--muted); font-size:0.94rem; margin-top:24px;" data-i18n="how_vendor_note">Then browse real local vendors near your destination — homestays, guides, restaurants — and contact them directly from your itinerary.</p>
</section>

<section id="features">
  <div class="section-head reveal">
    <div class="kicker" data-i18n="features_kicker">What you get</div>
    <h2 data-i18n="features_heading">Built around the trip, not the booking.</h2>
    <p data-i18n="features_sub">A complete plan, and the real local businesses to go with it.</p>
  </div>
  <div class="features">
    <div class="feature reveal"><div class="icon">$</div><h3 data-i18n="feat1_t">Budget-aware suggestions</h3><p data-i18n="feat1_d">Hotels, food and activities are picked to fit inside what you set.</p></div>
    <div class="feature reveal" style="transition-delay:0.05s"><div class="icon">☀</div><h3 data-i18n="feat2_t">Weather, built in</h3><p data-i18n="feat2_d">See the forecast for each day of your trip before you pack a bag.</p></div>
    <div class="feature reveal" style="transition-delay:0.1s"><div class="icon">▤</div><h3 data-i18n="feat3_t">Day-by-day structure</h3><p data-i18n="feat3_d">An actual sequence, so you know what happens on Day 2 versus Day 4.</p></div>
    <div class="feature reveal" style="transition-delay:0.15s"><div class="icon">▶</div><h3 data-i18n="feat4_t">See it before you go</h3><p data-i18n="feat4_d">Photos and short videos of your destinations, alongside the plan.</p></div>
    <div class="feature reveal" style="transition-delay:0.2s"><div class="icon">⬇</div><h3 data-i18n="feat5_t">Download as PDF</h3><p data-i18n="feat5_d">Keep a copy of your itinerary offline — no signal required on arrival.</p></div>
    <div class="feature reveal" style="transition-delay:0.25s"><div class="icon">✎</div><h3 data-i18n="feat6_t">Edit anytime</h3><p data-i18n="feat6_d">Plans change. Come back and adjust any day whenever you need to.</p></div>
    <div class="feature reveal" style="transition-delay:0.3s; border-color:rgba(79,195,176,0.25);"><div class="icon" style="color:var(--teal);">⌂</div><h3 data-i18n="feat7_t">Real local vendors</h3><p data-i18n="feat7_d">Homestays, guides, transport and restaurants near your destination — approved by our team, not AI guesses.</p></div>
    <div class="feature reveal" style="transition-delay:0.35s; border-color:rgba(79,195,176,0.25);"><div class="icon" style="color:var(--teal);">★</div><h3 data-i18n="feat8_t">Reviews you can trust</h3><p data-i18n="feat8_d">Ratings from real travellers, plus Verified and Top Rated badges — know before you contact a vendor.</p></div>
    <div class="feature reveal" style="transition-delay:0.4s; border-color:rgba(79,195,176,0.25);"><div class="icon" style="color:var(--teal);">⑂</div><h3 data-i18n="feat9_t">Food that fits your diet</h3><p data-i18n="feat9_d">Vegetarian or non-vegetarian — get restaurant picks with real distance and their signature dish.</p></div>
  </div>
</section>

<div class="cta-band reveal" style="border-color:rgba(79,195,176,0.3); margin-top:0;">
  <div class="kicker" style="color:var(--teal);" data-i18n="vendor_cta_kicker">For local businesses</div>
  <h2 data-i18n="vendor_cta_heading">Run a homestay, guide tours, or cook amazing food?</h2>
  <p data-i18n="vendor_cta_sub">List your business on Voyantra for free and get discovered by travellers planning their trip — approved by our team, reviewed by real guests.</p>
  <a href="<%= vendorCtaLink %>" class="btn btn-primary" style="background:var(--teal);" data-i18n="vendor_cta_button">List your business →</a>
</div>

<section id="contact">
  <div class="section-head reveal">
    <div class="kicker" data-i18n="contact_kicker">Contact</div>
    <h2 data-i18n="contact_heading">Questions before you start planning?</h2>
    <p data-i18n="contact_sub">Reach out and we'll get back to you.</p>
  </div>
  <div class="contact-grid">
    <div class="contact-info reveal">
      <div class="contact-row"><div class="ic">@</div><div><div class="t" data-i18n="contact_email_l">Email</div><div class="d">support@voyantra.app</div></div></div>
      <div class="contact-row"><div class="ic">☎</div><div><div class="t" data-i18n="contact_phone_l">Phone</div><div class="d">+91 00000 00000</div></div></div>
      <div class="contact-row"><div class="ic">📍</div><div><div class="t" data-i18n="contact_based_l">Based in</div><div class="d">Puducherry, India</div></div></div>
    </div>
    <form class="contact-form reveal" style="transition-delay:0.1s" onsubmit="event.preventDefault(); alert('Frontend demo — connect this to a ContactServlet to actually send messages.');">
      <input type="text" placeholder="Your name" data-i18n-placeholder="contact_name_ph" required>
      <input type="email" placeholder="Your email" data-i18n-placeholder="contact_email_ph" required>
      <textarea rows="4" placeholder="Your message" data-i18n-placeholder="contact_msg_ph" required></textarea>
      <button type="submit" class="btn btn-primary" style="justify-content:center;" data-i18n="contact_send">Send message</button>
    </form>
  </div>
</section>

<div class="cta-band reveal">
  <h2 data-i18n="cta_heading">Your next trip is one form away.</h2>
  <p data-i18n="cta_sub">Set a budget, pick your days, and let the plan build itself.</p>
  <a href="<%= isLoggedIn ? "trip-form.html" : "register.html" %>" class="btn btn-primary" data-i18n="cta_button">Start planning free →</a>
</div>

<footer>
  <a href="index.jsp" class="brand">
    <svg class="brand-mark" viewBox="0 0 40 40" fill="none" style="width:26px;height:26px;">
      <circle cx="20" cy="20" r="18.5" stroke="#E7A94C" stroke-width="1.4" opacity="0.4"/>
      <path d="M20 5 L24.5 17.5 L20 20 L15.5 17.5 Z" fill="#E7A94C"/>
      <path d="M20 35 L15.5 22.5 L20 20 L24.5 22.5 Z" fill="#F6F2E9" opacity="0.85"/>
      <circle cx="20" cy="20" r="3" fill="#0D1526" stroke="#E7A94C" stroke-width="1.4"/>
    </svg>
    <span class="brand-word" style="font-size:1.05rem;">Voy<span class="accent">antra</span></span>
  </a>
  <div class="f-links">
    <a href="#home" data-i18n="nav_home">Home</a><a href="#about" data-i18n="nav_about">About</a><a href="#features" data-i18n="nav_features">Features</a><a href="vendors.jsp" data-i18n="nav_vendors">Local Vendors</a><a href="#contact" data-i18n="nav_contact">Contact</a>
  </div>
  <div class="f-bottom" data-i18n="footer_note">Plan the trip. Find the people who make it real.</div>
</footer>

<script src="js/i18n.js?v=3"></script>
<script src="js/chatbot.js?v=3"></script>
<script>
  // typewriter headline
  const typeEl = document.getElementById('typeWord');
  const typeWords = ['finished itinerary', 'day-by-day plan', 'budget-fit trip', 'personalized route'];
  let twIndex = 0, twChar = 0, twDeleting = false;
  function typeTick() {
    const word = typeWords[twIndex];
    if (!twDeleting) {
      twChar++;
      typeEl.textContent = word.slice(0, twChar);
      if (twChar === word.length) { twDeleting = true; setTimeout(typeTick, 1600); return; }
      setTimeout(typeTick, 55);
    } else {
      twChar--;
      typeEl.textContent = word.slice(0, twChar);
      if (twChar === 0) { twDeleting = false; twIndex = (twIndex + 1) % typeWords.length; setTimeout(typeTick, 300); return; }
      setTimeout(typeTick, 30);
    }
  }
  if (typeEl) { typeEl.textContent = ''; setTimeout(typeTick, 900); }

  const hdr = document.getElementById('hdr');
  window.addEventListener('scroll', () => hdr.classList.toggle('scrolled', window.scrollY > 20), { passive: true });

  const burger = document.getElementById('burger');
  const navlinks = document.getElementById('navlinks');
  const navOverlay = document.getElementById('navOverlay');
  const navClose = document.getElementById('navClose');
  function openMenu() { burger.classList.add('open'); navlinks.classList.add('open'); navOverlay.classList.add('open'); }
  function closeMenu() { burger.classList.remove('open'); navlinks.classList.remove('open'); navOverlay.classList.remove('open'); }
  burger.addEventListener('click', () => navlinks.classList.contains('open') ? closeMenu() : openMenu());
  navClose.addEventListener('click', closeMenu);
  navOverlay.addEventListener('click', closeMenu);
  navlinks.querySelectorAll('a').forEach(a => a.addEventListener('click', closeMenu));

  const revealEls = document.querySelectorAll('.reveal');
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => { if (entry.isIntersecting) { entry.target.classList.add('in'); io.unobserve(entry.target); } });
  }, { threshold: 0.15 });
  revealEls.forEach(el => io.observe(el));

  // active nav link on scroll
  const sections = ['home','about','how','features','contact'].map(id => document.getElementById(id));
  const navA = document.querySelectorAll('nav.links a');
  const navIO = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        navA.forEach(a => a.classList.toggle('active', a.getAttribute('href') === '#' + entry.target.id));
      }
    });
  }, { threshold: 0.5 });
  sections.forEach(s => s && navIO.observe(s));
</script>

</body>
</html>