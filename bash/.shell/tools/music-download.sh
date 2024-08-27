#!/usr/bin/env bash

music-download () {
    local link=""
    local quality="best"
    local video_id=""
    local thumbnail_size="1000"

    show_help () {
        echo "Usage: music-d [OPTIONS] [YOUTUBE_LINK]"
        echo "Download YouTube audio in MP3 format with a square thumbnail."
        echo ""
        echo "Options:"
        echo "  -h    Show this help message"
        echo "  -q    Set quality (best, medium, worst)"
        echo "  -s    Set thumbnail size (default: 1000)"
        echo ""
        echo "If no arguments are provided, the function will prompt for input."
    }

    while getopts ":hq:s:" opt
    do
        case ${opt} in
            h) show_help
               return 0 ;;
            q) quality=$OPTARG ;;
            s) thumbnail_size=$OPTARG ;;
            \?) echo "Invalid option: $OPTARG" >&2
                show_help
                return 1 ;;
            :) echo "Invalid option: $OPTARG requires an argument" >&2
               show_help
               return 1 ;;
        esac
    done
    shift $((OPTIND -1))

    if [ $# -eq 1 ]
    then
        link=$1
    fi

    if [ -z "$link" ]
    then
        echo "Enter your YouTube link:"
        read -r link
    fi

    if [[ $link == *"youtube.com"* ]]
    then
        video_id=$(echo "$link" | sed -n 's/.*[?&]v=\([^&]*\).*/\1/p')
    elif [[ $link == *"youtu.be"* ]]
    then
        video_id=$(echo "$link" | sed -n 's/.*youtu.be\/\([^?]*\).*/\1/p')
    else
        echo "Invalid YouTube link format"
        return 1
    fi

    case $quality in
        best) quality_option="0" ;;
        medium) quality_option="5" ;;
        worst) quality_option="9" ;;
        *) echo "Invalid quality option. Using default (best)"
           quality_option="0" ;;
    esac

    # Set up a temporary directory
    tmp_dir=~/Movies/Youtube-dl/tmp
    mkdir -p "$tmp_dir"

    # Download thumbnail without downloading the video
    yt-dlp --write-thumbnail --skip-download -o "$tmp_dir/thumbnail.%(ext)s" "https://www.youtube.com/watch?v=$video_id"

    # Resize and create a square thumbnail using ImageMagick
    magick "$tmp_dir/thumbnail."* -resize "${thumbnail_size}x${thumbnail_size}^" -gravity Center -extent "${thumbnail_size}x${thumbnail_size}" "$tmp_dir/square_thumbnail.jpg"

    # Download and process the audio with a predictable filename
    audio_file="$tmp_dir/output.mp3"
    yt-dlp -x --audio-format mp3 --audio-quality "$quality_option" --add-metadata -o "$audio_file" "https://www.youtube.com/watch?v=$video_id"

    # Attach the square thumbnail to the downloaded MP3
    ffmpeg -i "$audio_file" -i "$tmp_dir/square_thumbnail.jpg" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "${audio_file%.mp3}_temp.mp3" > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Failed to attach the thumbnail to the MP3 file."
    fi

    # Replace the original file with the new one
    echo "Download complete. Square thumbnail attached to $audio_file"
    mv "${audio_file%.mp3}_temp.mp3" "$audio_file"

    # Move the final MP3 file out of the temporary directory
    # Move the final MP3 file out of the temporary directory
    mv "$audio_file" ~/Movies/Youtube-dl/
    echo "Right now, the song name is 'output.mp3'."
    echo "I advise you to change the name."
    echo -n "Enter the name of the song (leave blank if you are too lazy): "
    read input

    # If the user leaves the input blank, append a random number to the filename
    if [[ -z "$input" ]]; then
        random_number=$RANDOM
        final_name="music-$random_number.mp3"
    else
        # Check if the user input already has the .mp3 extension, if not, add it
        if [[ "$input" != *.mp3 ]]; then
            final_name="${input}.mp3"
        else
            final_name="$input"
        fi
    fi

    # Rename the file with the chosen or generated name
    mv "$HOME/Movies/Youtube-dl/output.mp3" "$HOME/Movies/Youtube-dl/$final_name"
    echo "The song has been renamed to '$final_name'."

    # Clean up temporary files
    rm -rf "$tmp_dir"
}
