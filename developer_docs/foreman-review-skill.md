# Foreman PR Review

<!-- Usage: copy this file to .claude/commands/foreman-review.md in your local
     checkout, then invoke with /foreman-review in Claude Code. -->

Perform a comprehensive review of the current branch's changes following the
Foreman project's PR review standards from developer_docs/pr_review.asciidoc
and the Foreman Handbook.

Review argument: $ARGUMENTS

## Step 1: Setup

Detect the project type by checking for these markers:
- **Core**: `app/registries/foreman/plugin.rb` exists
- **Plugin**: `*.gemspec` matching `foreman_*` and `Foreman::Plugin.register` in `lib/`
- **Smart Proxy**: `smart_proxy*.gemspec`

### Determining the diff range

The review must cover **only the commits on the current branch that are not in
the upstream main branch**. Auto-detect the base by running:

```bash
# Find the upstream main branch automatically.
# If $ARGUMENTS specifies a base, use that. Otherwise detect:
# 1. List all remote refs matching common default branch names
# 2. Pick the first one that exists
for ref in upstream/master upstream/main upstream/develop origin/master origin/main origin/develop; do
  if git rev-parse --verify "$ref" >/dev/null 2>&1; then
    BASE_BRANCH="$ref"
    break
  fi
done
echo "BASE_BRANCH=$BASE_BRANCH"
```

Then scope the review to only the current branch's commits:

```bash
MERGE_BASE=$(git merge-base $BASE_BRANCH HEAD)
git log --oneline $MERGE_BASE..HEAD          # commits to review
git diff $MERGE_BASE..HEAD --stat            # files changed
git diff $MERGE_BASE..HEAD                   # full diff
```

**Only review changes from these commits.** Do not include commits already in
the upstream main branch.

## Step 2: Convention Checks

Scan the diff output for the following Foreman convention violations. For each
check, grep the added lines and report any matches before proceeding.

1. **Commit format**: Every commit must match `^(Fixes|Refs) #[0-9]+`
2. **View extensions**: New `app/views/**/*.erb` must have format prefix (`.html.erb`)
3. **Exception types**: New exceptions must inherit `Foreman::Exception`
4. **Logger blocks**: `logger.debug` with `#{}` must use block form
5. **Concern pattern**: Use `ActiveSupport::Concern`, not `class_eval`
6. **app/ vs lib/**: New service/model classes belong in `app/`, not `lib/`
7. **Unsafe reflection**: No `.to_sym`/`.send` on `params`
8. **scoped_search**: `:ext_method` requires `:only_explicit => true`
9. **Deprecation**: Use `Foreman::Deprecation`, not `ActiveSupport::Deprecation`
10. **i18n**: User-facing strings should be wrapped in `_()`

Report all findings from this phase before proceeding.

## Step 3: AI-Based Assessment

For each of the following, examine the diff and relevant surrounding code.
Only report findings where you have evidence — do not speculate.

### 3.1 Does the PR address the stated issue?

Read the commit messages to find the `Fixes #XXXX` or `Refs #XXXX` reference.
Assess whether the changes plausibly address the title's description. Flag if:
- The diff appears unrelated to the commit message description
- The change scope seems too narrow or too broad for the stated fix

### 3.2 Unrelated changes

Look for files or hunks that don't relate to the primary purpose. Flag:
- Whitespace-only changes in unrelated files
- Style-only refactors mixed with bug fixes
- Opportunistic cleanups that should be separate PRs

### 3.3 Test coverage

For each new public method, controller action, or significant behavior change:
- Check if there is a corresponding test in `test/` (Ruby) or `__tests__/` (JS)
- For Ruby: look in `test/models/`, `test/controllers/`, `test/functional/`,
  `test/integration/`, or `test/graphql/` matching the changed file
- For JS: look for `*.test.js` files alongside or under `__tests__/`
- Flag new behavior without any test coverage
- Note: "tests exist" is different from "tests are meaningful" — look at
  what the tests actually assert

### 3.4 Permissions for non-admin users

If the diff adds new controller actions:
- Check for `authorize` calls or `before_action :find_resource`
- Look for permission definitions in the plugin's `security_block` or
  in `app/registries/foreman/access_control.rb`
- Flag new actions that lack authorization checks

For core: also check `app/models/permission.rb` data.
For plugins: check the `Foreman::Plugin.register` block for `permission` calls.

### 3.5 ActiveRecord validators on new fields

If `db/migrate/` files add new columns:
- Identify the corresponding model file
- Check for `validates` declarations covering the new fields
- Pay special attention to NOT NULL columns that lack presence validators
- Flag missing validators

### 3.6 Exception handling

Look for `rescue` blocks in the diff that may swallow exceptions:
- `rescue => e` followed by `nil`, empty block, or only logging at info level
- `rescue StandardError` that returns a generic error without details
- Missing `rescue` in blocks that call external services (API calls, file I/O)

Flag blocks that silently swallow errors without logging or re-raising.

### 3.7 Apipie documentation

If new API controller actions are added (under `app/controllers/api/`):
- Check for `api :METHOD, path, description` declarations
- Verify `param` declarations match the action's actual parameters
- Check `:required => true/false` accuracy
- Flag undocumented API endpoints

### 3.8 API backward compatibility

If existing API endpoints are modified:
- Check for removed parameters
- Check for changed response structure (renamed keys, removed fields)
- Check for changed HTTP methods or routes
- These should use `Foreman::Deprecation.api_deprecation_warning` before removal
- Flag breaking changes without deprecation
- **Exception**: If the removed parameters were already marked `:deprecated => true`
  in the base branch (check the previous apipie declarations or `permitted_params`),
  then removal is the expected final step of the deprecation cycle — not a breaking
  change. Mark as PASS in that case.

### 3.9 Performance patterns

Look for common performance issues in the diff:
- N+1 queries: `.each` blocks calling associations without `.includes`
- Unbounded queries: `.all` or `.where(...)` without `.limit` in controllers
- `.to_a` on large ActiveRecord relations
- Missing database indexes for new foreign keys in migrations
- Large string allocations in loops

Only flag patterns with clear evidence, not hypothetical concerns.

### 3.10 API counterparts for new controllers

If a new controller is added under `app/controllers/` (not `api/`):
- Check whether a matching `app/controllers/api/v2/` controller exists
- This is a reminder, not a hard requirement — note it if missing

## Step 4: Human-Only Reminders

At the end of the report, list these items that require human follow-up:
- [ ] Does the new functionality have a Hammer CLI counterpart?
- [ ] Has necessary RPM/deb packaging been done?
- [ ] Who will provide user documentation?
- [ ] Who will provide a community demo (if applicable)?
- [ ] Are Upgrade Notes or New Features docs needed?

## Output Format

Structure the report as:

```
## Foreman PR Review: [commit title or branch name]

**Project type:** core | plugin | smart_proxy
**Commits reviewed:** [count]
**Base:** [branch]

### Convention Checks
[Pass/Warn/Fail per check]

### AI Assessment

#### [Check name] — [PASS | WARNING | ISSUE]
[Explanation with file:line references]

...

### Human Follow-up Required
- [ ] Hammer CLI counterpart
- [ ] Packaging
- [ ] User documentation
- [ ] Community demo
- [ ] Upgrade notes

### Summary
[1-2 sentence overall assessment: ready to merge, needs changes, or needs discussion]
```
