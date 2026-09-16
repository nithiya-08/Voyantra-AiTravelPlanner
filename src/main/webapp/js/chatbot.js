/*
 * Voyantra site-wide AI chatbot. Include with <script src="js/chatbot.js"></script>
 * on any page. It injects its own markup/styles (matching the site's existing
 * --ink/--gold/etc. theme variables) and talks to ChatbotServlet, which calls
 * Gemini. If the current page URL has ?tripId=NN, the servlet includes that
 * trip's details in the prompt so the assistant can answer trip-specific
 * questions ("what should I pack for day 2?").
 */
(function () {
  var STYLE = '' +
    '.vy-ai-fab { position: fixed; right: 26px; bottom: 26px; z-index: 300; width: 58px; height: 58px; ' +
    '  border-radius: 50%; background: linear-gradient(135deg, var(--gold, #E7A94C), var(--coral, #E2704F)); ' +
    '  display: flex; align-items: center; justify-content: center; cursor: pointer; border: none; ' +
    '  box-shadow: 0 12px 30px rgba(231,169,76,0.35); transition: transform 0.25s cubic-bezier(.2,.8,.2,1); }' +
    '.vy-ai-fab:hover { transform: scale(1.08); }' +
    '.vy-ai-fab svg { width: 26px; height: 26px; }' +
    '.vy-ai-panel { position: fixed; right: 26px; bottom: 96px; z-index: 300; width: 330px; max-width: calc(100vw - 40px); ' +
    '  background: var(--ink-2, #131F38); border: 1px solid var(--line, rgba(246,242,233,0.14)); border-radius: 18px; overflow: hidden; ' +
    '  box-shadow: 0 30px 70px rgba(0,0,0,0.5); transform: translateY(16px) scale(0.97); opacity: 0; pointer-events: none; ' +
    '  transition: transform 0.25s cubic-bezier(.2,.8,.2,1), opacity 0.25s ease; font-family: Inter, sans-serif; }' +
    '.vy-ai-panel.open { transform: translateY(0) scale(1); opacity: 1; pointer-events: auto; }' +
    '.vy-ai-head { display: flex; align-items: center; gap: 10px; padding: 16px 18px; border-bottom: 1px solid var(--line, rgba(246,242,233,0.14)); background: var(--ink-3, #1B2A45); }' +
    '.vy-ai-head .vy-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--teal, #4FC3B0); }' +
    '.vy-ai-head .vy-name { font-weight: 700; font-size: 0.9rem; color: var(--paper, #F6F2E9); }' +
    '.vy-ai-head .vy-status { font-size: 0.74rem; color: var(--muted, rgba(246,242,233,0.6)); }' +
    '.vy-ai-close { margin-left: auto; background: none; border: none; color: var(--muted, rgba(246,242,233,0.6)); cursor: pointer; font-size: 1rem; }' +
    '.vy-ai-body { padding: 16px 18px; display: flex; flex-direction: column; gap: 12px; max-height: 320px; overflow-y: auto; }' +
    '.vy-ai-msg { font-size: 0.86rem; line-height: 1.5; max-width: 88%; padding: 10px 13px; border-radius: 12px; white-space: pre-wrap; }' +
    '.vy-ai-msg.bot { background: var(--ink-3, #1B2A45); align-self: flex-start; border-bottom-left-radius: 4px; color: var(--paper, #F6F2E9); }' +
    '.vy-ai-msg.user { background: var(--gold-soft, rgba(231,169,76,0.14)); color: var(--paper, #F6F2E9); align-self: flex-end; border-bottom-right-radius: 4px; }' +
    '.vy-ai-input-row { display: flex; gap: 8px; padding: 12px 16px 16px; border-top: 1px solid var(--line, rgba(246,242,233,0.14)); }' +
    '.vy-ai-input-row input { flex: 1; padding: 11px 13px; border-radius: 10px; border: 1px solid var(--line-strong, rgba(246,242,233,0.28)); ' +
    '  background: var(--ink-3, #1B2A45); color: var(--paper, #F6F2E9); font-family: inherit; font-size: 0.86rem; }' +
    '.vy-ai-input-row input:focus { outline: none; border-color: var(--gold, #E7A94C); }' +
    '.vy-ai-send { width: 40px; height: 40px; border-radius: 10px; border: none; cursor: pointer; ' +
    '  background: var(--gold, #E7A94C); color: var(--ink, #0D1526); font-size: 1rem; flex-shrink: 0; ' +
    '  display: flex; align-items: center; justify-content: center; }' +
    '.vy-typing { display: flex; gap: 4px; align-self: flex-start; padding: 10px 13px; background: var(--ink-3, #1B2A45); border-radius: 12px; border-bottom-left-radius: 4px; }' +
    '.vy-typing span { width: 6px; height: 6px; border-radius: 50%; background: var(--muted, rgba(246,242,233,0.6)); animation: vyBounce 1.2s infinite; }' +
    '.vy-typing span:nth-child(2) { animation-delay: 0.15s; } .vy-typing span:nth-child(3) { animation-delay: 0.3s; }' +
    '@keyframes vyBounce { 0%,60%,100% { transform: translateY(0); opacity:0.5; } 30% { transform: translateY(-4px); opacity:1; } }';

  function injectOnce() {
    if (document.getElementById('vyAiFab')) return;

    var styleTag = document.createElement('style');
    styleTag.textContent = STYLE;
    document.head.appendChild(styleTag);

    var fab = document.createElement('button');
    fab.className = 'vy-ai-fab';
    fab.id = 'vyAiFab';
    fab.setAttribute('aria-label', 'Ask the Voyantra assistant');
    fab.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="#0D1526" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
      '<path d="M12 2 L14.2 8.2 L20.5 10 L14.2 11.8 L12 18 L9.8 11.8 L3.5 10 L9.8 8.2 Z"/></svg>';

    var panel = document.createElement('div');
    panel.className = 'vy-ai-panel';
    panel.id = 'vyAiPanel';
    panel.innerHTML =
      '<div class="vy-ai-head"><span class="vy-dot"></span>' +
      '<div><div class="vy-name">Voyantra Assistant</div><div class="vy-status">Ask about the site or your trip</div></div>' +
      '<button class="vy-ai-close" id="vyAiClose">✕</button></div>' +
      '<div class="vy-ai-body" id="vyAiBody">' +
      '<div class="vy-ai-msg bot">Hi! I can help with anything about Voyantra, or answer questions about a trip you\'re viewing. What would you like to know?</div>' +
      '</div>' +
      '<form class="vy-ai-input-row" id="vyAiForm">' +
      '<input type="text" id="vyAiInput" placeholder="Type your question..." autocomplete="off">' +
      '<button type="submit" class="vy-ai-send" aria-label="Send">➤</button></form>';

    document.body.appendChild(fab);
    document.body.appendChild(panel);

    var body = document.getElementById('vyAiBody');
    var form = document.getElementById('vyAiForm');
    var input = document.getElementById('vyAiInput');
    var history = [];

    function toggle() { panel.classList.toggle('open'); if (panel.classList.contains('open')) input.focus(); }
    fab.addEventListener('click', toggle);
    document.getElementById('vyAiClose').addEventListener('click', function () { panel.classList.remove('open'); });

    function addMsg(text, who) {
      var div = document.createElement('div');
      div.className = 'vy-ai-msg ' + who;
      div.textContent = text;
      body.appendChild(div);
      body.scrollTop = body.scrollHeight;
    }

    function getTripId() {
      var params = new URLSearchParams(window.location.search);
      return params.get('tripId') || '';
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var text = input.value.trim();
      if (!text) return;
      addMsg(text, 'user');
      history.push({ role: 'user', text: text });
      input.value = '';

      var typing = document.createElement('div');
      typing.className = 'vy-typing';
      typing.innerHTML = '<span></span><span></span><span></span>';
      body.appendChild(typing);
      body.scrollTop = body.scrollHeight;

      fetch('ChatbotServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text, tripId: getTripId(), history: history.slice(-8) })
      })
        .then(function (res) { return res.json(); })
        .then(function (data) {
          typing.remove();
          var reply = data.reply || "Sorry, I couldn't get a response just now. Please try again.";
          addMsg(reply, 'bot');
          history.push({ role: 'bot', text: reply });
        })
        .catch(function () {
          typing.remove();
          addMsg("Sorry, I couldn't reach the server. Please try again.", 'bot');
        });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectOnce);
  } else {
    injectOnce();
  }
})();
