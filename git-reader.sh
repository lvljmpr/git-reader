#!/bin/bash
# Check deps
jq --help > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "Installing 'jq' as it was not found..."
  apt-get update -y; apt-get install -y jq
fi
FINALMSG=''
curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commit/$END"
function do_work () {
  HEAD=$(curl -H "Authorization: token $GHPAT" "https://api.github.com/repos/$ORG/$REPO/commit/$END")
  MESSAGE=$(echo $HEAD| jq -r '.commit.message')
  PARENT=$(echo $HEAD| jq -r '.parents[].sha')
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
