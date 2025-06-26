#!/bin/bash

# This script will display a loading animation using Braille dot characters.

# Braille dot characters for the animation
braille_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Function to display the loading animation
display_animation() {
  local message="$1"
  local delay="$2"
  local pid="$3"
  local i=0

  echo -n "$message "
  while ps -p $pid > /dev/null; do
    echo -ne "\r$message ${braille_chars[i]}"
    i=$(( (i + 1) % ${#braille_chars[@]} ))
    sleep "$delay"
  done
  echo -ne "\r$message Done!  \n"
}

# Example usage:
# sleep 5 &  # Start a background process
# display_animation "Loading..." 0.1 $! # Display animation while the process runs
# echo "Process complete!"
