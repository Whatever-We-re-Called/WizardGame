#!/bin/sh
echo -ne '\033c\033]0;Multiplayer Stuff\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Multiplayer Stuff.x86_64" "$@"
