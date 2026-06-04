# AI Review Skill Analysis for the Foreman Ecosystem

## 1. Catalog of Review Standards

The Foreman project defines review standards across four source documents.
This catalog enumerates every standard with its source and scope.

### 1.1 PR Review Checklist (`developer_docs/pr_review.asciidoc`)

| ID | Standard | Category | Scope |
|----|----------|----------|-------|
| R1 | Ticket number, title, and description are correct | Issue hygiene | All |
| R2 | Fixes the problem described in the issue | Issue hygiene | All |
| R3 | No unrelated changes present | Issue hygiene | All |
| R4 | Redmine opened for the correct project | Issue hygiene | All |
| R5 | No `.to_sym`, `.send` or reflection on untrusted inputs | Security | All |
| R6 | All strings extracted for translation | i18n | Core, Plugin |
| R7 | String extractions follow `:mark_translated: true` rules | i18n | Core, Plugin |
| R8 | Appropriate permissions for non-admin users | Security | Core, Plugin |
| R9 | No code copy-pasted from elsewhere | Code quality | All |
| R10 | All new AR fields have appropriate validators | Code quality | Core, Plugin |
| R11 | No exceptions swallowed or squashed | Code quality | All |
| R12 | New exceptions use `Foreman::Exception` or `WrappedException` | Code quality | All |
| R13 | Covered with meaningful unit/functional/integration tests | Testing | All |
| R14 | View templates have `.html.erb` extensions, not `.erb` | Rails conventions | Core, Plugin |
| R15 | Mixins use `ActiveSupport::Concern`, not `class_eval` | Rails conventions | Core, Plugin |
| R16 | Concerns and classes in `app/`, not `lib/` | Rails conventions | Core, Plugin |
| R17 | Apipie documentation correct: methods, params, required | API | Core, Plugin |
| R18 | `scoped_search` definitions for new model attributes | API | Core, Plugin |
| R19 | `scoped_search :ext_method` uses `:only_explicit` | API | Core, Plugin |
| R20 | Appropriate Rails logging with debug statements | Logging | All |
| R21 | `logger.debug` uses block form for lazy evaluation | Logging | All |
| R22 | Deprecations use `Foreman::Deprecation` with correct deadline | Compatibility | All |
| R23 | New controllers/actions have API counterparts | API | Core, Plugin |
| R24 | New controllers/actions have Hammer CLI counterparts | Compatibility | Core, Plugin |
| R25 | Public HTTP API not changed incompatibly | Compatibility | All |
| R26 | No memory or performance concerns | Performance | All |
| R27 | Necessary packaging done | Ops | All |
| R28 | Agreed who provides user documentation | Ops | All |
| R29 | Agreed who provides community demo | Ops | All |
| R30 | Agreed who provides Upgrade Notes / New Features docs | Ops | All |

### 1.2 Foreman Handbook (`theforeman.org/handbook.html`)

| ID | Standard | Category |
|----|----------|----------|
| H1 | Commit message format: `Fixes #XXXX - description` | Process |
| H2 | 50-char summary line, 72-char body wrap | Process |
| H3 | Linear git history (rebase, no merge commits) | Process |
| H4 | Ruby: use `blank?`/`present?` over `empty?`/`nil?` | Code style |
| H5 | Reversible migrations | Code quality |
| H6 | JS: ES2015+ via Babel, PatternFly components | Code style |
| H7 | JS: React Testing Library, not Enzyme/snapshots | Testing |
| H8 | JS: prefer hooks over Redux | Code style |
| H9 | Tests: MiniTest, `build` over `create`, stubs for external calls | Testing |
| H10 | Deprecation: JS via `tfm.tools.deprecate` | Compatibility |
| H11 | Deprecation: API via `Foreman::Deprecation.api_deprecation_warning` | Compatibility |
| H12 | API stability: SemVer 2.0, breaking changes need major version bump | Compatibility |

### 1.3 CONTRIBUTING.md

| ID | Standard | Category |
|----|----------|----------|
| C1 | Tests required for bug fixes and new features | Testing |
| C2 | String extraction for translation | i18n |
| C3 | Commit format reference | Process |

### 1.4 PR Template (`.github/PULL_REQUEST_TEMPLATE.md`)

| ID | Standard | Category |
|----|----------|----------|
| T1 | Create Redmine issue before PR | Process |
| T2 | Reference issue via `Fixes #1234` in commit | Process |
| T3 | Present-tense imperative commit messages | Process |
| T4 | `[WIP]` prefix for work-in-progress | Process |
| T5 | Screenshots for UI changes | Documentation |
| T6 | Testing prerequisites documented | Testing |

## 2. Classification: Deterministic vs AI-Based

### 2.1 Already automated by existing tooling

These standards are enforced by CI and need no additional tooling.

| Standard | Tool | CI Status |
|----------|------|-----------|
| Ruby code style (H4) | RuboCop via `theforeman-rubocop` lenient | Blocking |
| JS code style (H6, H8) | ESLint + Prettier | Blocking |
| React hooks rules | `eslint-plugin-react-hooks` | Blocking |
| PatternFly `ouiaId` props | Custom ESLint rule `require-ouiaid.js` | Blocking |
| Component file length ≤300 lines | ESLint `max-lines` | Blocking |
| Test suites pass (C1) | Minitest + Jest | Blocking |
| GraphQL tests | Minitest | Blocking |
| Webpack compilation | `webpack:compile` | Blocking |
| API doc generation | `apipie:cache` | Blocking |
| Asset precompilation | `assets:precompile` | Blocking |
| DB seed validity | `db:seed` | Blocking |
| Plugin compatibility | Plugin React tests workflow | Non-blocking |
| Single commit per PR | `single_commit.yml` | Non-blocking |
| PR labeling | `labeler.yml` | Automated |
| Stale PR cleanup | `stale.yml` | Automated |
| Redmine linkage | PR Processor bot | Automated |

### 2.2 Deterministic — recommended as custom RuboCop cops

These are rule-based checks that can be implemented as linter rules. Six of
them map directly to custom RuboCop cops in `theforeman-rubocop`; the
remaining three are handled by the AI review skill.

#### Recommended custom cops for `theforeman-rubocop`

| Cop name | Replaces | Pattern | Auto-correctable |
|----------|----------|---------|-----------------|
| `Foreman/ExceptionBaseClass` | R12 | `class XError < StandardError` | No |
| `Foreman/LoggerBlockForm` | R21 | `logger.debug "...#{x}"` without block | Yes |
| `Foreman/ConcernPattern` | R15 | `class_eval` outside known infra files | No |
| `Foreman/UnsafeReflection` | R5 | `params[].to_sym` or `.send` | No |
| `Foreman/ScopedSearchExplicit` | R19 | `:ext_method` without `:only_explicit` | Yes |
| `Foreman/DeprecationMethod` | R22 | Direct `ActiveSupport::Deprecation` use | Yes |

These cops would go in `lib/rubocop/cop/foreman/` in the `theforeman-rubocop`
gem. They would run in existing CI for all repos that use the gem.

#### Covered by AI review skill (not suited for RuboCop)

| Standard | Why not RuboCop |
|----------|-----------------|
| R14: View extensions | File naming convention, not Ruby code |
| R16: app/ vs lib/ | File placement, not Ruby code |
| R6: i18n wrapping | Includes ERB templates, which RuboCop doesn't lint |

### 2.3 AI-based — requires judgment

These checks cannot be reduced to pattern matching. AI review adds value here
by reading the diff in context and applying Foreman domain knowledge.

| Standard | What AI evaluates | Value-add |
|----------|-------------------|-----------|
| R2: Fixes described issue | Commit message intent vs diff scope | Catches scope mismatches |
| R3: No unrelated changes | File relevance to stated purpose | Catches opportunistic cleanups |
| R13: Meaningful test coverage | Test existence + assertion quality | Goes beyond "test exists" |
| R8: Permissions for non-admin | Authorization checks on new actions | Cross-file reasoning |
| R10: AR validators | New migration columns vs model validators | Cross-file reasoning |
| R11: Exceptions not swallowed | Rescue blocks with empty/silent handling | Context-dependent severity |
| R17: Apipie documentation | Param declarations vs actual params | Cross-file matching |
| R25: API backward compat | Removed/renamed params, changed responses | Semantic diff analysis |
| R26: Performance concerns | N+1 queries, unbounded `.all`, loops | Pattern + context |
| R23: API counterparts | New UI controllers without API match | Cross-directory scan |
| R9: Code duplication | Semantic similarity, not just text match | Understanding intent |

### 2.4 Human-only — requires coordination or external systems

| Standard | Why automation can't help |
|----------|--------------------------|
| R4: Correct Redmine project | Requires Redmine access + project taxonomy knowledge |
| R24: Hammer CLI counterparts | Requires cross-repo work (hammer-cli-foreman) |
| R27: Packaging done | Requires RPM/deb build + testing |
| R28-30: Documentation/demo/upgrade notes | Social coordination between people |

### 2.5 Coverage summary

| Category | Count | Coverage |
|----------|-------|----------|
| Already automated (CI) | 17 | Existing tooling (includes commit format via PR Processor) |
| Recommended as custom RuboCop cops | 6 | `theforeman-rubocop` (proposed) |
| AI-based — covered by `/foreman-review` command | 14 | AI review skill |
| Human-only | 5 | Reminder list in skill output |
| **Total** | **42** | |

Note: The 14 AI-based checks include the 3 deterministic checks not suited
for RuboCop (view extensions, app-vs-lib placement, i18n wrapping) plus the
11 judgment-based checks from section 2.3.

## 3. Review Feedback Patterns from Human Reviewers

Analysis of inline review comments on 15 recent merged PRs (theforeman/foreman),
ranked by frequency:

### 3.1 Most common feedback categories

1. **Logic / correctness bugs** (most frequent)
   - Edge cases, stale state, nil handling, behavioral regressions
   - Example (PR #10982): "Won't this break resolving `automatic` for image based provisioning?"
   - Example (PR #10983): "But wouldn't the onBlur get called with possibly stale displayValue?"
   - **AI overlap: HIGH** — these follow patterns learnable from the codebase

2. **Code style / simplification**
   - Better variable names, unnecessary code removal, simpler conditionals
   - Example (PR #10984): "Given IPMI and Redfish are the only providers left, this could just be `ipmi.credentials_present?`"
   - **AI overlap: HIGH** — `/simplify` and `/code-review` target this

3. **Convention violations (Foreman-specific)**
   - Redundant `N_()` wrapping, PatternFly utility classes vs custom CSS, `Refs #` vs `Fixes #`
   - **AI overlap: MEDIUM** — deterministic script catches some, AI catches the rest

4. **Test coverage requests**
   - Example (PR #10982): "I think it would be good to add a test case for 'firmware: automatic'"
   - Example (PR #10983): "Please add test coverage for both the default clear behavior and the opt-out path"
   - **AI overlap: MEDIUM** — AI can flag missing tests but can't judge sufficiency perfectly

5. **Architecture / design**
   - Example (PR #10982): "Why aren't we fixing it in the CR model for all CRs, instead of only for VMware?"
   - **AI overlap: MEDIUM** — AI can suggest broader scope but lacks community context

6. **API / documentation / packaging**
   - Release notes, version mismatches, upgrade warnings
   - **AI overlap: LOW** — requires external knowledge

7. **Security and performance** — absent from sample (rare in practice)

### 3.2 Key insight

The top two categories (logic bugs + simplification) are exactly where AI adds
the most value. Linters can't catch them, but they follow patterns that AI can
learn from the codebase. Foreman-specific conventions are split: some are
deterministic (commit format, view extensions) and now automated; others require
AI judgment (appropriate PF component choice, scope of a fix).

## 4. Validation Results

### 4.1 Convention check coverage

The 10 deterministic convention checks were validated against a synthetic
branch with intentional violations — all 10 patterns were correctly identified.
Six of these checks are recommended as custom RuboCop cops in
`theforeman-rubocop` (see section 2.2); the remaining four are covered by the
AI review skill directly.

Five merged PRs were also checked. All passed clean, which is expected — these
PRs went through human review and were merged before landing.

### 4.2 AI assessment value-add analysis

For the three PRs with available review comments, here is what AI assessment
would have caught that the deterministic script cannot:

**PR #10982 (firmware type normalization)**
- Actual reviewer feedback: "Why aren't we fixing it in the CR model for all CRs?" (architecture scope), "Won't this break resolving automatic?" (logic bug), "Add a test case for firmware: automatic" (test coverage)
- AI could catch: The architecture concern (diff only touches VMware/Libvirt but the method is on ComputeResource base class), the missing test for the 'automatic' firmware case
- AI would miss: The deep VMware clone-method archaeology that led to the final fix

**PR #10984 (BMC SSH removal)**
- Actual reviewer feedback: "Given IPMI and Redfish are the only providers left, this could just be `ipmi.credentials_present?`" (simplification)
- AI could catch: The now-redundant provider inclusion check (dead code after removing SSH)
- AI would miss: The git history context about why the check existed in the first place

**PR #10983 (AutocompleteInput)**
- Actual reviewer feedback: "Wouldn't onBlur get called with possibly stale displayValue?" (logic bug), "Add test coverage for both clear behavior and opt-out" (test coverage)
- AI could catch: The stale state concern (onBlur reads displayValue before clear), the test coverage gap
- AI would miss: Nothing significant — these are pattern-matching concerns AI handles well

### 4.3 Estimated review time impact

| Phase | Without skill | With skill |
|-------|---------------|------------|
| Convention checks (R5, R12, R14-16, R19, R21-22, H1) | 5-10 min manual | 0 min (automated) |
| Code quality assessment (R2-3, R9-11, R13, R17, R25-26) | 15-30 min reading | 5-10 min reviewing AI findings |
| Human-only items (R4, R24, R27-30) | Unchanged | Unchanged (skill reminds) |
| **Estimated total** | **25-45 min** | **10-20 min** |

The biggest time saving comes from automating convention checks (eliminating
back-and-forth on formatting issues) and front-loading AI assessment (reviewer
starts with a list of potential issues to verify rather than discovering them
from scratch).

## 5. Integration Recommendations

### 5.1 Short-term: Custom RuboCop cops in `theforeman-rubocop`

Six deterministic checks map cleanly to RuboCop cops and would benefit
the entire ecosystem (all repos using `theforeman-rubocop`):

| Cop | Standard | Benefit |
|-----|----------|---------|
| `Foreman/ExceptionBaseClass` | R12 | Prevents wrong inheritance at write time |
| `Foreman/LoggerBlockForm` | R21 | Enforced at lint time, auto-correctable |
| `Foreman/ConcernPattern` | R15 | Flags `class_eval` outside known infra paths |
| `Foreman/UnsafeReflection` | R5 | Catches `.to_sym`/`.send` on params |
| `Foreman/ScopedSearchExplicit` | R19 | Catches `:ext_method` without `:only_explicit` |
| `Foreman/DeprecationMethod` | R22 | Catches direct `ActiveSupport::Deprecation` calls |

These would go in `lib/rubocop/cop/foreman/` in the `theforeman-rubocop` gem.
Once released, they run in existing CI for all repos that use the gem — no
per-repo workflow needed.

### 5.2 Short-term: ESLint rule for i18n

Extend `script/lint/@theforeman/eslint-plugin-rules/` with a rule that flags
unwrapped string literals in JSX. This follows the existing pattern of
`require-ouiaid.js` (a custom Foreman-specific ESLint rule).

### 5.3 Medium-term: Shared workflow integration for plugins

The `theforeman/actions` repo provides shared GitHub Actions workflows that
plugins use. Once the custom RuboCop cops are released in `theforeman-rubocop`,
all plugins that use the gem get convention checking automatically — no
per-plugin configuration needed.

### 5.4 Medium-term: Smart-proxy convention checking

Smart-proxy uses a standalone RuboCop config (not `theforeman-rubocop`).
Adding `theforeman-rubocop` as a dependency and enabling the new cops would
bring convention checking to smart-proxy as well. Only the non-Rails cops
(ExceptionBaseClass, LoggerBlockForm, DeprecationMethod, UnsafeReflection)
apply — the Rails-specific cops (ConcernPattern, ScopedSearchExplicit) should
be scoped accordingly.

### 5.5 Where AI-based checks add irreplaceable value

These review concerns cannot be automated with deterministic tooling and
represent the strongest case for AI-assisted review:

1. **Logic bugs and edge cases** — The most common review feedback category.
   AI can reason about state flow, nil handling, and conditional logic in
   ways that linters cannot. Example: detecting that removing an enum value
   leaves a now-redundant inclusion check (PR #10984).

2. **Cross-file consistency** — Checking that a new migration column has a
   model validator, or that a new controller action has an API counterpart,
   requires reading multiple files together.

3. **Test coverage quality** — Beyond "does a test exist," AI can assess
   whether tests cover edge cases. Example: detecting a missing test for
   the `firmware: automatic` case (PR #10982).

4. **API backward compatibility** — Detecting removed parameters or changed
   response structures requires understanding the semantic meaning of changes,
   not just their syntax.

5. **Scope assessment** — Flagging unrelated changes or suggesting that a fix
   should apply more broadly (as in the VMware-only vs all-CRs discussion
   in PR #10982).

### 5.6 Handbook consolidation recommendation

Review standards are currently fragmented across:
- `handbook.md` in `theforeman/theforeman.org` repo
- `developer_docs/pr_review.asciidoc` in `theforeman/foreman` repo
- Divergent `CONTRIBUTING.md` files across repos
- PR template in HTML comments (invisible to submitters)

**Recommendation:** Consolidate into `developer_docs/handbook.md` in the core
repo. The website can link to it. This puts standards next to the code where
AI tools and CI can consume them directly. Keep per-repo `CONTRIBUTING.md`
files as thin stubs linking to the central document.

## 6. Deliverables Summary

| File | Purpose |
|------|---------|
| `developer_docs/foreman-review-skill.md` | Claude Code `/foreman-review` command (copy to `.claude/commands/` to use) |
| `developer_docs/review_skill_analysis.md` | This document |
