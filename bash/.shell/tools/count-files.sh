#!/usr/bin/env bash
count_files_by_type() {
    [[ $# -ne 2 ]] && { echo "Usage: count_files_by_type directory extension"; return 1; }
    [[ ! -d "$1" ]] && { echo "Directory does not exist: $1"; return 1; }
    local count=$(find "$1" -type f -iname "*.$2" | wc -l)
    echo "There are $count files with the extension .$2 in the directory $1."
}
