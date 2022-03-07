#!/bin/bash
# Check deps
jq --help > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "Installing 'jq' as it was not found..."
  apt-get update -y; apt-get install -y jq
fi
FINALMSG=''
function check_err () {
  if [[ "$?" != "0" ]]; then
    printf "ERR: Could not produce commit list with inputs.json provided."
    exit 1
  fi
}
function do_work () {
  curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commits/$END" > /dev/null 2>&1
  HEAD=$(curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commits/$END")
  check_err
  MESSAGE=$(echo $HEAD| jq -r '.commit.message')
  PARENT=$(echo $HEAD| jq -r '.parents[].sha')
  END="$PARENT"
}
while [[ "$PARENT" != "$BASE" ]]; do
  FINALMSG="$FINALMSG\n$MESSAGE"
  do_work
done
if [[ "$PARENT" == "$BASE" ]]; then
  FINALMSG="$FINALMSG\n$MESSAGE"
  do_work
  FINALMSG="$FINALMSG\n$MESSAGE"
  do_work
else
  printf "ERR: Could not produce commit list with inputs.json provided."
  exit 1
fi
printf "$FINALMSG"
exit 0
