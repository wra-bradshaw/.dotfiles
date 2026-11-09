#!/usr/bin/env bash
# The only step that writes to GitHub.
#   publish.sh ready | nothing-to-do | fixed PR | flaky PR | stuck PR
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
branch=$(git branch --show-current)
result=${1:?usage: publish.sh RESULT [PR]}
pr=${2:-}

case "$result" in
  ready)
    git push -u origin "HEAD:refs/heads/$branch"
    url=$(gh pr create --base main --head "$branch" \
      --title "chore: flake update $(date -u +%Y-%m-%d)" --body-file .flake-update/pr-body.md)
    gh pr merge "$url" --auto --squash --delete-branch
    gh pr list --state open --json number,headRefName \
      --jq ".[] | select((.headRefName | startswith(\"flake-update/\")) and .headRefName != \"$branch\") | .number" |
      while read -r old; do gh pr close "$old" --delete-branch --comment "Superseded by $url."; done
    ;;
  fixed) git push --force-with-lease origin "HEAD:refs/heads/$branch" ;;
  flaky)
    head=$(gh pr view "$pr" --json headRefOid --jq .headRefOid)
    for run in $(gh run list --commit "$head" --status failure --json databaseId --jq '.[].databaseId'); do
      gh run rerun "$run" --failed
    done
    ;;
  stuck | nothing-to-do) ;;
  *)
    echo "unknown result: $result" >&2
    exit 1
    ;;
esac

if [ -n "$pr" ] && [ -s .flake-update/comment.md ]; then
  gh pr comment "$pr" --body-file .flake-update/comment.md
fi
[ "$result" != stuck ]
