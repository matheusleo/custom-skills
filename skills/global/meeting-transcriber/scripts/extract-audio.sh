#!/usr/bin/env bash
# extract-audio.sh
# Extracts or converts audio from MP4 or MP3 to WAV (16kHz mono PCM)
# Usage: ./extract-audio.sh <input-file> [output-file]
#
# Output defaults to <input-basename>.wav in the same directory as the input.
# 16kHz mono is the recommended format for most speech transcription tools.

set -euo pipefail

INPUT="${1:-}"
OUTPUT="${2:-}"

# --- Validate input ---
if [[ -z "$INPUT" ]]; then
  echo "Usage: $(basename "$0") <input.mp4|input.mp3> [output.wav]" >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

EXT="${INPUT##*.}"
EXT_LOWER="${EXT,,}"

if [[ "$EXT_LOWER" != "mp4" && "$EXT_LOWER" != "mp3" ]]; then
  echo "Error: unsupported format '.$EXT'. Only .mp4 and .mp3 are accepted." >&2
  exit 1
fi

# --- Check ffmpeg, install if missing ---
if ! command -v ffmpeg &>/dev/null; then
  echo "ffmpeg not found. Attempting to install..."

  OS="$(uname -s)"

  case "$OS" in
    Darwin)
      if command -v brew &>/dev/null; then
        brew install ffmpeg
      else
        echo "Error: Homebrew not found. Install it from https://brew.sh, then run: brew install ffmpeg" >&2
        exit 1
      fi
      ;;
    Linux)
      if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y ffmpeg
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y ffmpeg
      elif command -v yum &>/dev/null; then
        sudo yum install -y ffmpeg
      elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm ffmpeg
      elif command -v zypper &>/dev/null; then
        sudo zypper install -y ffmpeg
      else
        echo "Error: could not detect a supported package manager (apt, dnf, yum, pacman, zypper)." >&2
        echo "Please install ffmpeg manually: https://ffmpeg.org/download.html" >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: unsupported OS '$OS'. Please install ffmpeg manually: https://ffmpeg.org/download.html" >&2
      exit 1
      ;;
  esac

  # Verify installation succeeded
  if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg installation failed. Please install it manually: https://ffmpeg.org/download.html" >&2
    exit 1
  fi

  echo "ffmpeg installed successfully."
fi

# --- Determine output path ---
if [[ -z "$OUTPUT" ]]; then
  INPUT_DIR="$(dirname "$INPUT")"
  INPUT_BASE="$(basename "$INPUT" ".$EXT")"
  OUTPUT="${INPUT_DIR}/${INPUT_BASE}.wav"
fi

# --- Extract / convert ---
echo "Input:  $INPUT"
echo "Output: $OUTPUT"

ffmpeg -y \
  -i "$INPUT" \
  -vn \
  -acodec pcm_s16le \
  -ar 16000 \
  -ac 1 \
  "$OUTPUT" \
  -loglevel error \
  -stats

echo "Done: $OUTPUT"
