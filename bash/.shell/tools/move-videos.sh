#!/bin/bash

# Check if both source and destination directories are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 source_directory destination_directory"
  exit 1
fi

SOURCE_DIR=$1
DEST_DIR=$2

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory does not exist: $SOURCE_DIR"
  exit 1
fi

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Find and move video files to the destination directory
find "$SOURCE_DIR" -type f \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.webm' -o -iname '*.mpeg' -o -iname '*.mpg' \) -exec mv {} "$DEST_DIR" \;

echo "All video files have been moved from $SOURCE_DIR to $DEST_DIR."
