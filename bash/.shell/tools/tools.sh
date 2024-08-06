#!/bin/bash
# moving files bash scripts by type
move_files() {
    local type=$1 src=$2 dst=$3 extensions

    [[ $# -ne 3 ]] && { echo "Usage: move_$type source_directory destination_directory"; return 1; }
    [[ ! -d "$src" ]] && { echo "Source directory does not exist: $src"; return 1; }

    case $type in
        images) extensions="jpg|jpeg|png|gif|bmp|tiff" ;;
        videos) extensions="mp4|avi|mkv|mov|wmv|flv|webm|mpeg|mpg" ;;
        documents) extensions="pdf|doc|docx|xls|xlsx|ppt|pptx|txt" ;;
        *) echo "Invalid type: $type"; return 1 ;;
    esac

    mkdir -p "$dst"
    find "$src" -type f -regextype posix-extended -regex ".*\.($extensions)" -exec mv -t "$dst" {} +
    echo "All $type files have been moved from $src to $dst."
}

move_images() { move_files images "$@"; }
move_videos() { move_files videos "$@"; }
move_documents() { move_files documents "$@"; }

compress_directory() {
    [[ $# -ne 2 ]] && { echo "Usage: compress_directory source_directory output_file"; return 1; }
    [[ ! -d "$1" ]] && { echo "Source directory does not exist: $1"; return 1; }
    tar -czvf "$2" -C "$1" . && echo "Directory $1 has been compressed into $2."
}

count_files_by_type() {
    [[ $# -ne 2 ]] && { echo "Usage: count_files_by_type directory extension"; return 1; }
    [[ ! -d "$1" ]] && { echo "Directory does not exist: $1"; return 1; }
    local count=$(find "$1" -type f -iname "*.$2" | wc -l)
    echo "There are $count files with the extension .$2 in the directory $1."
}

screen-copy() {
    local ip=192.168.1.4 port=5555 verbose=0

    [[ "$1" == "-h" || "$1" == "--help" ]] && { echo "Usage: screen-copy [IP_ADDRESS] [PORT]
Options:
  IP_ADDRESS   The IP address of the device (default: 192.168.1.9)
  PORT         The port number to connect to (default: 5555)
  -h, --help   Show this help message
  -v           Enable verbose mode"; return 0; }

    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ip=$1 && shift
    [[ "$1" =~ ^[0-9]+$ ]] && port=$1 && shift
    [[ "$1" == "-v" ]] && verbose=1

    { tailscale status && [[ $verbose -eq 1 ]] && echo "Tailscale is up, shutting it down"; } && tailscale down && [[ $verbose -eq 1 ]] && echo "Tailscale is now down"


    adb shell ip addr show wlan0 | grep -q "$ip" && {
        [[ $verbose -eq 1 ]] && echo "Device already connected at $ip."
        scrcpy
        return 0
    }

    [[ $verbose -eq 1 ]] && echo "Connecting to device at $ip:$port..."

    adb connect "$ip:$port" && {
        [[ $verbose -eq 1 ]] && echo "Connection successful, starting scrcpy..."
        scrcpy
    } || {
        echo "Error: No adb devices found. Please connect your device first.
Hints:
  - Turn on the WiFi and enable USB debugging on your device.
  - Check the IP address of the device.
  - Make sure adb tcpip is enabled.
  - -h or --help for help"
        return 99
    }
}


deploy-now() {
    local source_dir=""
    local dest_dir=""
    local build_command=""
    local build_output_dir=""
    local verbose=false

    # Function to display help message
    show_help() {
        echo "Usage: deploy-now <source-directory> <destination-directory> [OPTIONS]"
        echo "Options:"
        echo "  --react              Build a React project"
        echo "  --vite               Build a Vite project"
        echo "  -v, --verbose        Enable verbose mode"
        echo "  -h, --help           Display this help message"
        echo "Example:"
        echo "  deploy-now ./my-project user@host:/path/to/remote/destination --vite -v"
    }

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --react)
                build_command="npm run build"
                build_output_dir="build"
                shift
                ;;
            --vite)
                build_command="npm run build"
                build_output_dir="dist"
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            *)
                if [[ -z "$source_dir" ]]; then
                    source_dir="$1"
                elif [[ -z "$dest_dir" ]]; then
                    dest_dir="$1"
                else
                    echo "Error: Too many arguments."
                    show_help
                    return 1
                fi
                shift
                ;;
        esac
    done

    # Check if required arguments are provided
    if [[ -z "$source_dir" || -z "$dest_dir" || -z "$build_command" ]]; then
        echo "Error: Missing required arguments or build type."
        show_help
        return 1
    fi

    # Execute the deployment
    if $verbose; then
        echo "Source directory: $source_dir"
        echo "Destination directory: $dest_dir"
        echo "Building project..."
    fi

    cd "$source_dir" || { echo "Error: Could not change to source directory."; return 1; }

    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        echo "Error: package.json not found in $source_dir. Are you in the correct directory?"
        return 1
    fi

    # Check if the build script exists in package.json
    if ! grep -q '"build"' package.json; then
        echo "Error: 'build' script not found in package.json. Please ensure your project has a build script defined."
        return 1
    fi

    if $verbose; then
        echo "Running command: $build_command"
        $build_command
    else
        $build_command >/dev/null 2>&1
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Build failed. Please check your project setup and try again."
        return 1
    fi

    if [[ ! -d "./$build_output_dir" ]]; then
        echo "Error: Build output directory './$build_output_dir' not found. The build may have failed or the output directory is incorrect."
        return 1
    fi

    if $verbose; then
        echo "Deploying to destination..."
        scp -r "./$build_output_dir/"* "$dest_dir" && echo "Files successfully deployed."
    else
        scp -r "./$build_output_dir/"* "$dest_dir" >/dev/null 2>&1 && echo "Files successfully deployed."
    fi
}


# tailwind setup

tailwind_setup() {
    local do_it=false
    local verbose=false

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --do-it) do_it=true ;;
            -v) verbose=true ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    if $verbose; then
        echo "Starting Tailwind CSS setup..."
    fi

    if $do_it; then
        npm install -D tailwindcss postcss autoprefixer
        npx tailwindcss init -p

        if [[ -f "tailwind.config.js" ]]; then
            # Read the file content
            content=$(cat tailwind.config.js)
            # Replace the content array
            updated_content=$(echo "$content" | awk '{gsub(/content: \[\]/, "content: [\"./index.html\", \"./src/**/*.{js,ts,jsx,tsx}\"]")}1')
            # Write back to the file
            echo "$updated_content" > tailwind.config.js
            echo "Updated tailwind.config.js"
        else
            echo "Error: tailwind.config.js not found"
            return 1
        fi

        if [[ -f "./src/index.css" ]]; then
            echo -e "\n@tailwind base;\n@tailwind components;\n@tailwind utilities;" >> ./src/index.css
            echo "Added Tailwind directives to ./src/index.css"
        else
            echo "Error: ./src/index.css not found"
            return 1
        fi
    else
        echo "To set up Tailwind CSS, run the following commands:"
        echo "npm install -D tailwindcss postcss autoprefixer"
        echo "npx tailwindcss init -p"
        echo ""
        echo "Then, update tailwind.config.js with:"
        echo 'content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"]'
        echo ""
        echo "Finally, add these directives to ./src/index.css:"
        echo "@tailwind base;"
        echo "@tailwind components;"
        echo "@tailwind utilities;"
    fi

    if $verbose; then
        echo "Tailwind CSS setup complete."
    fi
}
