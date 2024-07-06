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


move_documents() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: move_documents source_directory destination_directory"
    return 1
  fi

  SOURCE_DIR=$1
  DEST_DIR=$2

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    return 1
  fi

  mkdir -p "$DEST_DIR"

  find "$SOURCE_DIR" -type f \( -iname '*.pdf' -o -iname '*.doc' -o -iname '*.docx' -o -iname '*.xls' -o -iname '*.xlsx' -o -iname '*.ppt' -o -iname '*.pptx' -o -iname '*.txt' \) -exec mv {} "$DEST_DIR" \;

  echo "All document files have been moved from $SOURCE_DIR to $DEST_DIR."
}

compress_directory() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: compress_directory source_directory output_file"
    return 1
  fi

  SOURCE_DIR=$1
  OUTPUT_FILE=$2

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    return 1
  fi

  tar -czvf "$OUTPUT_FILE" -C "$SOURCE_DIR" .

  echo "Directory $SOURCE_DIR has been compressed into $OUTPUT_FILE."
}

count_files_by_type() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: count_files_by_type directory extension"
    return 1
  fi

  DIRECTORY=$1
  EXTENSION=$2

  if [ ! -d "$DIRECTORY" ]; then
    echo "Directory does not exist: $DIRECTORY"
    return 1
  fi

  COUNT=$(find "$DIRECTORY" -type f -iname "*.$EXTENSION" | wc -l)

  echo "There are $COUNT files with the extension .$EXTENSION in the directory $DIRECTORY."
}
