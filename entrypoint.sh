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

# 1. search for known regexes

args="--entropy=False --regex --rules $REGEXES_PATH --branch ${current_branch} --json -x ${IGNORE_LIST_PATH}"
if [ $max_depth -gt 0 ]; then
  args="$args --max_depth=${max_depth}"
fi

echo ":: Running \"trufflehog $args .\""
res=$(trufflehog $args . | jq -s "$JQ_QUERY")
if [ "$res" != "[]" ]; then
  printf '%s' "$res" | jq
  exit 1
else
  echo ":: Nothing found."
fi

args="--entropy=True --branch ${current_branch} --json -x ${IGNORE_LIST_PATH}"
if [ $max_depth -gt 0 ]; then
  args="$args --max_depth=${max_depth}"
fi

# 2. search for high entropy

echo ":: Running \"trufflehog $args .\""
res=$(trufflehog $args . | jq -s "$JQ_QUERY" | jq -c .)
if [ "$res" != "[]" ]; then
  res=$( echo -E "$res" | tr -d '\\n')
  echo "::warning ::High entropy found"
  echo '::set-output name=high_entropy::'"$res"
else
  echo ":: Nothing found."
fi
