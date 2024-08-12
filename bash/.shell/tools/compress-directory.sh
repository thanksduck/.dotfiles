#!/usr/bin/env bash
compress_directory() {
    [[ $# -ne 2 ]] && { echo "Usage: compress_directory source_directory output_file"; return 1; }
    [[ ! -d "$1" ]] && { echo "Source directory does not exist: $1"; return 1; }
    tar -czvf "$2" -C "$1" . && echo "Directory $1 has been compressed into $2."
}
