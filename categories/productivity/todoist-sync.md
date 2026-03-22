# Todoist Sync

## What it does

Runs every 30 minutes and syncs tasks between your vault and Todoist. Reads your daily note for items tagged `#task`, checks whether they already exist in Todoist, and adds any that are missing. Keeps your task manager current without manual entry.

## Cron command

```bash
openclaw cron add \
  --name "todoist-sync" \
  --cron "*/30 * * * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_CHEAPEST_MODEL" \
  --message "Read and follow the skill at workspace/skills/todoist-sync.md exactly." \
  --no-deliver
```

## Full prompt

```
You are running a Todoist sync. Work through each step silently.

## 1. READ TODAY'S DAILY NOTE
Read [YOUR_VAULT]/01-daily/briefs/$(date +%Y-%m-%d)-kickoff.md

Look for any line in the ## 📝 My Notes section tagged #task that is
not already marked complete (not prefixed with ✅ or [x]).

Also read today's meeting notes in [YOUR_VAULT]/02-meetings/ for any
action items tagged #task.

## 2. CHECK TODOIST
For each #task item found, check whether a matching task already
exists in Todoist (fuzzy match on title — don't duplicate).

## 3. ADD MISSING TASKS
For each item not already in Todoist:
- Create the task with the text from the note (minus the #task tag)
- Set due date to today if no date is specified
- Add label matching any #project tag if present (e.g. #matrix → matrix label)

## 4. REPORT
If tasks were added, output: "SYNC_OK — added [N] task(s): [task names]"
If nothing to add: "SYNC_OK — nothing new"
If an error occurred: "SYNC_ERROR — [error detail]"

Do not deliver this output to any channel unless there is an error.
```

## Model recommendation

**Cheapest viable model.** This is the most frequent job in the system (every 30 minutes) and the most deterministic. It reads a file, checks an API, writes a task. No reasoning required. Running an expensive model here is the fastest way to blow your monthly budget.

## Timing rationale

**Every 30 minutes** — frequent enough that tasks captured mid-day appear in Todoist within the hour. Less frequent (hourly) means tasks sit in limbo too long. More frequent wastes API quota and rarely finds new items.

Silent delivery (`--no-deliver`) — this job runs 48 times a day. You don't want 48 Discord messages. Errors surface because the SYNC_ERROR output triggers delivery when something goes wrong.

## Dependencies

**Required:**
- Todoist MCP server or skill configured
- Todoist API key in secrets

**Vault structure:**
- `01-daily/briefs/` — reads today's brief for #task items
- `02-meetings/` — reads today's meeting notes for action items

**Conventions required:**
- Tasks in daily notes tagged with `#task`
- Optional project tags like `#matrix`, `#gnns` to auto-label in Todoist

## Gotchas

**Fuzzy matching prevents duplicates but isn't perfect.** If you write "Email Pascal" one day and "Email Pascal re MR pipeline" the next, the matcher may create a duplicate. Add the `--no-duplicate` instruction explicitly and include a similarity threshold.

**Silent failures are hard to diagnose.** Because the job runs silently, errors can go unnoticed for hours. The SYNC_ERROR output pattern is essential — make sure your delivery config surfaces errors even when normal output is suppressed.

**Meeting note tasks need a date.** Tasks extracted from meeting notes often have no natural due date. Set a default (today, or tomorrow for anything captured in an afternoon meeting) to avoid tasks with no due date piling up in Todoist.

**SYNC_OK confirmation is useful for monitoring.** Even though you don't deliver normal output, the `SYNC_OK` log in the cron run history lets you verify the job is running. Check `openclaw cron runs --id <jobId> --limit 5` periodically.
