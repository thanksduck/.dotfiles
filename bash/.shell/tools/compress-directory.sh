#!/usr/bin/env zsh?
compress_directory() {
    local source_dir output_file

    if [[ $# -ne 2 ]]; then
        echo "Usage: compress_directory <source_directory> <output_file.tar.gz>" >&2
        return 1
    fi

    source_dir="$1"
    output_file="$2"

    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Source directory does not exist: $source_dir" >&2
        return 1
    fi

    if [[ ! "$output_file" =~ \.tar\.gz$ ]]; then
        output_file="${output_file}.tar.gz"
        echo "Warning: Added .tar.gz extension to output file" >&2
    fi

    if tar -czvf "$output_file" -C "$source_dir" .; then
        echo "Successfully compressed directory $source_dir into $output_file"
    else
        echo "Error: Failed to compress directory" >&2
        return 1
    fi
}
