# Nightly Backup

## What it does

Runs every night and pushes your vault and agent configuration to a remote git repository. Ensures your skills, persona files, memory, and workspace are backed up offsite. Runs a refresh script first to copy workspace files into the backup repo, then pushes with an auto-generated commit message.

## Cron command

```bash
openclaw cron add \
  --name "nightly-backup" \
  --cron "10 23 * * *" \
  --tz "Europe/London" \
  --session isolated \
  --model "YOUR_CHEAPEST_MODEL" \
  --message "Run the nightly backup. Execute: bash /path/to/refresh.sh && bash /path/to/sync.sh push. Report BACKUP_OK or BACKUP_ERROR with details." \
  --no-deliver
```

## Full prompt

```
You are running the nightly backup. Execute each step in order.

## 1. SYNC CALENDAR CACHE
Run: vdirsyncer sync
This refreshes the local calendar cache before backup.
If vdirsyncer is not installed, skip this step silently.

## 2. COPY WORKSPACE FILES
Run: bash /path/to/refresh.sh
This copies:
- Custom skills from workspace/skills/ → backup-repo/data/skills/
- Kids workspace files → backup-repo/data/workspace-kids/
- Ops scripts → backup-repo/ops/

## 3. PUSH TO GIT
Run: bash /path/to/sync.sh push
This stages all changes, commits with message "auto-sync [date]",
and pushes to the remote repository.

## 4. REPORT
If all steps succeeded: output "BACKUP_OK [date]"
If any step failed: output "BACKUP_ERROR  -  [which step]  -  [error detail]"

Do not deliver output unless there is an error.
```

## Model recommendation

**Cheapest viable model.** This job runs shell commands. No AI reasoning needed. The model is just an orchestrator executing bash. Use your cheapest model or consider using `--system-event` in main session instead of an isolated job for pure shell execution.

## Timing rationale

**11:10pm**  -  chosen deliberately:
- After your working day ends
- Before memory consolidation (11:45pm)
- Before the research scan (1:15am)
- Gives a 2-hour buffer before midnight

Avoid midnight exactly  -  too many systems run at 00:00.

## Dependencies

**Required:**
- A git repository configured as the backup destination
- `refresh.sh`  -  copies workspace files into the backup repo
- `sync.sh`  -  stages, commits, and pushes
- SSH keys or HTTPS credentials configured for the remote repo

**Optional:**
- `vdirsyncer` for calendar cache sync before backup

**Vault structure:**
- Backs up: skills, persona files (SOUL.md, USER.md etc.), memory files, ops scripts

## refresh.sh example

```bash
#!/bin/bash
BACKUP_DIR="$HOME/openclaw-memory"
WORKSPACE="/data/.openclaw/workspace"

# Skills
cp -r "$WORKSPACE/skills/"*.md "$BACKUP_DIR/data/skills/" 2>/dev/null

# Core persona files
for f in SOUL.md USER.md AGENTS.md MEMORY.md HEARTBEAT.md IDENTITY.md TOOLS.md BOOT.md GOALS.md; do
  cp "$WORKSPACE/$f" "$BACKUP_DIR/data/" 2>/dev/null
done

echo "Refresh complete: $(date)"
```

## sync.sh example

```bash
#!/bin/bash
BACKUP_DIR="$HOME/openclaw-memory"
cd "$BACKUP_DIR"

git add -A
git commit -m "auto-sync $(date +%Y-%m-%d)" --allow-empty
git push origin main

echo "Sync complete: $(date)"
```

## Gotchas

**Never commit `~/.openclaw/` directly.** That directory contains secrets, session tokens, and credentials. The backup repo should only contain workspace files you explicitly copy via `refresh.sh`  -  never the full `.openclaw` directory.

**SSH keys need to be accessible to the process.** If your gateway runs as a different user than your SSH key owner, the git push will fail silently. Test with `git push` manually from the same user context as the gateway process.

**Empty commits are fine.** On nights when nothing changed, `git commit` fails without `--allow-empty`. Either use `--allow-empty` or check for changes before committing.

**Audit trail bonus.** Your backup repo becomes an append-only audit log when combined with audit log forwarding. Add this to `refresh.sh`:
```bash
cp /var/log/openclaw/audit.jsonl "$BACKUP_DIR/logs/audit-$(date +%Y-%m-%d).jsonl" 2>/dev/null
```
