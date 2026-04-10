# Special Flows & Engine Instructions

## 1. Push (`/od push`)

```yaml
context_requires:
  scan:
    - git status                     # modified files list
    - git diff --staged              # after staging, for commit message generation
  skip:
    - all state files                # push doesn't need OmniDev state
```

1. `git status` → show modified files.
2. If `interactive_mode` is `true`, use `AskQuestion`:
   - **一键全自动 (One-click)**: `git add .` -> auto-generate message -> commit -> push.
   - **手动选择 (Manual)**: wait for user to `git add`, then generate message.
   - **取消 (Cancel)**.
3. If `interactive_mode` is `false`, wait for user to `git add`, then generate message.
4. Confirm message (AskQuestion if interactive).
5. `git commit` + `git push origin <current-branch>`.

## 2. Change Management (`/od change`)

```yaml
context_requires:
  read:
    - 00-project-context.md          # stack info for impact scope
    - 02-plan.md                     # current plan to assess impact against
    - 03-progress.md                 # what's already done (can't undo)
    - 04-design.md                   # architectural constraints
  scan:
    - files affected by the proposed change
```

1. Assess impact on current architecture.
2. If interactive, use `AskQuestion` to confirm: Proceed / Revise / Cancel.
3. Archive old plan, regenerate blueprint/plan.

## 3. Report (`/od report`)

```yaml
context_requires:
  read:                              # report needs the full picture
    - 00-project-context.md
    - 02-plan.md
    - 03-progress.md
    - metrics.json
    - archive/*                      # historical progress
  scan:
    - git log --since="7 days ago"
```

1. Read all state files + `archive/`.
2. Analyze `git log` (past 7 days).
3. Generate management-ready report in `docs/omnidev-state/weekly-report-[date].md`.
4. Include: executive summary, AI-assisted achievements, progress, blockers, next week plan.

## 4. Context Pruning (`/od compress` or Auto-trigger)

**Triggers:** `03-progress.md` > 200 lines, 3+ M-level tasks done, or `/od compress`.
**Action:**
1. Archive resolved logs to `docs/omnidev-state/archive/progress-archive-[date].md`.
2. Condense to 1-2 sentence summary at top of `03-progress.md`.
3. Retain: YAML frontmatter, current blockers, next action.
4. Keep `03-progress.md` under 50 lines.

## 5. Update & Install

- **Update (`/od up`)**: Warn user. Overwrite same-name files, delete obsolete local files.
- **Install (`/od i <url>`)**: Clone to `_omnidev-kit-tmp`, copy rules/skills, cleanup.