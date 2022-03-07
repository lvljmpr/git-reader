#!/bin/bash
# Check deps
jq --help > /dev/null 2>&1
if [ $? != 0 ]; then
  printf "Installing 'jq' as it was not found..."
  apt-get update -y; apt-get install -y jq
fi
FINALMSG="## CHANGELOG : $ORG/$REPO\n---\n\n"
function check_err () {
  if [ "$?" != "0" ]; then
    printf "ERR: The start and end SHAs in inputs.json do not appear to be valid."
    exit 1
  fi
}
function do_work () {
  HEAD=$(curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commits/$END")
  MESSAGE=$(echo $HEAD| jq -r '.commit.message')
  PARENT=$(echo $HEAD| jq -r '.parents[].sha')
  END="$PARENT"
  FINALMSG="$FINALMSG\n---\n$MESSAGE\n"
}
curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commits/$END" > /dev/null 2>&1
check_err
while [ "$PARENT" != "$BASE" ]; do
  do_work
done
do_work
printf "$FINALMSG"
exit 0
