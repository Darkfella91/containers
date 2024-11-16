#!/usr/bin/env bash
version="$(curl -sX GET "https://api.github.com/repos/morpheus65535/bazarr/releases?per_page=1&pre_release=true" | jq --raw-output '.[0].tag_name' 2>/dev/null)"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
