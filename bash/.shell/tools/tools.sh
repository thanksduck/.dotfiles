#!/bin/bash

# Define an array of script files to source
scripts=(
    "move-files.sh"
    "compress-directory.sh"
    "count-files.sh"
    "screen-copy.sh"
    "deploy-now.sh"
    "tailwind.sh"
    "music-d.sh"
)

# Source all scripts
for script in "${scripts[@]}"; do
    if [ -f "./$script" ]; then
        source "./$script"
    else
        echo "Warning: $script not found"
    fi
done

# Define wrapper functions
move_images() { move_files images "$@"; }
move_videos() { move_files videos "$@"; }
move_documents() { move_files documents "$@"; }

# Main execution
main() {
    echo "File operations script loaded."
    echo "Available functions:"
    echo "- move_images"
    echo "- move_videos"
    echo "- move_documents"
    # Add other available functions here
}

main
