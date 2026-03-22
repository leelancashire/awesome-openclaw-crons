🛠 Contributing

Contributions welcome. The bar is practical: if a cron job has run in production and you can describe what broke, it belongs here.

What we want
- ✅ Cron jobs you have actually run (not theoretical)
- ✅ Real prompts (no placeholders)
- ✅ Honest gotchas — what broke, and why
- ✅ Model recommendations with reasoning

What we don’t want
- ❌ Jobs copied verbatim from the OpenClaw docs examples
- ❌ Prompts shorter than the cron command itself
- ❌ “TODO: add prompt here” placeholders
- ❌ Jobs designed to run every minute (heartbeat territory)

File format
- Start from `templates/JOB_TEMPLATE.md`. All sections required except "Example output".

Which category?
- productivity/ — daily brief, todo sync, weekly review
- research/ — literature scan, ingestion, knowledge synthesis
- writing/ — newsletters, LinkedIn, content pipelines
- monitoring/ — backups, audits, health checks
- calendar/ — meeting prep, scheduling

PR checklist
- File in the right category folder
- Filename is kebab-case.md
- All required sections present (see template)
- Cron command is complete and copy-paste ready
- Model recommendation includes reasoning
- At least one gotcha documented
- No real credentials, personal channel IDs, or private paths included

Versioning note
OpenClaw moves fast. If a job breaks after an update, open an issue/PR with the fix and note the version where it broke.
