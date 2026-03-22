#!/usr/bin/env bash
set -euo pipefail

echo "Running simple secrets guard on staged files..."
# keywords to search for (case-insensitive)
PATTERNS=(
  "secret"
  "password"
  "token"
  "api_key"
  "aws"
  "BEGIN PRIVATE KEY"
  "PRIVATE KEY"
  "ssh-rsa"
  "Authorization"
  "apikey"
  "auth_token"
  "passwd"
  "-----BEGIN"
  "AKIA"
  "ghp_"
)

# get staged files
FILES=$(git diff --cached --name-only --diff-filter=ACM)
if [ -z "$FILES" ]; then
  echo "No staged files to check."
  exit 0
fi

EXIT_CODE=0
for f in $FILES; do
  # skip binary files
  if file --brief --mime-type "$f" | grep -qv text; then
    continue
  fi
  for p in "${PATTERNS[@]}"; do
    if git show :"$f" | grep -i --line-number --color=never -E "$p" >/dev/null 2>&1; then
      echo "Potential secret pattern '$p' found in staged file: $f"
      git show :"$f" | grep -i --line-number -E "$p" | sed 's/^/  /'
      EXIT_CODE=2
    fi
  done
done

if [ $EXIT_CODE -ne 0 ]; then
  echo "\nCommit blocked: potential secret(s) detected in staged files.\nIf these are false positives, adjust .pre-commit-config.yml or update your staged changes."
  exit $EXIT_CODE
fi

echo "No obvious secrets detected by pre-commit guard." 
exit 0
