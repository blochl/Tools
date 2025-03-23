#!/bin/sh

set -e

log() {
    >&2 printf "%s\n" "${*}"
}

fatal() {
    log "ERROR: ${*}"
    exit 1
}

git_root="$(git rev-parse --show-toplevel)"

find "${git_root}/" -path "${git_root}/.git" -prune -o -type f -print0 | xargs -0 sh -c '
    for file in "${@}"
    do
        if file --mime "${file}" | grep -q "charset=[^[:space:]]*ascii"
        then
            sed -i "s/[[:space:]]\+$//" "${file}"
            [ -z "$(tail -c1 "${file}")" ] || echo >> "${file}"
        fi
    done
' _

if git diff --quiet
then
    log "SUCCESS"
else
    fatal "Trailing white spaces, DOS line endings, or no newline at EOF detected."
fi
