# Meeting Stub Creator

## What it does

Runs every weekday morning before your working day starts, reads today's calendar via `khal`, and auto-creates meeting note stubs for each event. Each stub is pre-populated with attendees (matched against your contacts folder), context from relevant project notes, and an empty structure ready for you to fill during the meeting.

Eliminates the friction of creating meeting notes manually and ensures you never go into a meeting without a note file ready.

## Cron command

```bash
openclaw cron add \
  --name "meeting-stub-creator" \
  --cron "30 6 * * 1-5" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_PREFERRED_MODEL" \
  --message "Read and follow the skill at workspace/skills/meeting-stub-creator.md exactly." \
  --no-deliver
```

## Full prompt

```
You are creating meeting note stubs for today's calendar events.

## 1. GET TODAY'S MEETINGS
Run exactly:
khal list today --format "{start-time} {end-time} {title} [{calendar}]"

## 2. FOR EACH MEETING FOUND
Create a stub at: [YOUR_VAULT]/02-meetings/$(date +%Y-%m-%d)-[title-slug].md

Rules:
- Skip if the file already exists
- Skip all-day events and personal/family calendar events
- Only create stubs for work/professional meetings

## 3. STUB CONTENT
Use this template:

---
date: [YYYY-MM-DD]
type: meeting
attendees: []
project_links: []
---

# Meeting: [title]
**Date:** [YYYY-MM-DD]  
**Time:** [start-time] – [end-time]
**Attendees:**
[Match names from title against [YOUR_VAULT]/03-contacts/
Include as wikilinks: [[👤 Name]] if contact page exists
Otherwise: Plain Name]

## Context
[Add 1-2 sentences of context from relevant project notes if applicable]

## Notes

## Decisions made
-

## Actions
- [ ] #task 

## Open questions
-

---

## 4. CONFIRM
Output: "Created [N] meeting stub(s): [meeting names]"
or: "No new stubs needed today"
Do not deliver to any channel.
```

## Model recommendation

**Mid-tier model.** This job reads the calendar, matches names against contacts, and creates structured markdown. Needs enough capability to do fuzzy name matching and write clean frontmatter. A very cheap model gets the contact matching wrong.

## Timing rationale

**6:30am weekdays** — 30 minutes before the daily kickoff (7am). The kickoff then reads the meeting stubs it finds and includes them in the brief. This ordering is intentional — stubs first, then briefing.

## Dependencies

**Required:**
- `khal` configured and synced with your calendar (via vdirsyncer)
- Calendar populated with today's events

**Vault structure:**
- `02-meetings/` — output location for stubs
- `03-contacts/` — contact pages for attendee matching
- `04-projects/` — for context snippets in stub headers
- `00-inbox/TEMPLATE-meeting-note.md` — base template (optional but recommended)

## Gotchas

**khal must be synced before this runs.** If vdirsyncer hasn't synced recently, khal returns stale calendar data. Either run vdirsyncer sync in the prompt before calling khal, or add a vdirsyncer sync to your nightly backup.

**Calendar filter is essential.** `khal list today` returns all calendars — personal, family, work, shared. Without filtering, you create stubs for your kids' school events and dentist appointments. Filter to work calendars only, or explicitly exclude Personal/Family calendars.

**Title slugs need cleaning.** Meeting titles often contain special characters, slashes, and colons that break filenames. Clean the slug: lowercase, spaces to hyphens, remove special characters. Explicitly instruct this in the prompt.

**Don't overwrite existing stubs.** The "skip if exists" rule is critical. If you run this job manually or the previous day's stubs survived, you don't want them overwritten. Always check for existing files first.

**Attendee matching is fuzzy and imperfect.** "1:1 with Charlie" might not match `03-contacts/charlie-smith.md` if the contact file uses the full name. Keep your contact filenames consistent and include common name variants in the contact frontmatter.
