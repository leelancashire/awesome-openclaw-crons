# Nightly Research Scan

## What it does

Runs 7 targeted Tavily searches across your research interest areas every night and writes qualifying items to a dated research candidates file in your inbox. Each entry includes a full summary paragraph and a "why it matters" paragraph connecting the paper to your active projects. The daily kickoff reads this file the next morning and surfaces any `#deep-dive` items.

Forms one of three orthogonal research feeds alongside AgentMail journal alerts and daily kickoff reactive searches.

## Cron command

```bash
openclaw cron add \
  --name "nightly-research-scan" \
  --cron "15 1 * * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_PREFERRED_MODEL" \
  --message "Read and follow the skill at workspace/skills/nightly-research-scan.md exactly." \
  --announce \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

## Full prompt

0. Quota check
Run the quota-check skill at workspace/skills/quota-check.md before any heavy work. Example wrapper:

```bash
JOB_NAME=nightly-research-scan bash -c 'workspace/skills/quota-check.md && echo ok'
```



```
You are running a nightly research scan. Your job is to find genuinely novel
and relevant developments published in the last 24-48 hours.

Run the following searches in sequence using Tavily web search:
1. [YOUR TOPIC 1] [current year]
2. [YOUR TOPIC 2] new methods
3. [YOUR TOPIC 3] preprint
4. [YOUR TOPIC 4] benchmark
5. [YOUR TOPIC 5] foundation model
6. [YOUR TOPIC 6] evaluation
7. [YOUR TOPIC 7] dataset

For each search, review the top results and select up to 3 that are genuinely
novel and relevant. Exclude:
- Press releases and product announcements
- Generic AI hype without substance
- Anything already captured in [YOUR_VAULT]/05-knowledge/concepts/

For each qualifying item write to:
[YOUR_VAULT]/00-inbox/research-candidates-$(date +%Y-%m-%d).md

Use this exact format:

---

**[Title]**

Source: [journal/preprint server] | [clean URL  -  omit if tracking link]

[4-6 sentence summary of what the paper does, how, and what it found]

**Why it matters:** [1-2 sentences connecting to your active projects
and research questions by name]

Tags: [#tag1 #tag2 #tag3]

Triage: #deep-dive | #skim | #monitor

---

After writing the file, post a brief completion summary to Discord:
"🔬 Nightly scan complete: [N] searches · [N] candidates
[N] flagged #deep-dive · File: 00-inbox/research-candidates-[date].md"
If nothing qualified, post: "🔬 Nightly scan: nothing new tonight."
```

## Model recommendation

A mid-tier model works well here. The job is structured and the output format is deterministic  -  you don't need Sonnet-level reasoning for a research scan. Use your cheapest model that can run Tavily searches reliably.

If using Claude with native web search rather than Tavily, use `openrouter/anthropic/claude-sonnet-4-5` since web search quality matters more than synthesis quality here.

## Timing rationale

**1:15am**  -  three reasons:
1. Clear of the nightly backup (typically 11:10pm)
2. Clear of memory consolidation (typically 11:45pm)  
3. File is ready before the 7am daily kickoff reads it

Don't run this at midnight  -  too many jobs compete for API quota at round numbers.

## Dependencies

**Tools:**
- Tavily plugin (`openclaw-tavily`) OR native Claude web search
- Both require API keys configured in secrets

**Vault structure:**
- `00-inbox/`  -  output location for research candidates files
- `05-knowledge/concepts/`  -  checked for deduplication

**Other jobs:**
- Daily kickoff reads `00-inbox/research-candidates-*.md` and surfaces `#deep-dive` items

## Gotchas

**Deduplication is essential.** Without explicitly checking `05-knowledge/concepts/`, the same papers resurface every night. The model has no memory between runs  -  it doesn't know what it found yesterday.

**Tracking URLs in emails.** If you feed journal alerts into this workflow, URLs often contain tracking parameters (long random strings, `bid=`, `cid=` parameters). Instruct the model to omit the URL rather than include a 400-character tracking link.

**Output format breaks in Obsidian.** Blank lines between fields are mandatory for Obsidian to render correctly. If fields run together, add explicit newline instructions to the prompt.

**7 searches is about the right number.** Fewer means gaps in coverage. More means API quota issues and diminishing returns  -  results from search 8-12 tend to repeat search 1-4.

**Query rotation reduces repetition.** The same query every night returns the same papers. Rotate query angles across days (methods Monday, benchmarks Tuesday, applications Wednesday etc.) or use date filtering: `published_after:yesterday`.
