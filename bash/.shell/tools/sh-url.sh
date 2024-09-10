#!/bin/bash
shorten_url() {
    [ -z "$URL_HOST" ] && { echo "Error: URL_HOST is not set."; return 1; }
    [ -z "$URL_TOKEN" ] && { echo "Error: URL_TOKEN is not set."; return 1; }
  usage() {
    echo "Usage: shorten_url [OPTIONS]
Options:
  -n <target_url>            Shorten a normal URL
  -p <target_url> <alias>    Create a premium URL with custom alias
  --help                     Show this help message"
  }
  [ $# -eq 0 ] && {
    echo "Choose an option:
1) Normal Link
2) Premium Link"
    read -r choice
    case $choice in
      1) echo "Enter the target URL: " && read -r target_url
         response=$(curl -s -X POST "$URL_HOST/api" -H "Authorization: $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$target_url\"}");;
      2) echo "Enter the target URL: " && read -r target_url
         echo "Enter the custom alias: " && read -r alias
         response=$(curl -s -X POST "$URL_HOST/pro" -H "Authorization: $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$target_url\", \"shortUrl\": \"$alias\"}");;
      *) echo "Invalid option."; usage; return 1;;
    esac
    short_url=$(echo "$response" | jq -r '.shortUrl')
    [ -n "$short_url" ] && echo "$URL_HOST/$short_url" || echo "Error: Unable to extract short URL from response"
    return
  }
  while [ "$#" -gt 0 ]; do
    case $1 in
      -n) [ -z "$2" ] && { echo "Error: Target URL required for normal link."; usage; return 1; }
          response=$(curl -s -X POST "$URL_HOST/api" -H "Authorization: $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$2\"}")
          shift 2;;
      -p) [ -z "$2" ] || [ -z "$3" ] && { echo "Error: Both target URL and alias required for premium link."; usage; return 1; }
          response=$(curl -s -X POST "$URL_HOST/pro" -H "Authorization: $URL_TOKEN" -H "Content-Type: application/json" --data "{\"originalUrl\": \"$2\", \"shortUrl\": \"$3\"}")
          shift 3;;
      --help) usage; return 0;;
      *) echo "Invalid option: $1"; usage; return 1;;
    esac
  done
  command -v jq >/dev/null 2>&1 || { echo "Response: $response"; return; }
  short_url=$(echo "$response" | jq -r '.shortUrl')
  [ -n "$short_url" ] && echo "$URL_HOST/$short_url" || echo "Error: Unable to extract short URL from response"
}
