#!/usr/bin/env bash
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
