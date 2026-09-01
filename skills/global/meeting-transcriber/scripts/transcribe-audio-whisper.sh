#!/usr/bin/env bash
# transcribe-audio-whisper.sh
# Transcribes a WAV audio file using OpenAI Whisper (local).
# Usage: ./transcribe-audio-whisper.sh <input.wav> [output-dir] [model] [language]
#
# Arguments:
#   input.wav   - Path to the WAV file to transcribe
#   output-dir  - Directory to write the transcript (default: same dir as input)
#   model       - Whisper model size: tiny, base, small, medium, large (default: medium)
#   language    - Language code, e.g. en, pt (prompted interactively if omitted)
#
# Output: <input-basename>.txt in the output directory

set -euo pipefail

INPUT="${1:-}"
OUTPUT_DIR="${2:-}"
MODEL="${3:-medium}"
LANGUAGE="${4:-}"

# --- Validate input ---
if [[ -z "$INPUT" ]]; then
  echo "Usage: $(basename "$0") <input.wav> [output-dir] [model] [language]" >&2
  echo "  model options:    tiny, base, small, medium, large (default: medium)" >&2
  echo "  language options: en (English), pt (Portuguese), es (Spanish), fr (French), ..." >&2
  echo "                    See full list: https://github.com/openai/whisper#available-models-and-languages" >&2
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

# --- Ensure Python 3 is available ---
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required but not installed." >&2

  OS="$(uname -s)"
  case "$OS" in
    Darwin)  echo "Install it with: brew install python3" >&2 ;;
    Linux)
      if command -v apt-get &>/dev/null;   then echo "Install it with: sudo apt-get install -y python3 python3-pip" >&2
      elif command -v dnf &>/dev/null;     then echo "Install it with: sudo dnf install -y python3" >&2
      elif command -v yum &>/dev/null;     then echo "Install it with: sudo yum install -y python3" >&2
      elif command -v pacman &>/dev/null;  then echo "Install it with: sudo pacman -Sy python" >&2
      elif command -v zypper &>/dev/null;  then echo "Install it with: sudo zypper install -y python3" >&2
      fi ;;
  esac
  exit 1
fi

# --- Ensure pip is available ---
if ! python3 -m pip --version &>/dev/null; then
  echo "pip not found. Attempting to install..." >&2
  OS="$(uname -s)"
  case "$OS" in
    Darwin) brew install python3 ;;  # pip is bundled with brew's python3
    Linux)
      if command -v apt-get &>/dev/null;   then sudo apt-get install -y python3-pip
      elif command -v dnf &>/dev/null;     then sudo dnf install -y python3-pip
      elif command -v yum &>/dev/null;     then sudo yum install -y python3-pip
      elif command -v pacman &>/dev/null;  then sudo pacman -Sy python-pip
      elif command -v zypper &>/dev/null;  then sudo zypper install -y python3-pip
      else
        echo "Error: could not install pip automatically. Please install it manually." >&2
        exit 1
      fi ;;
    *)
      echo "Error: unsupported OS. Please install pip manually: https://pip.pypa.io" >&2
      exit 1 ;;
  esac
fi

# --- Prompt for language if not provided ---
if [[ -z "$LANGUAGE" ]]; then
  echo "What language is this meeting recorded in?"
  echo "  1) English (en)"
  echo "  2) Portuguese (pt)"
  echo "  3) Other — enter code manually (e.g. es, fr, de, it, zh, ja)"
  printf "Choice [1/2/3]: "
  read -r LANG_CHOICE

  case "$LANG_CHOICE" in
    1) LANGUAGE="en" ;;
    2) LANGUAGE="pt" ;;
    3)
      printf "Enter language code: "
      read -r LANGUAGE
      if [[ -z "$LANGUAGE" ]]; then
        echo "Error: no language code entered." >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: invalid choice '$LANG_CHOICE'." >&2
      exit 1
      ;;
  esac
fi

# --- Ensure openai-whisper is installed ---
if ! python3 -c "import whisper" &>/dev/null; then
  echo "openai-whisper not found. Installing..."
  python3 -m pip install --quiet openai-whisper
  echo "openai-whisper installed successfully."
fi

# --- Run transcription ---
INPUT_BASE="$(basename "$INPUT" .wav)"

echo "Input:      $INPUT"
echo "Output dir: $OUTPUT_DIR"
echo "Model:      $MODEL"
echo "Language:   $LANGUAGE"
echo "Transcribing... (this may take a few minutes for larger files)"

python3 -m whisper "$INPUT" \
  --model "$MODEL" \
  --language "$LANGUAGE" \
  --output_format txt \
  --output_dir "$OUTPUT_DIR" \
  --verbose False

TRANSCRIPT="${OUTPUT_DIR}/${INPUT_BASE}.txt"

if [[ ! -f "$TRANSCRIPT" ]]; then
  echo "Error: transcription completed but output file not found at $TRANSCRIPT" >&2
  exit 1
fi

echo "Done: $TRANSCRIPT"
