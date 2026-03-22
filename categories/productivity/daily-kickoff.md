✨ DAILY KICKOFF

What it does
---
Runs every weekday morning and delivers a structured daily brief to a channel. It:
- reads the vault and yesterday’s notes
- pulls today’s calendar events
- runs targeted web searches for the last 24h
- writes a formatted brief to the vault with a trailing `## My Notes` section for in-day capture

Cron command (example)
```bash
openclaw cron add \
  --name "daily-kickoff" \
  --cron "0 7 * * 1-5" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Read and follow the skill at workspace/skills/daily-kickoff.md exactly. Run all --announce" \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

Full prompt
---
Store the full prompt in `workspace/skills/daily-kickoff.md` and reference it from the cron message. The skill should:
1. Verify date via shell (TZ-aware)
2. Read vault context (projects, contacts, inbox)
3. Process yesterday’s `## My Notes` section (route `#task`, `#idea`, `#parking`, `#decision`)
4. Pull calendar (filter to Personal/Work as needed)
5. Auto-create meeting note stubs
6. Run web searches across interest areas
7. Write the brief to vault and append `## My Notes`

Model recommendation
---
`openrouter/anthropic/claude-sonnet-4-5` — this job reads multiple files, runs searches and synthesises judgement calls. Use a high-quality model here; cheaper models reduce quality noticeably.

Timing rationale
---
- Run at 07:00 on weekdays (early enough to prep the day)
- If other jobs run around 07:00, stagger by 5–10 minutes
- The brief typically takes 2–3 minutes to complete

Dependencies
---
- Skill file: `workspace/skills/daily-kickoff.md`
- Tools: `khal` (calendar), web search client (Tavily or similar)
- Vault layout: `00-inbox/`, `01-daily/briefs/`, `02-meetings/`, `05-knowledge/concepts/`

Gotchas & notes
---
- Date inference: always use a shell date (TZ) as authoritative to avoid wrong filenames
- Monday lookback: on Mondays also consider Friday’s file (3 days ago) to avoid empty Sunday reads
- Deduplicate intelligence items against `05-knowledge/concepts/` and yesterday’s brief

Example output
---
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DAILY KICKOFF — MONDAY, 23 MARCH 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INTELLIGENCE — LAST 24 HOURS
3 searched · 2 passed filter → [Paper title] ...

OPEN LOOPS FROM YESTERDAY
- [#task] Item added to Todoist
- [#idea] Something worth exploring

---
## My Notes
> Capture tasks, ideas and thoughts below this line throughout the day.
