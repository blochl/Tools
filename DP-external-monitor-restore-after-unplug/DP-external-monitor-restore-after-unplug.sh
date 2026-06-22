#!/bin/bash

set -eE

log() {
    >&2 printf "%s\n" "${*}"
}

fatal() {
    log "ERROR: ${*}"
    exit 1
}

readonly settle_secs=4

at_least_one_dp_connected() {
    local status

    for status in /sys/class/drm/card*-DP-*/status
    do
        [ -r "${status}" ] || continue
        [ "$(cat "${status}")" != "connected" ] || return 0
    done

    return 1
}

bounce_vt() {
    local current scratch

    current="$(sudo fgconsole 2>/dev/null)" || fatal "No active VT to bounce."

    scratch=6
    if (( current == 6 ))
    then
        scratch=5
    fi

    log "Bouncing VT ${current} -> ${scratch} -> ${current} to re-init the display."
    sudo chvt "${scratch}"
    sleep 1
    sudo chvt "${current}"
}

main() {
    sleep "${settle_secs}"

    if at_least_one_dp_connected
    then
        log "DP already connected - nothing to do."
        exit 0
    fi

    bounce_vt
    log "Done."
}

main
