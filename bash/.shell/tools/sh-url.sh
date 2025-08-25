#!/usr/bin/env zsh?

shorten_url() {
    [ -z "$URL_HOST" ] && { echo "Error: URL_HOST is not set."; return 1; }
    [ -z "$URL_TOKEN" ] && { echo "Error: URL_TOKEN is not set."; return 1; }

    usage() {
        echo "Usage: shorten_url [OPTIONS]
Options:
  -n <target_url>            Shorten a normal URL
  -p <target_url> <alias>    Create a premium URL with custom alias
  -u <target_url> <alias>    Update a premium URL with custom alias
  --help                     Show this help message"
    }

    process_response() {
        local response="$1"
        if command -v jq >/dev/null 2>&1; then
            short_url=$(echo "$response" | jq -r '.shortUrl')
            [ -n "$short_url" ] && echo "$URL_HOST/$short_url" || echo "Error: Unable to extract short URL from response"
        else
            echo "Response: $response"
        fi
    }

    if [ $# -eq 0 ]; then
        echo "Choose an option:
        1) Normal Link
        2) Premium Link
        3) Update Premium Link"
        read choice
        case $choice in
            1)  echo -n "Enter the target URL: "
                read target_url
                response=$(curl -s -X POST "$URL_HOST/api" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$target_url\"}")
                ;;
            2)  echo -n "Enter the target URL: "
                read target_url
                echo -n "Enter the alias you want: "
                read alias
                response=$(curl -s -X POST "$URL_HOST/pro" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$target_url\", \"shortUrl\": \"$alias\"}")
                ;;
            3)  echo -n "Enter the alias you want to update: "
                read alias
                echo -n "Enter the new target URL: "
                read target_url
                response=$(curl -s -X PUT "$URL_HOST/pro" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$target_url\", \"shortUrl\": \"$alias\"}")
                ;;
            *)  echo "Invalid option."
                usage
                return 1
                ;;
        esac
        process_response "$response"
        return
    fi

    while [ "$#" -gt 0 ]; do
        case $1 in
            -n) [ -z "$2" ] && { echo "Error: Target URL required for normal link."; usage; return 1; }
                response=$(curl -s -X POST "$URL_HOST/api" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$2\"}")
                shift 2
                ;;
            -p) [ -z "$2" ] || [ -z "$3" ] && { echo "Error: Both target URL and alias required for premium link."; usage; return 1; }
                response=$(curl -s -X POST "$URL_HOST/pro" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$2\", \"shortUrl\": \"$3\"}")
                shift 3
                ;;
            -u) [ -z "$2" ] || [ -z "$3" ] && { echo "Error: Both target URL and alias required for updating premium link."; usage; return 1; }
                response=$(curl -s -X PUT "$URL_HOST/pro" -H "Authorization: Bearer $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$2\", \"shortUrl\": \"$3\"}")
                shift 3
                ;;
            --help) usage; return 0 ;;
            *) echo "Invalid option: $1"; usage; return 1 ;;
        esac
        process_response "$response"
    done
}
