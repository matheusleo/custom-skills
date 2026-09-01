#!/usr/bin/env bash
# transcribe-audio-assemblyai.sh
# Transcribes a WAV audio file using the AssemblyAI API (with speaker diarization).
# Usage: ./transcribe-audio-assemblyai.sh <input.wav> [output-dir]
#
# Prerequisites:
#   - An AssemblyAI account and API key: https://www.assemblyai.com
#   - Set the ASSEMBLYAI_API_KEY environment variable:
#       export ASSEMBLYAI_API_KEY="your-key-here"
#   - curl and jq must be installed

set -euo pipefail

INPUT="${1:-}"
OUTPUT_DIR="${2:-}"

ASSEMBLYAI_API="https://api.assemblyai.com/v2"
POLL_INTERVAL=5  # seconds between status checks

# --- Validate input ---
if [[ -z "$INPUT" ]]; then
  echo "Usage: $(basename "$0") <input.wav> [output-dir]" >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

EXT="${INPUT##*.}"
if [[ "${EXT,,}" != "wav" ]]; then
  echo "Error: expected a .wav file, got '.$EXT'. Run extract-audio.sh first." >&2
  exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$(dirname "$INPUT")"
fi

mkdir -p "$OUTPUT_DIR"

# --- Validate API key ---
if [[ -z "${ASSEMBLYAI_API_KEY:-}" ]]; then
  echo "Error: ASSEMBLYAI_API_KEY environment variable is not set." >&2
  echo "  1. Create an account at https://www.assemblyai.com" >&2
  echo "  2. Get your API key from the dashboard" >&2
  echo "  3. Export it: export ASSEMBLYAI_API_KEY=\"your-key-here\"" >&2
  exit 1
fi

# --- Check dependencies ---
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not installed." >&2
    OS="$(uname -s)"
    case "$OS" in
      Darwin) echo "Install it with: brew install $cmd" >&2 ;;
      Linux)
        if command -v apt-get &>/dev/null;   then echo "Install it with: sudo apt-get install -y $cmd" >&2
        elif command -v dnf &>/dev/null;     then echo "Install it with: sudo dnf install -y $cmd" >&2
        elif command -v yum &>/dev/null;     then echo "Install it with: sudo yum install -y $cmd" >&2
        elif command -v pacman &>/dev/null;  then echo "Install it with: sudo pacman -Sy $cmd" >&2
        elif command -v zypper &>/dev/null;  then echo "Install it with: sudo zypper install -y $cmd" >&2
        fi ;;
    esac
    exit 1
  fi
done

INPUT_BASE="$(basename "$INPUT" .wav)"
TRANSCRIPT_FILE="${OUTPUT_DIR}/${INPUT_BASE}.txt"

echo "Input:      $INPUT"
echo "Output dir: $OUTPUT_DIR"

# --- Step 1: Upload audio file ---
echo "Uploading audio to AssemblyAI..."

UPLOAD_URL=$(curl --silent --request POST \
  --url "${ASSEMBLYAI_API}/upload" \
  --header "authorization: ${ASSEMBLYAI_API_KEY}" \
  --header "content-type: application/octet-stream" \
  --data-binary "@${INPUT}" \
  | jq -r '.upload_url')

if [[ -z "$UPLOAD_URL" || "$UPLOAD_URL" == "null" ]]; then
  echo "Error: upload failed. Check your API key and network connection." >&2
  exit 1
fi

echo "Upload complete."

# --- Step 2: Submit transcription job ---
echo "Submitting transcription job (with speaker diarization)..."

JOB_ID=$(curl --silent --request POST \
  --url "${ASSEMBLYAI_API}/transcript" \
  --header "authorization: ${ASSEMBLYAI_API_KEY}" \
  --header "content-type: application/json" \
  --data "{
    \"audio_url\": \"${UPLOAD_URL}\",
    \"speaker_labels\": true,
    \"punctuate\": true,
    \"format_text\": true
  }" \
  | jq -r '.id')

if [[ -z "$JOB_ID" || "$JOB_ID" == "null" ]]; then
  echo "Error: failed to submit transcription job." >&2
  exit 1
fi

echo "Job submitted (ID: $JOB_ID). Waiting for completion..."

# --- Step 3: Poll until done ---
while true; do
  RESPONSE=$(curl --silent --request GET \
    --url "${ASSEMBLYAI_API}/transcript/${JOB_ID}" \
    --header "authorization: ${ASSEMBLYAI_API_KEY}")

  STATUS=$(echo "$RESPONSE" | jq -r '.status')

  case "$STATUS" in
    completed)
      echo "Transcription complete."
      break
      ;;
    error)
      ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error')
      echo "Error: transcription failed — $ERROR_MSG" >&2
      exit 1
      ;;
    queued|processing)
      echo "  Status: $STATUS — checking again in ${POLL_INTERVAL}s..."
      sleep "$POLL_INTERVAL"
      ;;
    *)
      echo "Error: unexpected status '$STATUS'" >&2
      exit 1
      ;;
  esac
done

# --- Step 4: Write transcript with speaker labels ---
echo "$RESPONSE" | jq -r '
  .utterances[]
  | "[\(.speaker)]: \(.text)"
' > "$TRANSCRIPT_FILE"

if [[ ! -s "$TRANSCRIPT_FILE" ]]; then
  echo "Error: transcript file is empty or was not created." >&2
  exit 1
fi

echo "Done: $TRANSCRIPT_FILE"
