# Weekly Review

## What it does

Fires every Friday afternoon and delivers a structured weekly reflection to Telegram. Reads the week's briefs, completed tasks, meeting notes, and calendar, then asks a series of reflection questions to close the week properly. Ends with three intentions for next week, written to the vault.

The difference between this and the weekly councils job: councils synthesise project status for planning. This job is personal  -  it asks you the right questions rather than generating a report.

## Cron command

```bash
openclaw cron add \
  --name "weekly-review" \
  --cron "0 16 * * 5" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Read and follow the skill at workspace/skills/weekly-review.md exactly. Run all steps in order." \
  --announce \
  --channel telegram \
  --to "YOUR_TELEGRAM_CHAT_ID"
```

## Full prompt

```
You are running Lee's weekly review for the week ending $(date +%Y-%m-%d).
Work through each section fully. Deliver to Telegram, not Discord  - 
this is personal, not operational.

## 1. WEEK IN REVIEW
Read all daily briefs from this week:
[YOUR_VAULT]/01-daily/briefs/

Summarise: what got done, what didn't, what surprised you.
Keep this factual and brief  -  3-5 bullet points.

## 2. PROJECTS
Read [YOUR_VAULT]/04-projects/  -  all *-OVERVIEW.md files
For each active project: what moved this week? What is blocked or stalled?
Flag anything with no movement in 2+ weeks with 🔴

## 3. RESEARCH
Read this week's research candidates from [YOUR_VAULT]/00-inbox/
How many #deep-dive items remain unactioned?
Any themes emerging across multiple candidates?

## 4. MEETINGS AND PEOPLE
Read this week's meeting notes from [YOUR_VAULT]/02-meetings/
Any follow-ups or commitments made that aren't in Todoist yet?
Run: khal list today 7d --format "{start-date} {start-time} {title}"
Flag anything next week needing prep.

## 5. REFLECTION QUESTIONS
Answer each honestly based on the week's evidence:
- What was the highest value thing I did this week?
- What did I avoid or procrastinate on?
- What would I do differently?
- What is the single most important thing for next week?

## 6. NEXT WEEK SETUP
Based on the above, write 3 clear intentions for next week.
Write them to: [YOUR_VAULT]/01-daily/weekly-intentions/$(date +%Y-%m-%d)-intentions.md

End with a brief encouraging closing note.
Under 3 minutes of reading total.
```

## Model recommendation

**`openrouter/anthropic/claude-sonnet-4-5`**  -  this job reads multiple files, synthesises across them, answers qualitative questions honestly, and writes in a personal tone. Cheaper models produce generic, formulaic responses. The weekly review is one of the highest-value jobs in the system  -  don't cheap out.

## Timing rationale

**Friday 4pm**  -  end of the working day, before the weekend. Early enough that you can act on anything surfaced (a follow-up to send, a task to capture). Late enough that the full week is visible. Delivers to Telegram not Discord so it comes to your phone.

## Dependencies

**Vault structure:**
- `01-daily/briefs/`  -  this week's daily briefs
- `01-daily/weekly-intentions/`  -  output location (create this folder first)
- `02-meetings/`  -  this week's meeting notes
- `04-projects/`  -  project overview files
- `00-inbox/research-candidates-*.md`  -  this week's research candidates

**Tools:**
- `khal`  -  for next week's calendar preview

## Gotchas

**Deliver to Telegram, not Discord.** This is a personal reflection, not a team broadcast. Discord is for operational output. The weekly review coming to your phone on Friday afternoon feels right  -  it's for you.

**The closing note matters.** Friday afternoon deserves a human touch. A factual report followed by "End of weekly review" misses the point. The closing note is what makes people actually look forward to this firing.

**Don't combine with weekly councils.** Councils are project-focused operational synthesis. This is personal reflection. Running them as the same job conflates two different purposes. Keep them separate  -  councils Sunday evening, review Friday afternoon.

**The intentions file is valuable over time.** After a few months, reading back through `weekly-intentions/` shows patterns  -  recurring blockers, repeated aspirations, goals that keep surfacing. Feed this into your monthly vault synthesis.
