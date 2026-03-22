# awesome-openclaw-crons 🦞⏰

> A curated collection of production-tested OpenClaw cron job prompts, organised by use case. Copy-paste ready. Battle-tested.

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
![Jobs](https://img.shields.io/badge/cron_jobs-30+-blue?style=flat-square)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)

Most OpenClaw cron examples show you `"Summarize my inbox"` and call it a day.

This repo is different. Every prompt here has been run in production. The timing rationale is documented. The model choices are explained. The gotchas are included  -  because the difference between a cron job that works once and one that runs reliably every day is usually in the details nobody writes down.

---

## What's included

Each job contains:
- ✅ Full `openclaw cron add` command, copy-paste ready
- 📝 Complete prompt text
- ⚙️ Model recommendation and why
- 🕐 Timing rationale (why this schedule, what to avoid)
- ⚠️ Known gotchas from running it in production
- 🔗 Dependencies (other jobs, skills, or vault structure needed)

---

## Categories

### 🌅 Productivity
Daily intelligence, task management, and personal organisation.

| Job | Schedule | What it does |
|-----|----------|-------------|
| [Daily Kickoff](categories/productivity/daily-kickoff.md) | Weekdays 7am | Morning brief with calendar, open loops, intel |
| [Weekly Review](categories/productivity/weekly-review.md) | Friday 4pm | Structured reflection and next week setup |
| [Todoist Sync](categories/productivity/todoist-sync.md) | Every 30 min | Sync daily note tasks to Todoist |
| [Memory Consolidation](categories/productivity/memory-consolidation.md) | 11:45pm daily | Distil session learnings to MEMORY.md |
| [Nightly Backup](categories/productivity/nightly-backup.md) | 11:10pm daily | Git backup of vault and config |

### 🔬 Research
Literature scanning, paper ingestion, and knowledge synthesis.

| Job | Schedule | What it does |
|-----|----------|-------------|
| [Nightly Research Scan](categories/research/nightly-research-scan.md) | 1:15am daily | Tavily scan across interest areas → inbox |
| [Email Research Digest](categories/research/email-research-digest.md) | 4x daily | Parse journal alerts from AgentMail inbox |
| [Monthly Vault Synthesis](categories/research/monthly-vault-synthesis.md) | 1st of month | Cross-vault connections, themes, contradictions |

### ✍️ Writing & Content
Newsletter drafts, LinkedIn posts, and content pipelines.

| Job | Schedule | What it does |
|-----|----------|-------------|
| [Weekly Content Pipeline](categories/writing/weekly-content-pipeline.md) | Friday 10pm | Multi-agent: synthesis → newsletter + LinkedIn + research report |
| [Newsletter Draft](categories/writing/newsletter-draft.md) | Saturday 8am | Standalone Rare Signal draft (single-agent version) |

### 🏥 Monitoring & Health
System health, security, and agent maintenance.

| Job | Schedule | What it does |
|-----|----------|-------------|
| [Weekly Security Review](categories/monitoring/weekly-security-review.md) | Monday 9am | Audit logs, flag anomalies vs baseline |
| [Context Health Check](categories/monitoring/context-health-check.md) | Every 6h | Auto-compact sessions near context limit |

### 🗓️ Calendar & Meetings
Calendar integration and meeting prep automation.

| Job | Schedule | What it does |
|-----|----------|-------------|
| [Meeting Stub Creator](categories/calendar/meeting-stub-creator.md) | Weekdays 6:30am | Auto-create meeting notes from today's calendar |
| [Weekly Councils](categories/calendar/weekly-councils.md) | Sunday 7pm | Project health synthesis across active work |

---

## Quick start

```bash
# Clone the repo
git clone https://github.com/leelancashire/awesome-openclaw-crons

# Browse a category
cat categories/productivity/daily-kickoff.md

# Copy the cron add command and paste into your terminal
```

All jobs use isolated sessions by default. See [PATTERNS.md](PATTERNS.md) for the reasoning.

---

## Design principles

**1. Prompts over commands**
The `openclaw cron add` syntax is in the docs. What isn't documented is what to put in `--message`. That's what this repo is for.

**2. Timing matters**
Jobs that compete for the same API quota at the same time fail silently. Every job here documents why it runs when it does and what it avoids.

**3. Model choice is intentional**
Not every job needs your best model. Research scans and summaries run cheap. Deep synthesis runs Sonnet. This is documented per job.

**4. Production, not demos**
These prompts have run for weeks. Edge cases are noted. Things that broke are recorded.

---

## File format

Every job follows this template:

```markdown
# Job Name

## What it does
One paragraph. What problem does this solve?

## Cron command
\```bash
openclaw cron add \
  --name "job-name" \
  --cron "0 7 * * 1-5" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "..." \
  --announce \
  --channel discord \
  --to "channel:YOUR_CHANNEL_ID"
\```

## Full prompt
\```
[Complete prompt text]
\```

## Model recommendation
Which model and why. Cost vs capability tradeoff.

## Timing rationale
Why this schedule. What to avoid scheduling around.

## Dependencies
- Skills required
- Vault structure assumed
- Other jobs this depends on

## Gotchas
What broke in production and how to avoid it.

## Example output
What a successful run looks like (optional).
```

---

## Patterns and anti-patterns

See [PATTERNS.md](PATTERNS.md) for:
- Isolated vs main session  -  when to use each
- How to avoid API quota collisions across jobs
- Memory flush before compaction
- Discord vs Telegram delivery
- Model tiering by job type
- Multi-agent chaining with `sessions_spawn`

---

## Contributing

Found a cron job that works well? PRs welcome.

Requirements:
- Must have run in production for at least 1 week
- Must include timing rationale and model recommendation
- Must include at least one gotcha (if it never broke, it hasn't run long enough)
- Follow the file format above

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## Related resources

- [openclaw/openclaw](https://github.com/openclaw/openclaw)  -  Core framework
- [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills)  -  Skill library
- [vincentkoc/awesome-openclaw](https://github.com/vincentkoc/awesome-openclaw)  -  General ecosystem
- [OpenClaw cron docs](https://docs.openclaw.ai/automation/cron-jobs)  -  Official reference

---

## Author

Maintained by Lee Lancashire  -  https://www.linkedin.com/in/llancashire/

I am testing these cron jobs as a way to run my personal research OS. I thought I would share them since I spent a couple of weeks figuring out what works and it might be helpful to share with the community rather than them start from scratch.


---

*If this helped you, star the repo. If you have a job that works well, open a PR.*
