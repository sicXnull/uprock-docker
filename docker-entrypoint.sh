#!/bin/sh
set -eu

mkdir -p /data/config /data/cache /data/state /tmp/runtime

# `daemon run` stays in the foreground and handles SIGTERM, so it can be PID 1.
# Do not use `daemon install` here: this image has no systemd.
exec /usr/local/bin/uprock "$@"
