# PIVlab Manual — Content Plan (master tracker)

**Read this file first when resuming work on the manual**, in this session or a
fresh one. It is the durable source of truth — more reliable than session
memory, which may be summarized or unavailable in a new session.

## How to resume

1. Find the first unchecked `[ ]` topic below, in priority order (P1 before P2 before P3).
2. Read its **Source** references (menu label + callback file) to ground the content in code — do not guess UI labels/tooltips, verify them in `+gui/generateUI.m` / `+gui/generateMenu.m` the same way the masking page was built (see [`manual/pages/masking.html`](pages/masking.html) as the reference template and tone).
3. Write `manual/pages/<slug>.html` following the masking page's structure: `<article id="doc">` content only, three `<script>` tags at the bottom.
4. In `manual/assets/js/nav.js`, flip that item's `status` from `"soon"` to `"live"` and add a one-line `blurb` — the homepage's "Start here" cards are auto-built from this file (`app.js`'s `buildStartHereCards()`), so this is the only place you need to touch; `index.html` itself never needs editing.
5. Add 1–3 records to `manual/assets/js/search-index.js` for the page's sections (or run `node tools/build_search_index.mjs`).
6. Check the box below `[x]` and note the completion date.
7. If screenshots are needed, see [`reference_pivlab_gui_screenshots`](../../../.claude/projects) memory. **Critical**: launch with `PIVlab_GUI(1)` (a core-count argument), never bare `PIVlab_GUI` — without it, PIVlab blocks on a "how many cores?" dialog and every subsequent MCP call hangs/times out. Also set `gui.put('batchModeActive',1)` right after loading images, before switching to any panel — several callbacks (e.g. switching the PIV algorithm to wOFV) show a confirmation dialog otherwise, which also hangs the MCP call and kills the whole figure.

Menu structure ground truth: [`+gui/generateMenu.m`](../+gui/generateMenu.m) (76 lines, read in full 2026-07-07 — quote it again if it may have changed).

## Screenshot pass — 2026-07-07 (second session)

All 24 P1/P2/P3 pages now have at least one real screenshot (33 images total across the site), captured in one MATLAB session using `PIVlab_GUI(1)` + `batchModeActive=1`. A real single-frame DCC analysis was run first (fast, ~7s) so validation/statistics/derive/export panels show genuine populated data (VDP, mean/min/max, etc.) instead of "N/A" placeholders — much more useful than empty panels. `piv-settings.html` also gained a second screenshot (Optical flow/wOFV view), which had previously been skipped after an earlier crash — confirmed the crash was specifically the missing `batchModeActive` guard, not a general wOFV problem. Capturing `capture.html`'s panel live revealed more real controls (Camera settings, Live image, Capture PIV images sections) than the static code read had shown — the page text was enriched accordingly.

## "Tips & tricks" advice pass — 2026-07-08

The user provided a distillation of years of their own PIVlab Google Group support advice
(including direct guidance from PIVlab's author, William Thielicke — the user themself) and
asked for it to be woven into the manual. **Unlike every other page here, this content is not
verified against `generateUI.m`** — it's community/author domain knowledge given directly by the
user; treated as authoritative, not embellished. New page `pages/best-practices.html` (five-stage
mindset, seeding/image quality, diagnose-before-you-tune checklist, troubleshooting-by-symptom
table) plus a substantial new `#tips` section (5 `<h3>` subsections) on `piv-settings.html`
covering interrogation-area choice and Δt selection. Smaller additions to `preprocessing.html`
(#tips), `roi.html`, `validation-velocity.html` (validation order + "interpolated vectors
aren't measurements"), `spatial-calibration.html` (calibrate early), and `correlation-matrices.html`
(peak-shape interpretation table). **Two explicit user corrections applied during planning, worth
remembering for any future advice-style content:** (1) don't invent a blockquote/citation
component — the user does not want to be quoted, even attributed to "William Thielicke, PIVlab
author" (awkward since they're the same person) — fold guidance into plain paraphrased prose
instead; (2) for Δt/displacement selection, the actionable technique is empirical, not
calculation-based: enter a rough guess, run a quick test analysis, click a vector, and read the
displacement directly from the Tools panel's "Current point" readout (already documented on
`interface.html#tools`) — much faster than computing it in advance.

**Follow-up, same day:** added a new `#tuning` section ("Tuning strategy: isolate, then combine")
to `validation-velocity.html`, right before `#apply` — user's own methodology for setting up the
statistical filters: tune one filter at a time with the others disabled, confirm it only removes
genuinely bad vectors, check across several different frames (not just one), then enable them
together — if they still work well combined, they're likely catching nearly all the erroneous
vectors. Complements (doesn't replace) the existing "A sensible order" tip near the top of that
page, which covers *which* filter to try first rather than *how* to tune each one.

**Correction, 2026-07-08:** removed the `#whatmask` ("What should I mask?") section from
`masking.html` entirely — the user flagged it as low-value and factually wrong. It claimed
"PIVlab has no true dynamic masking," but masking *does* support moving objects: the Automatic
masks Expert-mode generators re-detect per frame, and masks can also simply be moved/re-drawn
frame to frame. Don't reintroduce this claim in any future edit. Removed the corresponding
`search-index.js` record; left the rest of the masking page (which already documents per-frame
masks and Automatic masks/Expert mode correctly) untouched.

## User-provided result images — 2026-07-08

The user supplied 16 clean, properly-masked **result/output** screenshots (from `~/Downloads`, `.jpg`) and I placed them on the relevant pages as full-width `<figure>`s (panels stay as the earlier `.png` captures). Going forward, **result visuals come from the user** — do not auto-generate messy ones. Images added: sessions (import dialog), validation-velocity (auto-limits scatter, vector colours), derive-spatial (magnitude overlay), streamlines, plot-appearance (colormap steps), extract-polyline (magnitude profile popup + circle series), extract-area (rectangle result), markers (measurement — replaced the plain panel.png, which is now orphaned/unused), correlation-matrices (4-pass popup), spatial-calibration (reference length), camera-calibration (charuco board, lens distortion, camera positions, rectified board). Two filename notes flagged to user: `extract_area_vorticity_circle_series.jpg` actually shows the **poly-line** panel (circle-series type) so it went on extract-polyline; and the file is `extract_area_v_component.jpg` (v, not "c").

## Stale "soon" copy removed — 2026-07-09

User asked to verify the homepage's "Chapters marked soon aren't written yet" line, since the
plan had been fully complete since 2026-07-07 (see the capture.html entry below: "every P1/P2/P3
item is now live"). Confirmed via `nav.js` that zero entries currently have `status: "soon"` —
the only match for that string was inside the file's own header comment, not an actual nav item.
Removed the sentence (and its `<span class="badge">soon</span>`) from `index.html`. The
`soon`/`.badge` rendering in `app.js` (`buildSidebar()`) and its CSS (`.nav-link.soon`, `.badge`
in `style.css`) were left in place — not dead code, just currently unused — since step 4 of "How
to resume" above still uses `status: "soon"` as the placeholder state for any future topic added
to `nav.js`. If a new topic is ever added, flip it to `"live"` per that workflow and this homepage
sentence would need to be re-added at that point (it's fine to omit while the plan is 100% live).

## Style rules established on the masking page (apply to all new pages)

- Task-focused, not an exhaustive parameter reference — explain what a user does and why, not every implementation detail.
- Verify every button label / tooltip / menu path against the source before writing it down.
- Use the shared components: `<div class="split">` for text-beside-screenshot, `<ol class="steps">` for numbered workflows, `<table class="ref">` for button/option reference tables, `.note`/`.tip`/`.warn` callouts.
- Prefer one real worked example (like the Kármán-vortex rod mask) over abstract description.
- Flag anything disabled/WIP/experimental in the current code honestly (e.g. Stereo PIV, second-monitor display) rather than describing aspirational behavior.

---

## Topics

### Getting started
- [x] **Introduction** — `pages/index` (site landing page, not a menu item) — done 2026-07-07
- [x] **Interface & workflow** — `pages/interface.html` — done 2026-07-08 (not a menu item; requested by user). Covers the window layout, the left-to-right menu workflow (with links to each feature page), the **Tools panel** (frame slider, Toggle, zoom/pan, parallel toggle verified in `+misc/toggle_parallel_Callback.m`, Current-point readout verified click-driven in `+gui/veclick.m`), the quick-access strip (6 icons from `generateUI.m:71-76`) + progress bar, mouse/coordinate conventions, and Basic vs Advanced mode. **Annotated overview added 2026-07-08**: user's `gui-overview.jpg` (1248×918) with an inline-**SVG overlay** (6 numbered lime boxes: menu bar/settings/image/quick-access/progress/tools) + a numbered `.legend` under it; body text references regions by number. Overlay technique: `.annot` wrapper (in `style.css`) sizes to the img so the `viewBox="0 0 1248 918"` maps 1:1 — reusable for future annotated shots. Coordinates were verified by compositing the boxes onto the JPG in MATLAB (`insertShape`) since preview screenshots kept timing out on the large image.
- [x] **P1 — Sessions: new/load/save** — `pages/sessions.html` — done 2026-07-07. Covers importing images (3 sequencing styles verified in `+gui/uipickfiles.m:492-509`), the image list & Remove images (verified it clears results, `+import/remove_images_from_list.m`), and the Session-vs-Settings distinction (the main non-obvious value of this page). Screenshot: `assets/img/sessions/input-data-panel.png`.

### Image settings
- [x] **P2 — Camera calibration & lens rectification** — `pages/camera-calibration.html` — done 2026-07-07. Panels verified in `+gui/generateUI.m:2334-2496` (multip26 Camera calibration, multip27 Image rectification, multip28 Marker board setup). Confirmed Camera 2 disabled only at the menu level (`generateMenu.m`), while the callbacks (`cam_calibration_Callback.m`, `cam_rectification_Callback.m`) already handle it — documented as "mono only for now" without overclaiming. Noted (not documented, out of scope): `calib_dolivedetect` control is commented out in `generateUI.m:2475-2485` but still referenced by `cam_marker_setup_Callback.m:8` and session load/save — a latent dead-code bug, flagged via spawn_task rather than blocking docs. No screenshot (MATLAB session still unresponsive to `PIVlab_GUI` relaunch this session).
- [x] **P1 — Image pre-processing / enhancement** — `pages/preprocessing.html` — done 2026-07-07. Panel controls verified in `+gui/generateUI.m:599-673` (CLAHE, highpass, intensity capping, Wiener2, auto contrast stretch, background subtraction). Confirmed via `+preproc/preview_preprocess_Callback.m` that the button only re-renders a preview — actual filters apply to all frames at analysis time (matches `docs/_wiki/1_quickstart.md`). Screenshot: `assets/img/preprocessing/panel.png`.
- [x] **P1 — Region of interest (ROI)** — `pages/roi.html` — done 2026-07-07. Confirmed in `+preproc/PIVlab_preproc.m:33-45` that ROI actually crops the pixel array before processing (`in_roi=in(y:y+height,x:x+width)`), unlike masking's post-hoc NaN — page includes a ROI-vs-masking comparison table. One global rectangle per session (`roirect` appdata var), not per-frame. Screenshots: `assets/img/roi/panel.png`, `assets/img/roi/rectangle-on-image.png`.
- [x] **Masking** — Image settings → Define masks (exclude regions from analysis). `pages/masking.html` — done 2026-07-07, includes overlapping-mask even-odd behavior.

### Analysis
- [x] **P1 — PIV settings** — `pages/piv-settings.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:675-847`; per-algorithm control visibility verified in `+piv/algorithm_selection_Callback.m` (which of subpix/mask_auto_box/CorrQuality/checkbox_uncertainty show for each of the 4 algorithms — this differs and is documented in a table). Screenshot only for FFT view (`assets/img/piv-settings/panel-fft.png`) — **do not** attempt an Optical-flow screenshot by calling `algorithm_selection_Callback` with Value=4 without first setting `gui.put('batchModeActive',1)`; it opens a blocking confirmation dialog that torched the whole PIVlab figure (see reference_pivlab_gui_screenshots memory).
- [x] **P3 — Stereo PIV settings** — `pages/stereo-piv.html` — done 2026-07-07. Short honest stub confirming callback is `[]`/disabled; mentions related-but-usable infra (Scheimpflug option in camera calibration, disabled Stereo-PIV mode checkbox).
- [x] **P1 — Running the analysis (ANALYZE!)** — `pages/analyze.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:848-878`; confirmed "Analyze all frames" relabels to "Start ensemble analysis" for the Ensemble algorithm (`+piv/do_analys_Callback.m`); confirmed "Clear all results" only clears `resultslist`/`derived`, not masks/ROI/settings (`+misc/clear_everything_Callback.m`). **No screenshot** — MATLAB session became unresponsive to `PIVlab_GUI` launches (repeated MCP timeouts, though the MATLAB session itself stayed responsive to simple commands) after the earlier wOFV modal-dialog crash. A fresh session/MATLAB restart should be able to capture one if desired: switch to `multip05` via `piv.do_analys_Callback([],[])` and `exportapp`.

### Validation
- [x] **P2 — Velocity-based validation** — `pages/validation-velocity.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:880-1002`. Confirmed scatter plot is u-vs-v velocity space, not image space (`+validate/vel_limit_Callback.m`). Vector color legend (green/cyan/orange) cross-references Modify plot appearance (not yet linked — plan a cross-link pass once that page exists).
- [x] **P2 — Image-based validation** — `pages/validation-image.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:2042-2123` (multip23) — mirrors the velocity-validation panel's apply/undo/color-legend, but with 3 image-quality filters (low contrast, bright objects, correlation coefficient) instead of statistical ones. Cross-linked with `validation-velocity.html` both ways.

### Spatial calibration
- [x] **P2 — Spatial calibration (px → mm)** — `pages/spatial-calibration.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1004-1068` (multip07). Confirmed time-step=0 triggers `displacement_only` mode (cross-checked against `+import/load_session_Callback.m`'s handling of `time_inp_string`). Confirmed the axis-direction/offset panel is exactly what `docs/_wiki/1_quickstart.md`'s intro paragraph refers to as adjustable "after calibration". Cross-linked with `camera-calibration.html` both ways.

### Plot & post-processing
- [x] **P2 — Deriving spatial parameters / modifying data** — `pages/derive-spatial.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1070-1163` (multip08). Confirmed the 13-item parameter list and unit adaptation directly from `+plot/derivs_Callback.m`. **Important**: the "Calculate mean/sum" sub-panel (`uipanel43`, lines 1164-1181) is entirely commented out in `generateUI.m` — a disabled/dead feature — deliberately **not documented** here despite its tooltips existing in the source.
- [x] **P3 — Deriving temporal parameters** — `pages/derive-temporal.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:2008-2038` (multip22). Note: this is the **live, working version** of the mean/sum feature that appears commented-out/dead in multip08 (see derive-spatial.html's plan entry) — it moved here and gained stdev/TKE operations. Cross-linked with `derive-spatial.html`.
- [x] **P2 — Modifying plot appearance** — `pages/plot-appearance.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1182-1328` (multip09: vector appearance, background, vector colors uipanel37, derived-parameter colormap uipanel27, color legend uipanel27b, reference vector). This is the page both validation pages and masking reference for colors/transparency — did a **cross-link pass**: fixed an initially-inaccurate claim (masking.html didn't actually mention transparency yet), added a real tip to `masking.html` about `Mask transparency [%]`, and linked both `validation-velocity.html` and `validation-image.html`'s color-legend notes here. `img_not_mask` checkbox is `Visible off` in code — dead, not documented.
- [x] **P3 — Streamlines** — `pages/streamlines.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1872-1920` (multip18). Confirmed and led with the non-obvious "streamlines are global (all frames)" behavior from the panel's own instructional text.
- [x] **P3 — Markers / distance / angle** — `pages/markers.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1425-1494` (multip13, two sub-panels: Distance & angle uipanel40, Markers uipanel39). Confirmed the notable marker-persistence behavior (survives "New session", cleared only on PIVlab restart) directly from the `Hold markers` tooltip.
- [x] **P3 — Correlation matrices** — `pages/correlation-matrices.html` — done 2026-07-07. Panel (multip29) was already read in full while researching camera-calibration.html (`+gui/generateUI.m:2496-2511`). Small, simple panel — just retrieve + click-a-vector.
- [x] **P3 — Second monitor display** — `pages/second-monitor.html` — done 2026-07-07. Cross-checked the 66-day-old `project_multimonitor` memory against current `+gui/toggle_second_monitor_Callback.m` rather than trusting it — architecture (redirect `pivlab_axis`, restore on close) still matches. Kept the page deliberately short/high-level and labeled "experimental" per the menu's own wording; did not describe internal implementation details (axis redirection, resize-handler fixes) since those are implementation, not user-facing behavior. Confirmed single-monitor fallback behavior directly in code.

### Extractions
- [x] **P2 — Parameters from poly-line** — `pages/extract-polyline.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1374-1423` (multip12). Draw interaction (left-click points/right-click finish for polyline; two-click centre+radius for circle) taken from a commented-out-but-still-accurate instructional label at lines 1380/1383 — the label text is disabled for space, not because the behavior changed. Links forward to `derive-spatial.html` for the shared parameter list.
- [x] **P2 — Parameters from area** — `pages/extract-area.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1820-1868` (multip17). Confirmed this computes a single average over the drawn area (shown in a live `Results` box) rather than a profile — the key difference from poly-line extraction. Cross-linked both ways with `extract-polyline.html`.

### Statistics
- [x] **P2 — Statistics** — `pages/statistics.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1496-1553` (multip14). This completes P2 in full.

### Synthetic particle image generation
- [x] **P3 — Synthetic particle image generation** — `pages/synthetic-images.html` — done 2026-07-07. Panel verified in `+gui/generateUI.m:1555-1768` (multip15, 5 flow types each with their own hidden/shown sub-panel: Rankine, Hamel-Oseen, Rotation, Linear shift, Membrane). Note: "Membrane" has no dedicated sub-panel in the code (no `membranepanel` found) — documented as using only the general particle settings, not guessed at further.

### Data
- [x] **P1 — Exporting results** — `pages/export.html` — done 2026-07-07. All 6 panels verified in `+gui/generateUI.m` (ASCII=multip10:1330-1356, MAT=multip11:1357-1373, still image/animation=multip16:1770-1819, Paraview=multip19:1922-1931, Tecplot=multip20:1932-1945). Confirmed workspace export (`write_workspace_Callback.m`) fails silently with no results (no msgbox), unlike `pixel_data.m` which shows an error dialog — documented as a warning. No screenshot (MATLAB session unresponsive to `PIVlab_GUI`, see analyze.html entry above) — text/tables sufficed since content is mostly labels/options, not visual layout.

### Image acquisition
- [x] **P3 — Capturing images from a camera** — `pages/capture.html` — done 2026-07-07. **This completes the full ~24-topic plan — every P1/P2/P3 item is now live.** Panel (multip24, `+gui/generateUI.m:2125-2223+`) is large (~38 files in `+acquisition`) and genuinely hardware/product-specific (PIVlab SimpleSync synchronizer + named camera models) — deliberately kept at workflow-shape level rather than exhaustively cataloging every hardware control, since I can't verify exact behavior without physical hardware. Linked out to the existing `docs/_wiki/4_synchronizer_laser.md` and `5_camera_setup.md` pages (confirmed URL slugification pattern — underscores become hyphens — from a working link already inside `1_quickstart.md`) for hardware-specific setup instead of duplicating/guessing that content.

### Reference (not a menu item, but high value)
- [x] **P1 — Keyboard shortcuts** — `pages/shortcuts.html` — done 2026-07-07. All 15 `Accelerator` attributes extracted from `+gui/generateMenu.m` (source of truth). Cross-checked `help/PIVlab_shortcuts.pdf` and found it's **stale**: it lists Ctrl+E as covering both ROI and masking, but masking now has its own panel with no accelerator — documented this discrepancy explicitly rather than copying the PDF blindly.

### Best practices (not a menu item; source is user-provided domain knowledge, not code)
- [x] **Best practices & troubleshooting** — `pages/best-practices.html` — done 2026-07-08. Five-stage mindset, particle seeding/image quality, diagnose-before-you-tune checklist, troubleshooting-by-symptom table. Own top-level nav section, placed right after "Getting started" for visibility. See the dated changelog entry below for the full scope of this batch (also touches `piv-settings.html`, `preprocessing.html`, `masking.html`, `roi.html`, `validation-velocity.html`, `spatial-calibration.html`, `correlation-matrices.html`).

### Explicitly out of scope (external links, not manual content)
- Learn! → Tutorial videos, Forum, Website, How to cite, About — link from the footer/Introduction page instead of writing dedicated pages.

---

## Priority order to write in (P1 → P2 → P3, top to bottom within each)

P1: Sessions · Image pre-processing · ROI · PIV settings · Running the analysis (ANALYZE!) · Exporting results · Keyboard shortcuts

P2: Camera calibration & rectification · Velocity-based validation · Image-based validation · Spatial calibration · Deriving spatial parameters · Modifying plot appearance · Parameters from poly-line · Parameters from area · Statistics

P3: Stereo PIV settings (stub only) · Deriving temporal parameters · Streamlines · Markers/distance/angle · Correlation matrices · Second monitor display · Synthetic particle image generation · Capturing images from a camera
