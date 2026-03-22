# Memory Consolidation

## What it does

Runs every night after your working day ends and reviews the day's conversations and notes, distilling anything durable into `MEMORY.md` and `memory/YYYY-MM-DD.md`. Prevents preferences, decisions, and learnings from being lost at context compaction.

OpenClaw has a built-in pre-compaction memory flush, but it only fires when a session is *about* to compact. This job is a proactive second pass — a deliberate end-of-day review that catches anything the automatic flush might miss.

## Cron command

```bash
openclaw cron add \
  --name "memory-consolidation" \
  --cron "45 23 * * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_PREFERRED_MODEL" \
  --message "Review today's conversation and daily note. Extract anything durable into memory. See full prompt in workspace/skills/memory-consolidation.md" \
  --no-deliver
```

## Full prompt

```
You are running end-of-day memory consolidation.

## 1. READ TODAY'S MATERIAL
Read:
- Today's daily brief: [YOUR_VAULT]/01-daily/briefs/$(date +%Y-%m-%d)-kickoff.md
  Focus on the ## 📝 My Notes section
- Today's meeting notes in [YOUR_VAULT]/02-meetings/
  (any files dated today)
- memory/$(date +%Y-%m-%d).md if it exists — don't duplicate what's there

## 2. IDENTIFY DURABLE ITEMS
Extract items worth preserving across sessions:

GOES IN MEMORY.md (long-term, evergreen):
- New preferences about how work should be done
- Decisions made about direction or approach
- Patterns worth remembering (e.g. "Lee prefers shorter outputs")
- Corrections to previous assumptions
- New context about people, projects, or goals

GOES IN memory/YYYY-MM-DD.md (daily log, append):
- Open loops not yet in Todoist
- Context for tomorrow (what was in progress, what got blocked)
- Things to follow up
- Ideas captured but not developed

SKIP:
- Anything already in MEMORY.md
- Routine task completions with no lasting significance
- Meeting content already captured in meeting notes

## 3. WRITE TO MEMORY FILES
If durable items found:
- Append to [WORKSPACE]/MEMORY.md under today's date
- Append to [WORKSPACE]/memory/$(date +%Y-%m-%d).md

If nothing durable found: output "MEMORY_OK — nothing new to store" and stop.

## 4. CONFIRM
Output: "MEMORY_OK — stored [N] items to MEMORY.md, [M] items to daily log"
or: "MEMORY_OK — nothing new"
Do not deliver to any channel.
```

## Model recommendation

**Mid-tier model.** This job requires actual judgment — distinguishing what's genuinely durable from routine noise. A cheap model tends to either store too much (everything looks important) or too little (nothing passes the bar). Sonnet-class is appropriate here.

## Timing rationale

**11:45pm** — chosen to:
- Run after nightly backup (11:10pm)
- Run before the research scan (1:15am)
- Capture the full day including any late evening work
- Give time to process before midnight

## Dependencies

**Vault structure:**
- `[WORKSPACE]/MEMORY.md` — long-term memory file (must exist)
- `[WORKSPACE]/memory/` — daily log directory (created automatically)
- `01-daily/briefs/` — today's brief
- `02-meetings/` — today's meeting notes

**Configuration required:**
Add to `openclaw.json` to enable automatic memory flush at compaction (complements this job):
```json
"agents": {
  "defaults": {
    "compaction": {
      "memoryFlush": {
        "enabled": true,
        "softThresholdTokens": 40000,
        "prompt": "Distil this session to memory/YYYY-MM-DD.md. Focus on decisions, preferences, lessons, blockers. If nothing worth storing: NO_FLUSH",
        "systemPrompt": "Extract only what is worth remembering. Be concise."
      }
    }
  }
}
```

## Gotchas

**This job complements, not replaces, `memoryFlush`.** Enable both. The automatic flush fires mid-session when context is tight. This job fires end-of-day when the full picture is visible. They catch different things.

**MEMORY.md grows without pruning.** Over months, MEMORY.md becomes unwieldy. Add a monthly review pass (or include in monthly vault synthesis) to archive stale entries.

**The two-file split is intentional.** `MEMORY.md` is evergreen — loaded in every session. `memory/YYYY-MM-DD.md` is temporal — read at session start for today and yesterday only. Don't put temporary context in `MEMORY.md` or it loads permanently.

**Silent failures are especially bad here.** If this job fails silently for a week, you lose a week of learnings. Check `openclaw cron runs --id <jobId>` periodically to verify it's running.
