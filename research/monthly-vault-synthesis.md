# Monthly Vault Synthesis

## What it does

Runs on the first of every month and performs a deep read across the entire vault  -  knowledge notes, meeting notes, daily captures, project overviews, council outputs  -  looking for non-obvious connections, recurring themes, contradictions between notes, and ideas that keep resurfacing without resolution.

Unlike the weekly councils (project status) or weekly review (personal reflection), this job is about finding what you haven't noticed. Cross-cutting patterns that only become visible with distance.

## Cron command

```bash
openclaw cron add \
  --name "monthly-vault-synthesis" \
  --cron "0 8 1 * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "openrouter/anthropic/claude-sonnet-4-5" \
  --message "Read and follow the skill at workspace/skills/monthly-vault-synthesis.md exactly. Run all steps in order." \
  --announce \
  --channel discord \
  --to "channel:YOUR_BRIEFING_CHANNEL_ID"
```

## Full prompt

```
You are running the monthly vault synthesis for $(date +%B %Y).
Read everything before concluding anything.
Your job is to find what hasn't been explicitly noticed yet  - 
not to summarise what's already obvious.

## 1. VERIFY DATE
Run: TZ="Europe/London" date "+%A %d %B %Y"

## 2. READ THE VAULT
Read broadly across all of:

Knowledge base:
- [YOUR_VAULT]/05-knowledge/concepts/  -  all files from the last 90 days
- [YOUR_VAULT]/05-knowledge/notes/  -  all freeform notes

Projects:
- [YOUR_VAULT]/04-projects/  -  all *-OVERVIEW.md files in full

Research inbox:
- [YOUR_VAULT]/00-inbox/research-candidates-*.md  -  last 30 days

Daily thinking:
- [YOUR_VAULT]/01-daily/briefs/  -  last 30 days,
  ONLY the ## 📝 My Notes sections
- [YOUR_VAULT]/07-councils/  -  last 3 council synthesis outputs

Previous insights:
- [YOUR_VAULT]/09-insights/  -  all previous synthesis notes
  Do NOT repeat insights already captured there.

Read everything before writing anything.

## 3. SYNTHESISE THROUGH FOUR LENSES

Lens 1: Cross-project connections
Where do separate projects touch the same problem from different angles?
Look for: shared methods, shared failure modes, places where progress
on one project would unlock another.
Only surface non-obvious connections  -  not ones already linked in the vault.

Lens 2: Recurring themes
What ideas, questions, or framings appear repeatedly across different
contexts without being explicitly resolved or developed?
A theme needs 3+ source touchpoints to qualify.
Look for: phrases that recur across unrelated notes, questions asked
repeatedly in different forms.

Lens 3: Contradictions
Where do different notes hold positions that tension or contradict?
Look for: different answers to the same question in different contexts,
recent findings that undermine older claims.
Assign severity: low | medium | high

Lens 4: Ideas resurfacing without resolution
What appears in daily notes, research candidates, and meeting notes
repeatedly without ever becoming a project or concept stub?
Look for: topics captured but never developed, questions appearing
in multiple daily notes without resolution.

## 4. WRITE SYNTHESIS NOTE
Write to: [YOUR_VAULT]/09-insights/$(date +%Y-%m-%d)-monthly-synthesis.md

---
type: vault-synthesis
date: [YYYY-MM-DD]
month: [Month YYYY]
vault_notes_read: [N]
previous_synthesis: [[last synthesis file]]
---

# Vault Synthesis  -  [Month YYYY]

## Summary
[3-4 sentences. What is the single most important thing this synthesis
surfaces? Lead with it.]

## Cross-project connections
[N connections found]

→ **[Connection title]**
  [2-3 sentences on the connection and why it matters]
  Links: [[project-a]] · [[project-b]]
  Suggested action: [one line]

## Recurring themes

→ **[Theme]**
  Appears in: [list of notes/contexts]
  [2 sentences on what the theme is]
  Unresolved because: [one line]
  Suggested action: [develop into concept / start project / park deliberately]

## Contradictions

→ **[Contradiction title]**
  Position A: [one line] · [[source]]
  Position B: [one line] · [[source]]
  Which holds on evidence: A | B | unclear
  Severity: low | medium | high

## Ideas resurfacing without resolution

→ **[Idea]**
  Appears in: [N notes across M weeks]
  [One sentence on what the idea is]
  Suggested action: [concept stub / project / park / decide to drop]

## Recommended actions
1. [Most important  -  max 5 total]

---

## 5. ANNOUNCE
Post to Discord:
"🧠 Monthly vault synthesis complete  -  [Month YYYY]
[N] connections · [N] themes · [N] contradictions · [N] resurfaces
Top finding: [one sentence]
Full note: 09-insights/[date]-monthly-synthesis.md"
```

## Model recommendation

**`openrouter/anthropic/claude-sonnet-4-5`**  -  this is the most cognitively demanding job in the system. It reads 50-100+ files, holds them all in working memory, and finds non-obvious patterns across them. Cheap models produce surface-level summaries that miss the point. Use your best available model here.

## Timing rationale

**1st of month, 8am**  -  beginning of the month is a natural review point. Morning delivery means you can read it with coffee and let the findings inform the month ahead.

First run will be thin  -  the vault is young and patterns haven't had time to accumulate. Gets significantly more valuable from month 3 onwards when there's enough material to find genuine non-obvious connections.

## Dependencies

**Vault structure:**
- `05-knowledge/concepts/`  -  concept stubs
- `05-knowledge/notes/`  -  freeform notes
- `04-projects/`  -  project overviews
- `00-inbox/`  -  research candidates
- `01-daily/briefs/`  -  daily briefs
- `07-councils/`  -  council synthesis outputs
- `09-insights/`  -  output location AND previous syntheses (create this folder)

## Gotchas

**Only surface non-obvious connections.** The most common failure mode is producing a synthesis that restates things already linked in the vault. Explicit instruction to find what hasn't been noticed is essential.

**Read everything before concluding anything.** Models that write while reading tend to anchor on early findings and miss later contradictions. The instruction to read first, write second is not decorative.

**Previous synthesis notes prevent repetition.** Without reading prior syntheses, the job surfaces the same connections every month. Always read `09-insights/` and explicitly exclude what's already been captured.

**The job is slow.** Reading 50-100 files takes time and context. This is a long-running isolated job  -  don't be surprised if it takes 10-15 minutes. Don't set a short timeout.
