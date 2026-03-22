# Daily Kickoff

## What it does

Runs every weekday morning and delivers a structured daily brief to Discord. Reads the vault, processes yesterday's notes, pulls calendar events, runs targeted web searches for the last 24 hours, and writes a formatted brief to the vault. The brief ends with an empty `## 📝 My Notes` section where you write throughout the day — replacing the need for a separate daily note file.

## Cron command

```bash
openclaw cron add \
  --name "daily-kickoff" \
  --cron "0 7 * * 1-5" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Read and follow the skill at workspace/skills/daily-kickoff.md exactly. Run all steps in order." \
  --announce \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

## Full prompt

Store the full prompt in `workspace/skills/daily-kickoff.md` and reference it from the cron message above. See [daily-kickoff.md](../../skills/daily-kickoff.md) for the complete skill.

The skill covers:
1. Verify date via shell command
2. Read vault context (projects, contacts, inbox)
3. Process yesterday's `## 📝 My Notes` section — route #task, #idea, #parking, #decision tags
4. Pull calendar via khal for today
5. Auto-create meeting note stubs
6. Run web searches across interest areas
7. Write the brief to vault
8. Append `## 📝 My Notes` footer

## Model recommendation

**`openrouter/anthropic/claude-sonnet-4-5`** — this job does everything: reads multiple vault files, runs web searches, writes structured output, and needs to make judgment calls about what's worth surfacing. Don't cheap out here. A worse model produces a noticeably worse brief.

## Timing rationale

**7am weekdays only.** Early enough to read before the day starts. Weekdays only — no point running Saturday/Sunday unless you work those days.

If you have other jobs running around 7am, stagger by 5-10 minutes. The brief takes 2-3 minutes to complete.

## Dependencies

**Skills:**
- `workspace/skills/daily-kickoff.md` — the full skill file

**Tools:**
- `khal` — calendar integration (must be configured with vdirsyncer)
- Web search — Tavily or native Claude web search

**Vault structure:**
- `00-inbox/` — items to surface
- `01-daily/briefs/` — output location
- `02-meetings/` — meeting notes
- `03-contacts/` — contact pages with health flags
- `04-projects/` — project overviews
- `05-knowledge/concepts/` — concept stubs (for deduplication)

**Other jobs:**
- Works best alongside `todoist-sync` — open loops from the brief feed into Todoist

## Gotchas

**Date inference is wrong without a shell command.** The model will guess the date from context and get it wrong, especially early in the morning or after the weekend. Always include `TZ="Europe/London" date "+%A %d %B %Y"` as Step 0 and use the shell output as the authoritative date for all filenames.

**Monday needs a Friday lookback.** Yesterday's notes on Monday morning points to Sunday — which is blank. Add an explicit check for Friday's file when today is Monday.

**khal returns all calendars by default.** Filter to Personal and Family only, otherwise work calendars from shared invites pollute the personal brief.

**Intelligence items repeat without deduplication.** Add an explicit check against `05-knowledge/concepts/` and yesterday's brief before including any research item.

## Example output structure

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌅 DAILY KICKOFF — MONDAY, 23 MARCH 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 INTELLIGENCE — LAST 24 HOURS
3 searched · 2 passed filter
→ [Paper title] ...

OPEN LOOPS FROM YESTERDAY
→ [#task] Item added to Todoist
→ [💡 Idea] Something worth exploring

[... full brief sections ...]

---
## 📝 My Notes

> Capture tasks, ideas, and thoughts below this line throughout the day.
```
