#!/bin/bash

local opts show=0 clip=0 tail=0
opts="$($GETOPT -o sct -l show,clip,tail -n "$PROGRAM" -- "$@")"
local err=$?
echo "$opts"
eval set -- "$opts"
while true; do case $1 in
	-s|--show) show=1; shift  ;;
	-c|--clip) clip=1; shift  ;;
	-t|--tail) tail=1; shift  ;;
    --)  shift; break   ;;
esac done

[[ $err -ne 0 || ( $show -eq 1 && $tail -eq 1 ) ]] && die "Usage: $PROGRAM fzf [--show,-s|--tail,-t] [--clip,-c] [query]"

if [[ $show -eq 0 && $tail -eq 0 && $clip -eq 0 ]]; then
    show=1
fi

local query="$1"

local path="$(find ~/.password-store -type f -name '*.gpg' -printf '%P\n' \
    | sed 's/\.gpg$//' \
    | fzf --height 12 --exact --select-1 --query="$query"
)" || exit 1

check_sneaky_paths "$path"

if [[ $clip -eq 1 ]]; then
    cmd_show -c "$path" || exit $?
fi
if [[ $show -eq 1 ]]; then
    cmd_show "$path" || exit $?
elif [[ $tail -eq 1 ]]; then
    cmd_extension tail "$path" || exit $?
fi