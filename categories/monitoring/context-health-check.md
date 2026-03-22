⚙️ CONTEXT HEALTH CHECK

What it does
---
Checks session context sizes and compaction health across agents, and triggers memoryFlush or notification if thresholds are exceeded.

Cron command (example)
```bash
openclaw cron add \
  --name "context-health-check" \
  --cron "*/360  * * * *" \
  --tz "UTC" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Check agent session sizes and report any near-compaction state." \
  --announce
```

What to check
- Number of tokens per session
- Sessions near compaction thresholds
- Whether memoryFlush has been configured in openclaw.json

Deliverable
- Short report listing sessions at risk and suggested remediation steps (increase memoryFlush thresholds, split long-running sessions, or summarise content to MEMORY.md).

Gotchas
- Running this job too often may itself contribute to API usage; schedule conservatively (e.g. every 6 hours).
