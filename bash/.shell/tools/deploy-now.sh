#!/usr/bin/env bash
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
