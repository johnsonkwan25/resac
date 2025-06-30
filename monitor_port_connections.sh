#!/bin/bash

LOG_FILE="/var/log/port_connections.log"

# Function to log the number of connections for a given port
log_port_connections() {
  local port=$1
  if [[ -z "$port" ]]; then
    echo "Error: Port number must be provided."
    return 1
  fi

  # Count listening connections on the specified port
  # We use ss -lntp to list listening TCP sockets, numeric ports, and process info.
  # Then grep for the specific port.
  # We use awk to ensure we are matching the exact port number in the correct column.
  local connection_count
  connection_count=$(ss -lntp | awk -v p=":$port" '$4 ~ p {count++} END {print count}')

  # If connection_count is empty, it means no connections were found, so set to 0
  if [[ -z "$connection_count" ]]; then
    connection_count=0
  fi

  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  echo "$timestamp - Port $port: $connection_count connections" >> "$LOG_FILE"
}

# --- Script Main Execution ---

# Ensure the log file directory exists and the script can write to it.
# This is a common point of failure for cron jobs.
# For /var/log, typically root privileges are needed.
# If running as a non-root user, you might want to change LOG_FILE path
# to somewhere the user has write permissions, e.g., "$HOME/port_connections.log"
if ! touch "$LOG_FILE" 2>/dev/null; then
  echo "Error: Cannot write to $LOG_FILE. Please check permissions or change LOG_FILE path."
  echo "Attempting to create/use log file in user's home directory: $HOME/port_connections.log"
  LOG_FILE="$HOME/port_connections.log"
  if ! touch "$LOG_FILE"; then
    echo "Error: Still cannot write to log file. Exiting."
    exit 1
  fi
  echo "Logging to $LOG_FILE"
fi


# Example usage: Log connections for port 80 and port 443
# You can call this function multiple times for different ports.
log_port_connections 80
log_port_connections 443

# Add more calls here if needed, for example:
# log_port_connections 22
# log_port_connections 3000

echo "Connection counts logged to $LOG_FILE"
