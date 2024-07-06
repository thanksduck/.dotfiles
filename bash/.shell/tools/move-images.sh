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

# Find and move image files to the destination directory
find "$SOURCE_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \) -exec mv {} "$DEST_DIR" \;

echo "All image files have been moved from $SOURCE_DIR to $DEST_DIR."
