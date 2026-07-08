/*
 * app.js — builds the shared page chrome around each page's content.
 *
 * Every content page contains only:
 *     <article id="doc"> ...the actual manual text... </article>
 * plus <script> tags loading nav.js, search-index.js and this file.
 *
 * This script wraps that article in the header / sidebar / table-of-contents /
 * footer layout, so navigation and styling live in ONE place and pages stay
 * pure content.  All links are relative, so the site behaves identically when
 * opened from disk (file://) or served from any sub-path.
 */
(function () {
  "use strict";

  // --- Where is the manual root, relative to the current page? -------------
  // Pages under /pages/ need to go up one level; the root index.html does not.
  var inPages = /\/pages\//.test(location.pathname.replace(/\\/g, "/"));
  var ROOT = inPages ? "../" : "./";
  var currentFile = location.pathname.replace(/\\/g, "/").split("/").pop() || "index.html";
  var currentRel = (inPages ? "pages/" : "") + currentFile; // e.g. "pages/masking.html"

  function h(tag, attrs, html) {
    var el = document.createElement(tag);
    if (attrs) { for (var k in attrs) { if (attrs[k] != null) el.setAttribute(k, attrs[k]); } }
    if (html != null) el.innerHTML = html;
    return el;
  }
  function resolve(href) { return ROOT + href; }

  // --- Flatten nav into an ordered list of live pages (for the pager) ------
  function livePages() {
    var out = [];
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      (sec.items || []).forEach(function (it) {
        if (it.status === "live") out.push({ label: it.label, href: it.href, section: sec.title });
      });
    });
    return out;
  }

  // ------------------------------------------------------- Homepage "Start here"
  // Auto-built from nav.js so the homepage never goes stale as pages ship.
  // Renders one card per live page (except the homepage itself), using each
  // item's `blurb`, in the order they appear in nav.js.
  function buildStartHereCards() {
    var container = document.getElementById("start-here-cards");
    if (!container) return;
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      (sec.items || []).forEach(function (it) {
        if (it.status !== "live" || it.href === currentRel) return;
        var card = h("a", { class: "card", href: resolve(it.href) },
          "<h3>" + it.label + "</h3><p>" + (it.blurb || sec.title) + "</p>");
        container.appendChild(card);
      });
    });
  }

  // ------------------------------------------------------------------ Sidebar
  function buildSidebar() {
    var nav = h("nav", { class: "nav" });
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      var group = h("div", { class: "nav-group" });
      group.appendChild(h("p", { class: "nav-group-title" }, sec.title));
      var ul = h("ul");
      (sec.items || []).forEach(function (it) {
        var li = h("li");
        if (it.status === "soon") {
          li.appendChild(h("span", { class: "nav-link soon", title: "Coming soon" },
            it.label + '<span class="badge">soon</span>'));
        } else {
          var isActive = it.href === currentRel;
          var a = h("a", { class: "nav-link" + (isActive ? " active" : ""), href: resolve(it.href) }, it.label);
          li.appendChild(a);
        }
        ul.appendChild(li);
      });
      group.appendChild(ul);
      nav.appendChild(group);
    });
    return nav;
  }

  // --------------------------------------------------------- Table of contents
  function slugify(s) {
    return s.toLowerCase().replace(/[^\w]+/g, "-").replace(/^-+|-+$/g, "");
  }
  function buildToc(article) {
    var heads = article.querySelectorAll("h2, h3");
    if (!heads.length) return null;
    var wrap = h("div", { class: "toc" });
    wrap.appendChild(h("p", { class: "toc-title" }, "On this page"));
    var ul = h("ul");
    heads.forEach(function (hd) {
      if (!hd.id) hd.id = slugify(hd.textContent);
      var li = h("li", { class: hd.tagName.toLowerCase() });
      li.appendChild(h("a", { href: "#" + hd.id, "data-target": hd.id }, hd.textContent));
      ul.appendChild(li);
    });
    wrap.appendChild(ul);
    return wrap;
  }
  function initScrollSpy(toc) {
    if (!toc) return;
    var links = toc.querySelectorAll("a");
    var byId = {};
    links.forEach(function (a) { byId[a.getAttribute("data-target")] = a; });
    var ids = Object.keys(byId);
    if (!ids.length) return;
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          links.forEach(function (a) { a.classList.remove("active"); });
          var a = byId[e.target.id];
          if (a) a.classList.add("active");
        }
      });
    }, { rootMargin: "0px 0px -75% 0px", threshold: 0 });
    ids.forEach(function (id) { var el = document.getElementById(id); if (el) obs.observe(el); });
  }

  // ------------------------------------------------------------------- Pager
  function buildPager() {
    var pages = livePages();
    var idx = -1;
    for (var i = 0; i < pages.length; i++) { if (pages[i].href === currentRel) { idx = i; break; } }
    if (idx === -1) return null;
    var pager = h("nav", { class: "pager" });
    if (idx > 0) {
      var p = pages[idx - 1];
      pager.appendChild(h("a", { class: "pager-link prev", href: resolve(p.href) },
        '<span class="pager-dir">Previous</span><span class="pager-label">' + p.label + "</span>"));
    } else { pager.appendChild(h("span")); }
    if (idx < pages.length - 1) {
      var n = pages[idx + 1];
      pager.appendChild(h("a", { class: "pager-link next", href: resolve(n.href) },
        '<span class="pager-dir">Next</span><span class="pager-label">' + n.label + "</span>"));
    } else { pager.appendChild(h("span")); }
    return pager;
  }

  // --------------------------------------------------------------- Breadcrumb
  function buildBreadcrumb() {
    var section = null, label = null;
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      (sec.items || []).forEach(function (it) {
        if (it.href === currentRel) { section = sec.title; label = it.label; }
      });
    });
    var bc = h("nav", { class: "breadcrumb" });
    bc.appendChild(h("a", { href: resolve("index.html") }, window.MANUAL_NAV.title));
    if (section) { bc.appendChild(h("span", { class: "sep" }, "›")); bc.appendChild(h("span", null, section)); }
    if (label && label !== "Introduction") { bc.appendChild(h("span", { class: "sep" }, "›")); bc.appendChild(h("span", { class: "current" }, label)); }
    return bc;
  }

  // ------------------------------------------------------------------- Search
  function initSearch(input, panel) {
    var data = window.MANUAL_SEARCH || [];
    function render(q) {
      panel.innerHTML = "";
      q = q.trim().toLowerCase();
      if (!q) { panel.classList.remove("open"); return; }
      var terms = q.split(/\s+/);
      var hits = data.map(function (rec) {
        var hay = (rec.title + " " + (rec.section || "") + " " + (rec.text || "")).toLowerCase();
        var score = 0;
        terms.forEach(function (t) {
          if (rec.title.toLowerCase().indexOf(t) !== -1) score += 3;
          else if (hay.indexOf(t) !== -1) score += 1;
        });
        return { rec: rec, score: score };
      }).filter(function (x) { return x.score > 0; })
        .sort(function (a, b) { return b.score - a.score; })
        .slice(0, 8);

      if (!hits.length) {
        panel.appendChild(h("div", { class: "search-empty" }, "No results for “" + q + "”"));
      } else {
        hits.forEach(function (x) {
          var rec = x.rec;
          var url = resolve(rec.href) + (rec.hash && rec.hash !== "top" ? "#" + rec.hash : "");
          var a = h("a", { class: "search-hit", href: url },
            '<span class="search-hit-title">' + rec.title + "</span>" +
            '<span class="search-hit-section">' + (rec.section || "") + "</span>");
          panel.appendChild(a);
        });
      }
      panel.classList.add("open");
    }
    input.addEventListener("input", function () { render(input.value); });
    input.addEventListener("focus", function () { if (input.value) render(input.value); });
    document.addEventListener("click", function (e) {
      if (!panel.contains(e.target) && e.target !== input) panel.classList.remove("open");
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "/" && document.activeElement !== input) { e.preventDefault(); input.focus(); }
      if (e.key === "Escape") { panel.classList.remove("open"); input.blur(); }
    });
  }

  // -------------------------------------------------------------------- Theme
  function initTheme(btn) {
    var stored = null;
    try { stored = localStorage.getItem("pivlab-manual-theme"); } catch (e) {}
    var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    var theme = stored || (prefersDark ? "dark" : "light");
    apply(theme);
    btn.addEventListener("click", function () {
      theme = (document.documentElement.getAttribute("data-theme") === "dark") ? "light" : "dark";
      apply(theme);
      try { localStorage.setItem("pivlab-manual-theme", theme); } catch (e) {}
    });
    function apply(t) {
      document.documentElement.setAttribute("data-theme", t);
      btn.setAttribute("aria-label", t === "dark" ? "Switch to light mode" : "Switch to dark mode");
      btn.innerHTML = t === "dark" ? "☀" : "☾";
    }
  }

  // --------------------------------------------------------------------- Build
  document.addEventListener("DOMContentLoaded", function () {
    var article = document.getElementById("doc");
    if (!article) return;

    // Header / top bar
    var header = h("header", { class: "topbar" });
    var brand = h("a", { class: "brand", href: resolve("index.html") },
      '<span class="brand-mark">PIV</span><span class="brand-text">lab Manual</span>');
    var burger = h("button", { class: "burger", "aria-label": "Toggle navigation" }, "&#9776;");
    var searchWrap = h("div", { class: "search" });
    var searchInput = h("input", { type: "search", placeholder: "Search the manual…  ( / )", "aria-label": "Search" });
    var searchPanel = h("div", { class: "search-panel" });
    searchWrap.appendChild(searchInput); searchWrap.appendChild(searchPanel);
    var themeBtn = h("button", { class: "theme-toggle", "aria-label": "Toggle theme" }, "☾");
    var ghLink = h("a", { class: "gh-link", href: "https://github.com/Shrediquette/PIVlab", target: "_blank", rel: "noopener" }, "GitHub");
    header.appendChild(burger); header.appendChild(brand); header.appendChild(searchWrap);
    header.appendChild(themeBtn); header.appendChild(ghLink);

    // Layout skeleton
    var layout = h("div", { class: "layout" });
    var sidebar = h("aside", { class: "sidebar" });
    sidebar.appendChild(buildSidebar());
    var main = h("main", { class: "main" });
    var toc = buildToc(article);

    main.appendChild(buildBreadcrumb());
    main.appendChild(article);            // move the page's content in
    var pager = buildPager();
    if (pager) main.appendChild(pager);
    main.appendChild(h("footer", { class: "site-footer" },
      'PIVlab manual · <a href="https://www.pivlab.de" target="_blank" rel="noopener">PIVlab.de</a> · ' +
      'supported by <a href="https://optolution.com" target="_blank" rel="noopener">OPTOLUTION</a>'));

    layout.appendChild(sidebar);
    layout.appendChild(main);
    if (toc) { var tocAside = h("aside", { class: "toc-rail" }); tocAside.appendChild(toc); layout.appendChild(tocAside); }

    document.body.insertBefore(layout, document.body.firstChild);
    document.body.insertBefore(header, document.body.firstChild);

    // Behaviour
    burger.addEventListener("click", function () { sidebar.classList.toggle("open"); });
    document.addEventListener("click", function (e) {
      if (window.innerWidth <= 900 && sidebar.classList.contains("open") &&
          !sidebar.contains(e.target) && e.target !== burger) sidebar.classList.remove("open");
    });
    initScrollSpy(toc);
    initSearch(searchInput, searchPanel);
    initTheme(themeBtn);
    buildStartHereCards();
  });
})();
