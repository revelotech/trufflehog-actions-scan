#!/usr/bin/env sh
set -e # Abort script at first error

# Ensure master ref is present
git fetch -u origin master:master

current_branch=$(git rev-parse --abbrev-ref HEAD)
max_depth=$(git rev-list origin/master..HEAD --count)

echo current branch is $current_branch
echo max depth is $max_depth

if [[ "$current_branch" != 'master' && $max_depth -eq 0 ]]; then
  exit 0
fi

args="--regex --branch ${current_branch} --json -x /.ignorelist" # Default trufflehog options
if [[ $max_depth -gt 0 ]]; then
  args="$args --max_depth=${max_depth}"
fi

query="$args" # Build args query with repository url
echo running \"$query\"
res=$(trufflehog $query . | jq -s 'del(.[].diff) |del(.[].printDiff) |del(.[].stringsFound)')
if [[ "$res" != "[]" ]]; then
  echo $res | jq
  exit 1
fi
