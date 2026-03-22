# [Job Name]

## What it does

[One paragraph. What problem does this solve? Why would someone want to run this?]

## Cron command

```bash
openclaw cron add \
  --name "job-name" \
  --cron "0 7 * * 1-5" \
  --tz "Europe/London" \
  --session isolated \
  --model "MODEL_NAME" \
  --message "Your prompt here or: Read and follow the skill at workspace/skills/skill-name.md exactly." \
  --announce \
  --channel discord \
  --to "channel:YOUR_CHANNEL_ID"
```

## Full prompt

If the prompt is short enough to inline, put it here.
If it's a skill file, put the full skill content here.

```
[Full prompt text]
```

## Model recommendation

[Which model and why. Include the cost vs capability tradeoff.
Be specific  -  "mid-tier" is more useful than "any model".]

## Timing rationale

[Why this schedule. What to avoid scheduling around.
Include why this time was chosen over alternatives.]

## Dependencies

**Required tools/skills:**
- [tool or skill name]  -  [why it's needed]

**Vault structure assumed:**
- `[folder]/`  -  [what's in it and how it's used]

**Other jobs this depends on:**
- [job name]  -  [relationship]

## Gotchas

[What broke in production and how to avoid it.
If nothing has broken yet, it hasn't run long enough  -  come back when it has.]

## Example output (optional)

[What a successful run looks like. Paste a real output snippet if you have one.]
