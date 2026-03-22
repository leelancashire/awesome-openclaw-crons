✨ awesome-openclaw-crons

A curated collection of production-tested OpenClaw cron job prompts, organised by use case. Copy-paste ready. Battle-tested.

Most OpenClaw cron examples show you "Summarize my inbox" and call it a day. This repo is different: every prompt here has been run in production. The timing rationale is documented, the model choices explained, and the gotchas recorded — the small details that make a job reliable in production.

What’s included

Each job contains:
- ✅ Full openclaw cron add command (copy-paste ready)
- 🧩 Complete prompt text
- 🤖 Model recommendation and reasoning
- ⏰ Timing rationale (why this schedule, what to avoid)
- ⚠️ Known gotchas discovered in production
- 🔗 Dependencies (skills, vault structure, other jobs)

Categories

📈 Productivity — daily intelligence, task management, and personal organisation

Job schedule (examples)
- ✨ Daily Kickoff — Weekdays 07:00 — Morning brief with calendar, open loops, intel
- 🔁 Weekly Review — Friday 16:00 — Structured reflection and next-week setup
- 🔄 Todoist Sync — Every 30 min — Sync daily-note tasks to Todoist
- 🧠 Memory Consolidation — 23:45 daily — Distil session learnings to MEMORY.md
- 💾 Nightly Backup — 23:10 daily — Git backup of vault + config

🔬 Research — literature scanning, paper ingestion, and knowledge synthesis

Job schedule (examples)
- 🌙 Nightly Research Scan — 01:15 daily — Trawl interest areas → inbox
- ✉️ Email Research Digest — 4x daily — Parse journal alerts from AgentMail inbox
- 🗂 Monthly Vault Synthesis — 1st of month — cross-vault themes & contradictions

✍️ Writing & Content — newsletter drafts, LinkedIn, and content pipelines

Job schedule (examples)
- 🧩 Weekly Content Pipeline — Fri 22:00 — multi-agent synthesis → newsletter + socials
- 📰 Newsletter Draft — Sat 08:00 — standalone newsletter draft example

🛡 Monitoring & Health — system health, security, and maintenance

Job schedule (examples)
- 🔐 Weekly Security Review — Mon 09:00 — audit logs & anomaly checks
- ⚙️ Context Health Check — every 6h — auto-compact sessions near token limits

📅 Calendar & Meetings — calendar integration and meeting prep automation

Job schedule (examples)
- 📝 Meeting Stub Creator — weekdays 06:30 — create meeting notes from today’s calendar
- 🏛 Weekly Councils — Sun 19:00 — project health synthesis across active work

Quick start

1. Clone the repo:

```bash
git clone https://github.com/YOUR_USERNAME/awesome-openclaw-crons
```

2. Browse a category, e.g.:

```bash
cat categories/productivity/daily-kickoff.md
```

3. Copy a cron add command and paste into your terminal (replace placeholders).

All jobs use isolated sessions by default. See PATTERNS.md for reasoning.

Design principles

1. Prompts over commands — the repo demonstrates what to put in --message, not just the cron syntax.
2. Timing matters — avoid API quota collisions by staggering jobs.
3. Model tiering — match model capability to job need to control cost.
4. Production, not demos — examples here are battle-tested; gotchas are documented.

File format

Every job follows a concise template; see templates/JOB_TEMPLATE.md for the required sections and ordering.

Contributing

PRs welcome — see CONTRIBUTING.md for the bar: production-run jobs with concrete gotchas and model rationale.

Related resources
- openclaw/openclaw — Core framework
- VoltAgent/awesome-openclaw-skills — Skill library
- vincentkoc/awesome-openclaw — General ecosystem
- OpenClaw cron docs — Official reference

Author

Maintained by Lee Lancashire. Examples are community-focused and generic.