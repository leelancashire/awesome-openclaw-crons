⚠️ Patterns & Anti-patterns

Hard-won lessons from running multiple cron jobs in production.

🔒 Isolated vs main session
Always use `--session isolated` for background jobs. Main session jobs interrupt interactive threads and can drop system events into conversations.

✅ Correct
```
--session isolated --announce
```

❌ Avoid for background jobs
```
--session main
```

One exception: simple one-off reminders where you want the interruption.

⏱ API quota collision
If multiple jobs run at the same time they compete for rate limits and some can fail silently. Stagger jobs that call external APIs.

Bad — three jobs at midnight:
```
nightly-backup:      0 23 * * *
memory-consolidation:0 23 * * *
research-scan:       0 23 * * *
```

Good — staggered:
```
nightly-backup:       10 23 * * *   # 23:10
memory-consolidation: 45 23 * * *   # 23:45
research-scan:        15 1  * * *   # 01:15
```

Rule of thumb: leave 30+ minutes between jobs that call external APIs.

🔢 Model tiering by job type
Match model capability to task — don’t run your best model for trivial jobs.

| Job type | Recommended model | Reasoning |
|---|---:|---|
| Daily brief (web search) | openrouter/anthropic/claude-sonnet-4-5 | reasoning + web search
| Deep research synthesis | openrouter/anthropic/claude-sonnet-4-5 | quality matters
| Nightly Tavily scan | cheaper model | structured output, low reasoning
| Todoist sync | cheapest viable | deterministic tasks
| Backup | cheapest viable | shell commands only
| Newsletter writing | openrouter/anthropic/claude-sonnet-4-5 | voice / narrative quality

💾 Memory flush before compaction
Long-running sessions can lose context at compaction. Add a memoryFlush config to `openclaw.json`:

```json
"agents": {
  "defaults": {
    "compaction": {
      "memoryFlush": {
        "enabled": true,
        "softThresholdTokens": 40000,
        "prompt": "Distil this session to memory/YYYY-MM-DD.md. Focus on decisions, preferences.",
        "systemPrompt": "Extract only what is worth remembering. Be concise."
      }
    }
  }
}
```

🚚 Delivery: Discord vs Telegram
- Discord: structured output, team-visible logs — good for daily briefs and councils.
- Telegram: time-sensitive alerts — use for urgent notifications.
- Silent jobs: use `--no-deliver` or omit `--announce` for maintenance jobs (backup/sync).

🔗 Multi-agent chaining with `sessions_spawn`
When Stage 1 hands off to Stage 2, spawn Stage 2 from within Stage 1 (use `sessions_spawn`) so Stage 2 runs only after Stage 1 completes successfully.

🧪 Testing before schedule
Always test manually first:

```bash
# register disabled
openclaw cron add --name "test-job" --cron "0 7 * * *" --disabled ...
# run manually
openclaw cron run <jobId>
# inspect
openclaw cron runs --id <jobId> --limit 3
# enable when it looks right
openclaw cron enable <jobId>
```

A job that fails silently at 01:00 is much harder to debug than one you observed fail when running manually.