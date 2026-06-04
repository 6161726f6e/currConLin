#!/bin/bash
# Summarize unique connections from netput files
# Each connection printed once with count of files it appears in

shopt -s nullglob
files=(netput*.txt)

if [ ${#files[@]} -eq 0 ]; then
    echo "No netput*.txt files found."
    exit 1
fi

awk '
BEGIN { file_count = 0 }
FNR == 1 { file_count++ }
/^proc:port = / {
    match($0, /\("([a-zA-Z0-9_-]+)",pid=([0-9]+),fd=([0-9]+)/, m)
    if (RSTART > 0) {
        pname = m[1]
        pid = m[2]
        fd = m[3]
        socket = pid ":" fd
    }
}
/^dest_IP = / {
    match($0, /dest_IP = ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+)/, d)
    if (RSTART > 0) {
        dest = d[1] ":" d[2]
        key = pname " (" socket ") --> " dest
        if (!(key SUBSEP file_count in seen)) {
            seen[key SUBSEP file_count] = 1
            count[key]++
        }
    }
}
END {
    for (key in count) {
        print count[key], key
    }
}
' "${files[@]}" | sort -n
