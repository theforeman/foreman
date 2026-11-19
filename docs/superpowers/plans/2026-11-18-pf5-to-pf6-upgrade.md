# PatternFly 5 → 6 Upgrade (foreman core) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move foreman core's React UI, SCSS and ERB layouts from PatternFly 5 to PatternFly 6 with no workflow or behavior change.

**Architecture:** Follow the PF6 upgrade guide (https://www.patternfly.org/releases/upgrade-guide) in its order: bump deps → run codemods (dry run, then `--fix`) → manual fixes until build and tests are green → remove CSS overrides → review variable/class names with AI skills → convert px breakpoints to rem. PF3 (`patternfly`, `patternfly-react`) stays installed and untouched.

**Tech Stack:** React 17.0.2, @patternfly/* 6.7.0, @patternfly/react-charts 8.7.0 + victory 37, jest 26 + RTL 10, webpack 5, sass ~1.60, local `../pf-codemods` checkout (pf-codemods 2.6.4, class-name-updater 2.1.2, css-vars-updater 1.1.5).

**Spec:** User guidelines (2026-11-18 session) + PF6 upgrade guide. Five steps: 1) update deps, 2) run codemods (`pf-codemods --v6`, `class-name-updater`, `tokens-update`, `css-vars-updater`) without `--fix` first, 3) remove CSS overrides, 4) review/update variable and class names using AI skills, 5) breakpoint logic px → rem.

## Global Constraints

- Scope: `~/git/foreman` only. foreman-js / `@theforeman/vendor-core` and plugins are out of scope.
- Do not remove `patternfly` (^3.59.5) or `patternfly-react` (^2.40.0).
- Versions (Task 1, already applied in the working tree): `react`/`react-dom` `^17.0.2`; `@patternfly/{patternfly,react-core,react-icons,react-styles,react-table,react-tokens,react-templates}` `^6.7.0`; `@patternfly/react-charts` `^8.7.0`; `victory` `^37.3.6` (react-charts 8 peer range; `.npmrc` has `legacy-peer-deps=true`, so peers are not auto-installed).
- `package-lock.json` is gitignored; only `package.json` is committed. Install with `npm install --ignore-scripts` locally (the `postinstall` runs `npm install` in every plugin).
- Codemods run from the local checkout `../pf-codemods`, not `npx …@latest`.
- pf-codemods is an eslint wrapper; it is the one eslint-based tool allowed here because the user asked for it. Never run `npm run lint`, `eslint`, or `npm run lint:plugins`.
- Jest: `npm test -- <pattern>` (never bare `npx jest --config`). Full suite: `npm test`.
- Webpack build check: `NODE_OPTIONS=--max-old-space-size=8096 NODE_ENV=development npx webpack --config config/webpack.config.js` (exits 0 with no `ERROR in`).
- UI smoke checks run on the remote dev box (SSH, vagrant); restart Puma **and** webpack together.
- Commits: `Refs #<redmine-issue> - <summary>` (ask the user for the issue number before the first commit).
- Do not mock child components to make tests pass; fix the component.
- PF6 docs: patternfly.org (v6) via the patternfly MCP (`mcp__patternfly-mcp__searchPatternFlyDocs` / `usePatternFlyDocs`).

## Review Focus

1. Removed deprecated components (old `Select`, `Dropdown`, `ContextSelector`, `KebabToggle`, `DropdownToggle*`) in header/taxonomy switcher/bookmarks/table actions: keyboard flow, typeahead filtering, and selected state must match PF5 behavior. Each rewritten component gets an RTL test asserting open → select → callback (Task 3).
2. ERB-rendered pages (`app/views/layouts/*.erb`, `app/assets/stylesheets/*.scss`) are invisible to the JS codemods and jest; they must still pick up PF6 page/section styling. Covered by class-name-updater with `--extensions` including `erb,rb` (Task 2) and a dev-box smoke check of a Rails index page (Task 4).
3. Hot-pink placeholder `--pf-t--temp--dev--tbd` / `t_temp_dev_tbd` left behind by `tokens-update`/`css-vars-updater`: zero occurrences may remain at the end. Grep gate in Task 5.
4. Theme overrides in `patternfly_colors_overrides.scss` (sidebar/nav colors) keyed on PF5 component vars silently stop applying; the nav must keep foreman's colors or deliberately adopt PF6 defaults. Dev-box visual check in Task 4.
5. Plugins consume PF through foreman's vendor bundle (`config/webpack.vendor.js`); `@patternfly/react-core/deprecated` and `@patternfly/react-charts/victory` must resolve for them. Vendor list entries added in Task 1.

---

### Task 1: Phase 0 — dependencies (React 17 + PF6)

`package.json` edits and the local install are **done** (verified: react 17.0.2, @patternfly/* 6.7.0, react-charts 8.7.0, victory 37.4.1, patternfly-react 2.40.0). Remaining: bundle/jest wiring.

**Files:**
- Modify: `package.json` (done)
- Modify: `config/webpack.vendor.js:40-47`
- Modify: `webpack/jest.config.js:54`

- [ ] **Step 1:** In `config/webpack.vendor.js`, replace `'@patternfly/react-charts'` with `'@patternfly/react-charts/victory'`, and add `'@patternfly/react-core/deprecated'` and `'@patternfly/react-table/deprecated'`.
- [ ] **Step 2:** In `webpack/jest.config.js`, add mappers next to the existing `react-table/deprecated` one: `'^@patternfly/react-core/deprecated$'` and `'^@patternfly/react-charts/victory$'` → `${nodeModules}/<same path>`.
- [ ] **Step 3:** Commit `package.json`, `config/webpack.vendor.js`, `webpack/jest.config.js`. The build and tests are expected to be red until Task 3.

### Task 2: Run codemods (dry run → fix)

**Files:** everything under `webpack/`, `app/assets/stylesheets/`, `app/views/layouts/`, `script/lint/@theforeman/eslint-plugin-rules/`.

**Interfaces:**
- Produces: reports in `/tmp/pf6-codemods/` (outside the repo), consumed by Task 3 as the manual-fix worklist.

- [ ] **Step 1: Build the local codemods.** `cd ../pf-codemods && yarn install && yarn build`. Expected: `packages/class-name-updater/dist/cli.js` and `packages/css-vars-updater/dist/cli.js` exist.
- [ ] **Step 2: pf-codemods dry run.** From the foreman root: `NODE_OPTIONS=--max-old-space-size=4096 node ../pf-codemods/packages/pf-codemods/index.js --v6 webpack > /tmp/pf6-codemods/pf-codemods-dry.txt`. Expected: a lint-style report ending in an error/warning count. It includes `tokens-update`, `remove-deprecated-components`, `charts-import-moved`, `text-replace-with-content`, `empty-state-header-move-into-empty-state`, and `modal-deprecated`.
- [ ] **Step 3: pf-codemods fix.** Same command with `--fix` → `/tmp/pf6-codemods/pf-codemods-fix.txt` (the remaining unfixable items). Then run `--only data-codemods-cleanup --fix` once.
- [ ] **Step 4: class-name-updater.** Run `node ../pf-codemods/packages/class-name-updater/dist/cli.js --v6 --extensions css,scss,js,jsx,ts,tsx,erb,rb webpack app/assets/stylesheets app/views app/helpers script/lint` first without, then with `--fix`. Expected: all 274 `pf-v5-` occurrences become `pf-v6-`, including `prefer-pf-components.js` and its tests, `base.html.erb:64` and `_application_content.html.erb`.
- [ ] **Step 5: css-vars-updater.** Run `node ../pf-codemods/packages/css-vars-updater/dist/cli.js webpack app/assets/stylesheets -i`. Answers: extensions `scss,css`, no excludes, run fixer **Y**, hot-pink colors **Y**, other globals **Y**, directional fix **left-to-right**. Run it once without the fixer first and save the output to `/tmp/pf6-codemods/css-vars-dry.txt`.
- [ ] **Step 6: Verify.** `grep -rIn "pf-v5" webpack app script/lint` lists only intentional leftovers; record each one in the commit message. Then commit with the message "run PF6 codemods".

### Task 3: Manual fixes until build + tests are green

Worklist = `/tmp/pf6-codemods/pf-codemods-fix.txt` + webpack build errors + jest failures.

**Files (known now):**
- Rewrite removed deprecated components (composable PF6 `Select`/`Dropdown`/`Menu`, or `@patternfly/react-templates` `SimpleSelect`/`SimpleDropdown`/`CheckboxSelect`/`TypeaheadSelect`):
  `HostDetails/DetailsCard/PowerStatus/PowerStatusDropDown.js`, `HostDetails/Status/StatusTable.js`, `HostStatuses/Status/Details.js`, `HostDetails/Tabs/ReportsTab/helpers.js`, `HostsIndex/index.js`, `HostDetails/Tabs/Parameters/EditTableRow.js`, `Layout/components/TaxonomySwitcher/TaxonomyDropdown.js`, `Layout/components/Toolbar/UserDropdowns.js`, `PF4/Bookmarks/Bookmarks.js`, `PF4/Bookmarks/BookmarkItems.js`, `PF4/DocumentationLink/index.js`, `PF4/TableIndexPage/Table/SelectAllCheckbox/index.js`, `PF4/TableIndexPage/ActionButtons.js`, `routes/FiltersForm/SelectRole.js`, `routes/FiltersForm/SelectResourceType.js` (all under `webpack/assets/javascripts/react_app/`).
- Charts: `components/common/charts/{BarChart,AreaChart,DonutChart}/index.js`, `charts/helpers/LegendHelpers.js` must import from `@patternfly/react-charts/victory`.
- Layout: `components/Layout/Layout.js`, `Layout/components/Toolbar/Header.js` (PF6 Masthead/Page structure: `MastheadLogo`, `MastheadToggle` inside `MastheadMain`, `Page masthead=`).
- Modal (21 files) and old `DualListSelector` (`common/Pf4DualList`, `common/OrderableDualListSelector`) stay on `@patternfly/react-core/deprecated`, as placed by the codemod. Migrating them to the new APIs is a follow-up, not part of this plan.

- [ ] **Step 1:** Run the webpack build check (Global Constraints) and fix each `ERROR in` until it exits 0.
- [ ] **Step 2:** For each rewritten removed-component file, write or extend its RTL test first. Assert: the toggle renders with the current label → clicking it opens the menu → clicking an option calls the handler with that option's value → the menu closes. For typeahead selects (`SelectRole`, `SelectResourceType`, `TaxonomyDropdown`), also assert that typing filters the options. Run `npm test -- <ComponentName>`. Expected: fails before the rewrite, passes after.
- [ ] **Step 3:** Run `npm test`. Fix failures in the component, not with mocks. Update snapshots (`npm test -- -u <pattern>`) only after confirming the diff is a PF6 markup change (class prefix, wrapper element), not lost content.
- [ ] **Step 4:** Verify: the build exits 0 and `npm test` reports 0 failed. Commit, using one commit per component group (header/layout, bookmarks, table actions, host details, filters form, charts).

### Task 4: Remove CSS overrides

**Files:** the 36 `.scss`/2 `.css` files carrying `pf-v6-` selectors or vars after Task 2, plus `app/assets/stylesheets/{patternfly_and_overrides,patternfly_colors_overrides,base,base-pf4,navigation}.scss`.

- [ ] **Step 1:** For each rule that targets a `.pf-v6-c-*` class or sets a `--pf-v6-c-*` / `--pf-t--*` var, comment it out, rebuild, and compare the page on the dev box (restart Puma + webpack). Delete the rule if the PF6 default is acceptable. Keep it, re-keyed to a PF6 token, only if dropping it breaks layout or foreman branding (nav colors in `patternfly_colors_overrides.scss`).
- [ ] **Step 2:** Remove `pf-m-light` from `_application_content.html.erb` page sections. PF6 removed the light variant; use the default or `pf-m-secondary` to match the React `PageSection`.
- [ ] **Step 3:** Smoke-check on the dev box: login page, dashboard, hosts index (React), host details, a Rails index page (e.g. `/architectures`), and the settings page. Check nav colors, toolbar, pagination and empty states.
- [ ] **Step 4:** Run `npm run stylelint` and `npm run test:stylelint`. Expected: 0 errors. Commit.

### Task 5: Review variable and class names (AI skills)

- [ ] **Step 1:** Run the `pf-workshop:css-var-analyzer` skill on `webpack/` and `app/assets/stylesheets/` for undefined or v5-only `--pf-` vars. Fix each hit using the PF6 token docs.
- [ ] **Step 2:** Run the `design-audit:pf-raw-colors-scan` skill on the same paths. Replace hot-pink placeholders and raw colors with semantic `--pf-t--global--*` tokens.
- [ ] **Step 3:** Run the `react:pf-import-checker` skill on `webpack/`. Fix invalid PF6 import paths.
- [ ] **Step 4:** Replace the React token by hand in `HostDetails/Status/GlobalState.js`: `global_success_color_100` → `t_global_icon_color_status_success_default`. `charts/helpers/LegendHelpers.js` keeps `chart_color_black_500`, which still exists in react-tokens 6.7.0.
- [ ] **Step 5: Gate.** `grep -rIn "t_temp_dev_tbd\|--pf-t--temp--dev--tbd\|pf-v5-\|global_.*_color_" webpack app script/lint` returns nothing.
- [ ] **Step 6:** Run the `foreman-ui-reviewer` skill on the branch diff. Fix the findings, run the build, `npm test` and stylelint, then commit.

### Task 6: Breakpoints px → rem

**Files:**
- `webpack/assets/javascripts/react_app/common/variables.scss:12-22`
- `webpack/assets/javascripts/react_app/components/PF4/Bookmarks/bookmarks.scss:14,21`
- px media queries: `dashboard/gridster.scss:10,36`, `ColumnSelector/column-selector.scss:8`, `AuditsList/audit.scss:7`, `HostDetails/HostDetails.scss:9,19`, `app/assets/stylesheets/base.scss:594`, `patternfly_and_overrides.scss:58`

- [ ] **Step 1:** In `variables.scss`, replace `@import '~@patternfly/patternfly/base/patternfly-variables'` with `@import '~@patternfly/patternfly/sass-utilities/scss-variables'`. The PF6 base file loads its variables via `@use`, so it does not expose `$pf-v6-*` to `@import`ers. Rename `$pf-v5-global--{font,fonticon,image}-path` → `$pf-v6-…` and set `$pf-prefix: 'pf-v6-'`. Set `$header-max-width: calc(#{$pf-v6-global--breakpoint--lg} + 70px)`.
- [ ] **Step 2:** In `bookmarks.scss`, use `$pf-v6-global--breakpoint--xl` / `--2xl`.
- [ ] **Step 3:** Convert hard-coded px breakpoints that correspond to PF breakpoints to the PF6 vars: 768px → `$pf-v6-global--breakpoint--md` (48rem), 992px → `--lg` (62rem), 1200px → `--xl` (75rem). Convert `max-width: 767px` to `max-width: calc(#{$pf-v6-global--breakpoint--md} - 1px)`. Leave non-PF values (`1530px`, `$screen-sm-max` from PF3/bootstrap) unchanged. Files outside the webpack SCSS pipeline (`app/assets/stylesheets/*`) use literal rem values: 48rem / 62rem.
- [ ] **Step 4:** Verify: the webpack build exits 0, `npm run stylelint` passes, and on the dev box resizing across 768/992/1200/1450px toggles the header collapse, bookmarks width, and host-details layout at the same widths as before. Commit.

---

## Execution notes

- Tasks 1–3 leave the branch red between commits; review them as one unit if needed. Tasks 4–6 each start and end green.
- Out of scope / follow-ups: foreman-js vendor-core bump, plugin migrations (16 plugin files use removed deprecated components, 38 use `pf-v5-`), new Modal and DualListSelector APIs, React 18.
