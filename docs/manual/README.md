# PIVlab Manual (standalone website)

A self-contained, dependency-free documentation site for PIVlab. Plain
HTML/CSS/JS — no build step, no framework. It can be opened straight from disk
or hosted on any static web server (including GitHub Pages).

## View it locally

Just open `index.html` in a browser. Everything (navigation, search, dark mode,
table of contents) runs client-side, so `file://` works — no server required.

If your browser is strict about local files, serve the folder instead:

```bash
# from the manual/ folder
python -m http.server 8000
# then open http://localhost:8000/
```

## How it is organised

```
manual/
  index.html              Landing page
  pages/*.html            One file per manual page (content only)
  assets/css/style.css    All styling + light/dark themes
  assets/js/nav.js        Navigation tree — the single source of truth
  assets/js/app.js        Builds header/sidebar/TOC/search/pager around each page
  assets/js/search-index.js  Search records (loaded as a script, no fetch)
  assets/img/<page>/*.png Screenshots
  tools/build_search_index.mjs  Optional helper to regenerate the search index
  .nojekyll               Serve as-is if placed under a Jekyll site
```

Each page contains only an `<article id="doc">…</article>` plus three script
tags. `app.js` reads `nav.js` and wraps that article in the shared layout, so
the chrome is defined once and pages stay pure content.

## Add a new page

1. Copy `pages/masking.html` to `pages/<your-page>.html` and replace the
   article content. Keep the three `<script>` tags at the bottom.
2. In `assets/js/nav.js`, change the matching item's `status` from `"soon"` to
   `"live"` (or add a new item). Hrefs are relative to the manual root, e.g.
   `pages/<your-page>.html`.
3. Add a few records to `assets/js/search-index.js` (or run the generator
   below). Use `hash` values that match `id` attributes on your `<h2>`/`<h3>`.

Images referenced from a page in `pages/` use a relative path, e.g.
`../assets/img/<page>/figure.png`.

## Regenerate the search index (optional)

```bash
node tools/build_search_index.mjs
```

This scans `index.html` and `pages/*.html`, extracts headings, and rewrites
`assets/js/search-index.js`. The site works without ever running it — it is
only a convenience once there are many pages.

## Deploy later

The site is fully portable (all paths are relative):

- **Sub-folder of the PIVlab repo** — copy `manual/` under `docs/` and enable
  GitHub Pages; the included `.nojekyll` stops Jekyll from touching it. It will
  be served at `…/manual/`.
- **Separate repo** — push the contents of `manual/` to its own repo and turn on
  GitHub Pages.

Link to it from the PIVlab GUI Help menu, the PIVlab website and Optolution.com.
