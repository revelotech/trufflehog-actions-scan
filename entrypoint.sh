#!/usr/bin/env sh
set -e # Abort script at first error

if [ -z $INPUT_DEFAULT_BRANCH ]; then
  INPUT_DEFAULT_BRANCH='master'
fi

if [ -z $IGNORE_LIST_PATH ]; then
  IGNORE_LIST_PATH='/.ignorelist'
fi

if [ -z $REGEXES_PATH ]; then
  REGEXES_PATH='/regexes.json'
fi

if [ -z $IGNORE_PATTERNS_PATH ]; then
  IGNORE_PATTERNS_PATH='/ignore_patterns.json'
fi

if [ "$SHOW_STRINGS" = true ]; then
  JQ_QUERY="del(.[].diff) |del(.[].printDiff)"
else
  JQ_QUERY="del(.[].diff) |del(.[].printDiff) |del(.[].stringsFound)"
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
max_depth=$(git rev-list origin/${INPUT_DEFAULT_BRANCH}..HEAD --count)

echo ":: Current branch is $current_branch."
echo ":: Depth is $max_depth."

if [ $max_depth -eq 0 ]; then
  echo "No commit found. Leaving."
  exit 0
fi

if [ $current_branch = "HEAD" ]; then
  current_branch="check-secrets-from-pr"
  echo "checking out to $current_branch"
  git checkout -b $current_branch
fi

args="--regex --branch ${current_branch} --json \
  --rules $REGEXES_PATH \
  --allow $IGNORE_PATTERNS_PATH \
  -x ${IGNORE_LIST_PATH}"
if [ $max_depth -gt 0 ]; then
  args="$args --max_depth=${max_depth}"
fi

query="$args" # Build args query with repository url
echo ":: Running \"trufflehog $query .\""
res=$(trufflehog $query . | jq -s "$JQ_QUERY")
if [ "$res" != "[]" ]; then
  printf '%s' "$res" | jq
  exit 1
else
  echo ":: Nothing found."
fi
