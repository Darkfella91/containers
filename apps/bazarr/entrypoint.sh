#!/usr/bin/env bash
#shellcheck disable=SC2086

exec \
    /usr/bin/python3 \
        /app/bazarr/bin/bazarr.py \
            --no-update \
            --config /config \
            --port ${BAZARR__PORT} \
            "$@"
