# Create wrapper function for oas command
oas() {
    # Port mappings
    local PORTS=(
        "localhost:3000:localhost:3000"
        "localhost:4444:localhost:4444"
        "localhost:6777:localhost:6777"
        "localhost:5432:localhost:5432"
        "localhost:27017:localhost:27017"
    )
    local REMOTE_HOST="fed"

    # Function to create tunnels
    create_tunnels() {
        echo "Creating SSH tunnels..."
        for port_mapping in "${PORTS[@]}"; do
            echo "Creating tunnel for $port_mapping"
            ssh -fNT -L "$port_mapping" "$REMOTE_HOST"
        done
        echo "All tunnels created"
    }

    # Function to list active tunnels
    list_tunnels() {
        echo "Active SSH tunnels:"
        ps aux | grep "ssh -fNT -L" | grep "$REMOTE_HOST" | grep -v grep
    }

    # Function to stop tunnels
    stop_tunnels() {
        echo "Stopping SSH tunnels..."
        ps aux | grep "ssh -fNT -L" | grep "$REMOTE_HOST" | grep -v grep | awk '{print $2}' | xargs -r kill
        echo "All tunnels stopped"
    }

    # Handle function arguments
    case "$1" in
        start)
            create_tunnels
            list_tunnels
            ;;
        stop)
            stop_tunnels
            ;;
        status)
            list_tunnels
            ;;
        *)
            echo "Usage: oas {start|stop|status}"
            return 1
            ;;
    esac
}
