# Weekly Security Review

## What it does

Runs every Monday morning and reviews the last 7 days of audit logs, comparing activity against a known baseline of normal behaviour. Flags anything unusual — unexpected file access, API calls from unexpected sources, cron jobs that ran at wrong times, unusual action volumes. Writes a brief report to the vault and alerts immediately on anything suspicious.

Security through visibility: you can't spot anomalies without a baseline, and you can't build a baseline without regular review.

## Cron command

```bash
openclaw cron add \
  --name "weekly-security-review" \
  --cron "0 9 * * 1" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Read and follow the skill at workspace/skills/weekly-security-review.md exactly." \
  --announce \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

## Full prompt

```
You are running the weekly security review for the 7 days ending $(date +%Y-%m-%d).

## 1. READ AUDIT LOGS
Read: /var/log/openclaw/audit.jsonl
Filter to entries from the last 7 days.

If audit logging is not configured, output:
"⚠️ SECURITY: Audit logging not configured — cannot review.
See PATTERNS.md for setup instructions."
Then stop.

## 2. ESTABLISH BASELINE
Known normal activity for this system:
- Cron jobs: todoist-sync (every 30min), daily-kickoff (weekdays 7am),
  weekly-councils (Sunday 7pm), nightly-backup (23:10),
  nightly-research-scan (1:15am), email-research-digest (4x daily),
  memory-consolidation (23:45), weekly-review (Friday 4pm)
- Normal vault reads and writes throughout working hours
- AgentMail polling (4x daily)
- Tavily searches during research scan and daily kickoff
- khal calendar reads during kickoff and meeting-stub-creator

## 3. FLAG ANOMALIES
Look for:
- Commands or file access outside normal patterns
- API calls from unexpected sources or at unexpected times
- Failed actions or permission errors (more than occasional)
- Any cron job that ran unexpectedly or at wrong times
- Unusual volumes of any action type
- File deletions outside of normal operations
- Access to sensitive paths: ~/.openclaw/credentials/, secrets files

## 4. WRITE REPORT
Write to: [YOUR_VAULT]/10-personal/security/$(date +%Y-%m-%d)-security-review.md

Report format:
---
# Security Review — [date]
Period: [start] to [end]
Status: NORMAL | REVIEW NEEDED | ALERT

## Activity summary
[N] total actions reviewed
[N] cron job runs
[N] API calls

## Flagged items
[List any anomalies with timestamp, action, and why it's flagged]
[If nothing: "Nothing unusual detected."]

## Baseline drift
[Any gradual changes in activity patterns worth noting]
---

## 5. ANNOUNCE
Post to Discord:
If NORMAL: "✅ Weekly security review complete — nothing unusual"
If REVIEW NEEDED: "🔍 Security review: [N] items need attention —
[one-line summary]. Full report: 10-personal/security/[date].md"
If ALERT: "🚨 SECURITY ALERT: [what was found] —
Review immediately: 10-personal/security/[date].md"
```

## Model recommendation

**`openrouter/anthropic/claude-sonnet-4-5`** — reading audit logs requires genuine pattern recognition and judgment. A cheap model either flags everything (useless noise) or flags nothing (false security). This is one job where quality of analysis matters significantly.

## Timing rationale

**Monday 9am** — reviews the full previous week including weekend. Early enough Monday to act on anything found before the week progresses. Weekly cadence is sufficient for a personal system — daily review would be noise.

## Dependencies

**Required for full functionality:**
- Structured JSON audit logging enabled in `openclaw.json`:
```json
"logging": {
  "level": "INFO",
  "format": "json",
  "destinations": [
    { "file": "/var/log/openclaw/agent.log" }
  ]
}
```
- Audit log at `/var/log/openclaw/audit.jsonl`

**Vault structure:**
- `10-personal/security/` — report output location (create this folder)

## Gotchas

**The job is only as useful as your audit logging.** Without structured logging configured, this job has nothing to review. Set up logging first — see the logging configuration in `PATTERNS.md`.

**Build baseline knowledge before expecting useful alerts.** The first few reviews will be noise as you learn what's normal. After 4-6 weeks you'll have a mental model of baseline activity and anomalies will be obvious.

**False positives are better than false negatives.** Configure the baseline conservatively — flag anything uncertain rather than suppressing it. You can always decide a flagged item is fine. You can't un-miss a real anomaly.

**Offsite log storage matters.** Logs stored only on the same machine as the agent can be deleted by a compromised agent. Copy audit logs to your backup repo nightly (add to `refresh.sh`) so an attacker can't cover their tracks.

**Also run OpenClaw's built-in audit:**
```bash
openclaw security audit --deep --json
```
This catches configuration issues (world-readable files, exposed ports) that the log review won't surface.
