# Email Research Digest

## What it does

Polls an AgentMail inbox every few hours, processes journal alert emails and newsletter digests, extracts qualifying papers, and appends them to the same research candidates file as the nightly Tavily scan. Same triage format, third orthogonal research source.

The pattern: forward all journal alerts (PubMed, bioRxiv, Nature, Science, Cell, etc.) to a dedicated AgentMail address. The agent parses them so you don't have to. Turns a guilt pile of unread alerts into an automatic research feed.

## Cron command

```bash
openclaw cron add \
  --name "email-research-digest" \
  --cron "0 8,12,17,21 * * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_PREFERRED_MODEL" \
  --message "Read and follow the skill at workspace/skills/email-research-digest.md exactly." \
  --announce \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

## Full prompt

```
You are processing research email alerts from an AgentMail inbox.

## 1. FETCH UNREAD EMAILS
Use the agentmail skill to fetch all unread messages.
If there are no unread messages, stop here silently.

## 2. FOR EACH EMAIL
Evaluate whether it contains substantive research content:
- Journal table of contents alerts
- PubMed / bioRxiv / medRxiv digests
- Nature / Science / Cell newsletters
- Preprint notifications
- Conference announcements with papers

Skip: newsletters with no papers, marketing, event invites,
duplicates of papers already in [YOUR_VAULT]/05-knowledge/concepts/

## 3. FOR QUALIFYING PAPERS
Extract each individual paper and append to:
[YOUR_VAULT]/00-inbox/research-candidates-$(date +%Y-%m-%d).md

Use exactly this format (same as nightly Tavily scan):

---

**[Title]**

Source: [journal/preprint server] | [clean URL  -  omit if tracking link]

[4-6 sentence summary]

**Why it matters:** [1-2 sentences connecting to active projects]

Tags: [#tag1 #tag2 #tag3]

Triage: #deep-dive | #skim | #monitor

---

## 4. MARK AS READ
After processing, mark all fetched emails as read via agentmail skill.

## 5. SUMMARY
If qualifying papers were found, post to Discord:
"📬 Email digest: [N] papers from [source names]. Added to research candidates."
If nothing found, stay silent.
```

## Model recommendation

Cheap model is fine. Email parsing is structured extraction, not reasoning. The main job is: read email, identify papers, extract title/abstract/URL, write formatted output. Any model that can follow structured instructions works.

## Timing rationale

**4x daily: 8am, 12pm, 5pm, 9pm**  -  journals send alerts at various times. Running 4x catches morning alerts before the day starts, lunchtime digests, end-of-day newsletters, and evening bioRxiv drops. Running more frequently adds API cost without meaningfully improving coverage.

Runs after the daily kickoff (7am) so the kickoff always reads the previous day's email digest, not the current morning's.

## Dependencies

**Required:**
- AgentMail account at console.agentmail.to
- AgentMail MCP server configured in openclaw
- AgentMail API key in secrets
- Gmail (or other email) filters forwarding journal alerts to your AgentMail address

**Vault structure:**
- `00-inbox/`  -  output location, appends to same file as nightly scan
- `05-knowledge/concepts/`  -  checked for deduplication

**Other jobs:**
- Complements `nightly-research-scan`  -  both write to the same candidates file
- Daily kickoff reads the combined output

## Gotchas

**Set up Gmail filters first.** The job is useless without forwarding rules. Create filters for: journal alert keywords, PubMed sender addresses, bioRxiv digest subjects, Nature/Science newsletter senders. Forward to your AgentMail address. Test the filters before enabling the cron.

**Tracking URLs everywhere in email.** Journal alert emails almost always use tracking redirects. The URL in the email is never the paper URL. Add explicit instruction to omit tracking URLs rather than include them. Clean DOI links only, or no URL.

**Mark as read is essential.** Without this, every run reprocesses the same emails. The job grows unbounded. Always include the mark-as-read step after processing.

**Appending, not overwriting.** This job appends to the daily candidates file, which the nightly scan may have already created. Verify your prompt uses append mode, not write mode.

**Volume management.** High-volume journal subscriptions can generate 20-50 papers per day. Add a relevance filter against your interest profile to avoid flooding the candidates file with noise.
