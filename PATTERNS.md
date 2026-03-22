# Patterns & Anti-patterns

Hard-won lessons from running multiple cron jobs in production.

---

## Isolated vs main session

**Always use isolated for background jobs.**

Main session jobs interrupt your conversation. If you're mid-chat when the nightly backup fires, it drops a system event into your thread. Isolated jobs run in their own context and deliver a summary only when they finish.

```bash
# ✅ Correct
--session isolated --announce

# ❌ Avoid for background jobs
--session main
```

The one exception: simple one-time reminders where you *want* the interruption.

---

## API quota collision

If you run multiple jobs at the same time they compete for the same rate limit and one silently fails. Stagger jobs that run on similar schedules.

**Bad  -  three jobs at midnight:**
```
nightly-backup:        0 23 * * *
memory-consolidation:  0 23 * * *
research-scan:         0 23 * * *
```

**Good  -  staggered:**
```
nightly-backup:        10 23 * * *   # 11:10pm
memory-consolidation:  45 23 * * *   # 11:45pm
research-scan:         15 1  * * *   # 1:15am
```

Rule of thumb: 30+ minutes between jobs that call external APIs.

---

## Model tiering by job type

Don't use your best model for everything. Cost adds up fast with always-on cron jobs.

| Job type | Recommended model | Reasoning |
|----------|------------------|-----------|
| Daily brief with web search | `openrouter/anthropic/claude-sonnet-4-5` | Needs reasoning + search |
| Deep research synthesis | `openrouter/anthropic/claude-sonnet-4-5` | Quality matters |
| Nightly Tavily scan | Cheaper model | Structured output, low reasoning needed |
| Todoist sync | Cheapest viable | Deterministic task |
| Backup | Cheapest viable | Shell commands only |
| Newsletter writing | `openrouter/anthropic/claude-sonnet-4-5` | Voice quality critical |

---

## Memory flush before compaction

Long-running sessions lose context at compaction unless you configure `memoryFlush`. Add this to `openclaw.json`:

```json
"agents": {
  "defaults": {
    "compaction": {
      "memoryFlush": {
        "enabled": true,
        "softThresholdTokens": 40000,
        "prompt": "Distil this session to memory/YYYY-MM-DD.md. Focus on decisions, preferences, lessons. If nothing worth storing: NO_FLUSH",
        "systemPrompt": "Extract only what is worth remembering. Be concise."
      }
    }
  }
}
```

Without this, every cron job that runs a long session quietly discards anything worth remembering.

---

## Delivery: Discord vs Telegram

**Discord:** best for structured output, multiple channels, and team-visible logs. Use for daily briefs and weekly councils where you want a permanent record.

**Telegram:** best for alerts and time-sensitive notifications. Use for "something needs attention now" rather than "here's your weekly synthesis."

**Silent jobs:** use `--no-deliver` or omit `--announce` for maintenance jobs (backup, sync) where output is written to files and you don't need a notification.

---

## Multi-agent chaining with sessions_spawn

When Stage 1 needs to hand off to Stage 2, use `sessions_spawn` inside the Stage 1 prompt rather than two separate cron jobs. This ensures Stage 2 only runs when Stage 1 completes successfully.

```
sessions_spawn: {
  task: "Read the brief at [path] and follow [skill]. Produce all outputs.",
  model: "openrouter/anthropic/claude-sonnet-4-5",
  session: "isolated"
}
```

**Why not two cron jobs?**
- Two jobs at different times means Stage 2 might run before Stage 1 finishes
- If Stage 1 fails, Stage 2 runs on stale data
- Spawning keeps them coupled correctly

---

## Skills vs inline prompts

For short jobs (backup, sync, reminder) put the full prompt inline in `--message`.

For complex jobs (research scan, newsletter pipeline) put the prompt in a skill file and reference it:

```bash
--message "Read and follow the skill at workspace/skills/weekly-synthesis.md exactly."
```

**Why:** skill files are editable without touching the cron config. Update the skill, the next cron run automatically uses the new version. Inline prompts require `openclaw cron edit` every time.

---

## Monday lookback

Daily jobs that read "yesterday's" notes break over weekends  -  Monday morning's job looks back to Sunday, which is blank.

Fix: add an explicit Monday check in any job that reads yesterday's output.

```
If today is Monday, also read Friday's file at:
[path]/$(date -d '3 days ago' +%Y-%m-%d).md
```

---

## Deduplication in research jobs

Without deduplication, nightly research scans resurface the same papers every night. Add an explicit check:

```
Before including any item, check whether it already appears in
05-knowledge/concepts/ or was included in yesterday's brief.
Do not resurface items already seen.
```

---

## Testing before scheduling

Always test a new job manually before setting the schedule:

```bash
# Register the job disabled first
openclaw cron add --name "test-job" --cron "0 7 * * *" --disabled ...

# Run it manually
openclaw cron run <jobId>

# Check the output
openclaw cron runs --id <jobId> --limit 3

# Enable only when it looks right
openclaw cron enable <jobId>
```

A job that fails silently at 1am is much harder to debug than one you ran manually and watched fail.


Related tools & skills
---
The OpenClaw ecosystem includes diagnostic and visualization skills that complement the patterns here. Notable examples:
- cron-doctor — a diagnostics skill that audits cron jobs and their recent runs
- cron-visualizer — a visualization skill for job schedules and quota usage over time

Use these alongside the patterns in this doc for operational debugging and visibility.
