#!/bin/bash
# Check deps
jq --help > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "Installing 'jq' as it was not found..."
  apt-get update -y; apt-get install -y jq
fi
FINALMSG="## CHANGELOG : $ORG/$REPO\n##########\n\n"
function check_err () {
  if [ "$?" != "0" ]; then
    printf "ERR: The start and end SHAs in inputs.json do not appear to be valid."
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
  FINALMSG="$FINALMSG\n$MESSAGE"
}
while [ "$PARENT" != "$BASE" ]; do
  do_work
done
if [ "$PARENT" = "$BASE" ]; then
  do_work
  do_work
else
  printf "ERR: Could not produce commit list with inputs.json provided."
  exit 1
fi
printf "$FINALMSG"
exit 0
