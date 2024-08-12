#!/usr/bin/env bash
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
