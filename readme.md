# git-reader
- This script will crawl git history from `head` commit to `base` commit as specified in `inputs.json`.
- This will happen in a GitHub actions pipeline upon commit to `main` branch.
- You can also specify `repo` and `org`, but the targets would need to be public or allowed via GitHub PAT.
