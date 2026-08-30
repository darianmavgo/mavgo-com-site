/* ============================================================
   Mavgo Main JS — tabs, clipboard, mobile menu, search, theme
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {

  // ---- Code Tabs ----
  document.querySelectorAll('.code-panel').forEach(panel => {
    const tabs   = panel.querySelectorAll('.code-tabs button:not(.copy-btn)');
    const bodies = panel.querySelectorAll('.tab-content');

    tabs.forEach((tab, i) => {
      tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        bodies.forEach(b => b.classList.remove('active'));
        tab.classList.add('active');
        if (bodies[i]) bodies[i].classList.add('active');
      });
    });

    // Activate first tab by default
    if (tabs[0]) tabs[0].click();
  });

  // ---- Copy to Clipboard ----
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const panel = btn.closest('.code-panel');
      const active = panel ? panel.querySelector('.tab-content.active pre') : null;
      const text = active ? active.textContent.trim() : '';

      if (!text) return;
      navigator.clipboard.writeText(text).then(() => {
        const orig = btn.innerHTML;
        btn.textContent = '✓ Copied';
        btn.classList.add('copied');
        setTimeout(() => { btn.innerHTML = orig; btn.classList.remove('copied'); }, 1800);
      });
    });
  });

  // ---- Mobile Hamburger ----
  const hamburger = document.querySelector('.hamburger');
  const navLinks  = document.querySelector('.navbar nav');
  const navActions = document.querySelector('.navbar .nav-actions');

  if (hamburger) {
    hamburger.addEventListener('click', () => {
      const isOpen = navLinks && navLinks.classList.toggle('open');
      if (navActions) navActions.classList.toggle('open', isOpen);
      hamburger.setAttribute('aria-expanded', isOpen);
    });
  }

  // ---- Project Search (hub page) ----
  const searchInput = document.getElementById('project-search');
  if (searchInput) {
    searchInput.addEventListener('input', () => {
      const q = searchInput.value.toLowerCase().trim();
      document.querySelectorAll('.project-card').forEach(card => {
        const name = (card.dataset.name || '').toLowerCase();
        const desc = (card.dataset.desc || '').toLowerCase();
        const lang = (card.dataset.lang || '').toLowerCase();
        const show = !q || name.includes(q) || desc.includes(q) || lang.includes(q);
        card.style.display = show ? '' : 'none';
      });

      // hide empty category groups
      document.querySelectorAll('.category-group').forEach(group => {
        const visible = [...group.querySelectorAll('.project-card')].some(c => c.style.display !== 'none');
        group.style.display = visible ? '' : 'none';
      });
    });
  }

  // ---- Fade-in on scroll (IntersectionObserver) ----
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.classList.add('fade-in');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.1 });

    document.querySelectorAll('.feature-card, .project-card, .related-card').forEach(el => {
      io.observe(el);
    });
  }

});
