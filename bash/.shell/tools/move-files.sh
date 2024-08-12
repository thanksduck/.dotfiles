#!/usr/bin/env bash
move_files() {
    local type=$1 src=$2 dst=$3 extensions

    [[ $# -ne 3 ]] && { echo "Usage: move_$type source_directory destination_directory"; return 1; }
    [[ ! -d "$src" ]] && { echo "Source directory does not exist: $src"; return 1; }

    case $type in
        images) extensions="jpg|jpeg|png|gif|bmp|tiff" ;;
        videos) extensions="mp4|avi|mkv|mov|wmv|flv|webm|mpeg|mpg" ;;
        documents) extensions="pdf|doc|docx|xls|xlsx|ppt|pptx|txt" ;;
        *) echo "Invalid type: $type"; return 1 ;;
    esac

    mkdir -p "$dst"
    find "$src" -type f -regextype posix-extended -regex ".*\.($extensions)" -exec mv -t "$dst" {} +
    echo "All $type files have been moved from $src to $dst."
}
