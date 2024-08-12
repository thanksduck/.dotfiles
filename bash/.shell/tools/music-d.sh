#!/usr/bin/env bash
music-d() {
    local link=""
    local quality=""
    local video_id=""

    # Function to display help message
    show_help() {
        echo "Usage: music-d [OPTIONS] [YOUTUBE_LINK]"
        echo "Download YouTube audio in MP3 format."
        echo ""
        echo "Options:"
        echo "  -h    Show this help message"
        echo "  -q    Set quality (best, medium, worst)"
        echo ""
        echo "If no arguments are provided, the function will prompt for input."
    }

    # Parse command-line arguments
    while getopts ":hq:" opt; do
        case ${opt} in
            h )
                show_help
                return 0
                ;;
            q )
                quality=$OPTARG
                ;;
            \? )
                echo "Invalid option: $OPTARG" 1>&2
                show_help
                return 1
                ;;
            : )
                echo "Invalid option: $OPTARG requires an argument" 1>&2
                show_help
                return 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Check if link is provided as an argument
    if [ $# -eq 1 ]; then
        link=$1
    fi

    # If link is not provided, ask for it
    if [ -z "$link" ]; then
        echo "Enter your YouTube link:"
        read -r link
    fi

    # Extract video ID from the link
    if [[ $link == *"youtube.com"* ]]; then
        video_id=$(echo "$link" | sed -n 's/.*[?&]v=\([^&]*\).*/\1/p')
    elif [[ $link == *"youtu.be"* ]]; then
        video_id=$(echo "$link" | sed -n 's/.*youtu.be\/\([^?]*\).*/\1/p')
    else
        echo "Invalid YouTube link format"
        return 1
    fi

    # If quality is not provided, ask for it
    if [ -z "$quality" ]; then
        echo "Choose your quality: a) Best b) Medium c) Worst"
        read -r quality_choice
        case $quality_choice in
            a|A) quality="best" ;;
            b|B) quality="medium" ;;
            c|C) quality="worst" ;;
            *) echo "Invalid choice. Using default (best)"; quality="best" ;;
        esac
    fi

    # Set yt-dlp quality option based on user choice
    case $quality in
        best) quality_option="0" ;;
        medium) quality_option="5" ;;
        worst) quality_option="9" ;;
        *) echo "Invalid quality option. Using default (best)"; quality_option="0" ;;
    esac

    # Download the audio
    yt-dlp -x --audio-format mp3 --audio-quality "$quality_option" --embed-thumbnail --add-metadata "https://www.youtube.com/watch?v=$video_id"
}
