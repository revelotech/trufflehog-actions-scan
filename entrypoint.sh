#!/usr/bin/env sh
set -e # Abort script at first error

if [[ -z $INPUT_DEFAULT_BRANCH ]]; then
  INPUT_DEFAULT_BRANCH='master'
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
max_depth=$(git rev-list origin/${INPUT_DEFAULT_BRANCH}..HEAD --count)

echo current branch is $current_branch
echo max depth is $max_depth

if [[ "$current_branch" != "$INPUT_DEFAULT_BRANCH" && $max_depth -eq 0 ]]; then
  exit 0
fi

if [[ "$current_branch" == "HEAD" ]]; then
  current_branch="check-secrets-from-pr"
  echo "checking out to $current_branch"
  git checkout -b $current_branch
fi

args="--regex --rules /regexes.json --branch ${current_branch} --json -x /.ignorelist" # Default trufflehog options
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
