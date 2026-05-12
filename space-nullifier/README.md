# Repo-Cleaning Tool

Run `space-nullifier.sh` in yout Git repository to:

1. Eliminate all trailing whitespaces
1. Eliminate DOS line endings
1. Eliminate no newline at EOF

If any of the above are present, the script corrects these, and exits with an
error. If nothing is changed - it exits with success.

A great tool for self-verification and inclusion in CI.

Also a Git hook variant is available to prevent commits that introduce these:
`pre-commit`

A varinamt exists which also unifies JSON files' formatting:
`space-nullifier-with-json.sh`
