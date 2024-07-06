#!/bin/bash

move_images() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: move_images source_directory destination_directory"
    return 1
  fi

  SOURCE_DIR=$1
  DEST_DIR=$2

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    return 1
  fi

  mkdir -p "$DEST_DIR"

  find "$SOURCE_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \) -exec mv {} "$DEST_DIR" \;

  echo "All image files have been moved from $SOURCE_DIR to $DEST_DIR."
}

move_videos() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: move_videos source_directory destination_directory"
    return 1
  fi

  SOURCE_DIR=$1
  DEST_DIR=$2

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    return 1
  fi

  mkdir -p "$DEST_DIR"

  find "$SOURCE_DIR" -type f \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.webm' -o -iname '*.mpeg' -o -iname '*.mpg' \) -exec mv {} "$DEST_DIR" \;

  echo "All video files have been moved from $SOURCE_DIR to $DEST_DIR."
}
