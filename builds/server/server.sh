#!/bin/sh
echo -ne '\033c\033]0;Chess But\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/server_v1.x86_64" "$@"
