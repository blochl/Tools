#!/bin/sh

set -e

log() {
    >&2 printf "%b\n" "${*}"
}

fatal() {
    log "ERROR: ${*}"
    exit 1
}

if ! git diff --quiet || ! git diff --cached --quiet
then
    fatal "Please commit your current changes or stash them before running this script."
fi

git_root="$(git rev-parse --show-toplevel)"

find "${git_root}/" -path "${git_root}/.git" -prune -o -type f -print0 | xargs -0 sh -c '
    for file in "${@}"
    do
        if file --mime "${file}" | grep -q "charset=[^[:space:]]*\(ascii\|utf-8\)" | grep -v "text/[^[:space:]]*diff"
        then
            sed -i "s/[[:space:]]\+$//" "${file}"
            [ -z "$(tail -c1 "${file}")" ] || echo >> "${file}"
            [ "${file##*.}" != "json" ] ||
                { jq < "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"; }
        fi
    done
' _

if git diff --quiet
then
    log "SUCCESS: No commits need to be modified."
else
    fatal "Trailing white spaces, DOS line endings, malformed JSON files,"`
         `"\nor no newline at EOF detected."`
         `"\nI have made the necessary fixes."`
         `"\nPlease amend the commits where they were introduced before pushing."
fi
