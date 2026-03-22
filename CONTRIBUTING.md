# Contributing

Contributions welcome. The bar is simple: if it's run in production and you know what breaks, it belongs here.

## What we want

- Cron jobs you have actually run, not ones you think would work
- Real prompts, not placeholders
- Honest gotchas  -  if your job has never failed you haven't run it long enough
- Model recommendations with reasoning, not just "use the best model"

## What we don't want

- Jobs copied from the OpenClaw docs examples
- Prompts shorter than the cron command itself
- "TODO: add prompt here"
- Jobs designed to run every minute (heartbeat territory, not cron territory)

## File format

Copy `templates/JOB_TEMPLATE.md` as your starting point. All sections are required except "Example output."

## Which category

| Your job does... | Category |
|-----------------|----------|
| Daily brief, task sync, weekly review, personal reminders | `productivity/` |
| Literature scan, paper ingestion, knowledge synthesis | `research/` |
| Newsletter, LinkedIn drafts, content pipelines | `writing/` |
| Backup, security audit, context cleanup, health checks | `monitoring/` |
| Calendar, meeting prep, scheduling | `calendar/` |
| Doesn't fit above | Open an issue and suggest a category |

## PR checklist

- [ ] File is in the right category folder
- [ ] Filename is `kebab-case.md`
- [ ] All required sections present (see template)
- [ ] Cron command is complete and copy-paste ready
- [ ] Model recommendation includes reasoning
- [ ] At least one gotcha documented
- [ ] No real credentials, channel IDs, or personal paths in the prompt

## Versioning note

OpenClaw moves fast. If a job stops working after an update, open an issue or PR with the fix and note the version where it broke. The community benefits from knowing.
