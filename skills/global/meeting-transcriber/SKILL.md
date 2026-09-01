---
name: meeting-transcriber
description: Transcribe and summarize a meeting recording. Use when given an .mp4 or .mp3 file and asked to transcribe, summarize, or generate meeting notes.
argument-hint: "<path/to/meeting.mp4|mp3>"
disable-model-invocation: true
allowed-tools: Bash, Read, Write
---

# Meeting Transcriber

Transcribe and summarize the meeting recording at: `$ARGUMENTS`

Follow the steps below in order. Do not skip steps. Stop and report clearly if any step fails.

---

## Step 1 — Validate input

Check that an argument was provided and that the file exists:

- If `$ARGUMENTS` is empty, tell the user: _"Please provide a file path. Usage: /meeting-transcriber <path/to/file.mp4|mp3>"_ and stop.
- If the file does not exist, tell the user and stop.
- If the file extension is not `.mp4` or `.mp3` (case-insensitive), tell the user and stop.

Derive the following paths from the input file and use them consistently throughout all steps:

- `INPUT_FILE` — the original argument as-is
- `INPUT_DIR` — the directory containing the input file
- `INPUT_BASE` — filename without extension
- `WAV_FILE` — `<INPUT_DIR>/<INPUT_BASE>.wav`
- `TRANSCRIPT_FILE` — `<INPUT_DIR>/<INPUT_BASE>.txt`
- `SUMMARY_FILE` — `<INPUT_DIR>/<INPUT_BASE>-summary.md`

---

## Step 2 — Extract audio

Run the extract-audio script to produce a WAV file:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/extract-audio.sh" "$INPUT_FILE" "$WAV_FILE"
```

This converts the input to a 16kHz mono PCM WAV, which is the format required by Whisper.
If the script fails, report the error output and stop.

---

## Step 3 — Ask for language

Before transcribing, ask the user:

> _"What language is this meeting recorded in? Common options: English (en), Portuguese (pt). You can also enter any other Whisper language code (e.g. es, fr, de)."_

Wait for the user's response and store the language code (e.g. `en`, `pt`).
Use this value as the `LANGUAGE` in the next step.

---

## Step 4 — Transcribe audio

Run the transcription script with the language the user provided:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/transcribe-audio-whisper.sh" "$WAV_FILE" "$INPUT_DIR" medium "$LANGUAGE"
```

This produces `$TRANSCRIPT_FILE`.
If the script fails, report the error output and stop.

---

## Step 5 — Read the transcript

Read the full content of `$TRANSCRIPT_FILE`.

This is the raw text you will use to generate the summary. Do not truncate or summarize it yet — read it completely before proceeding.

---

## Step 6 — Generate the summary

Read the summary template at:

```
${CLAUDE_SKILL_DIR}/summary-template.md
```

Using the transcript content and the template structure, produce a complete meeting summary.

Rules for generating the summary:

- **Language:** Write the entire summary in the same language as the meeting (the language the user specified in Step 3). Section headings, labels, and all content must be in that language.
- **Metadata:** Fill in every field. Estimate duration from the transcript. List participants only if names or roles are clearly identifiable — otherwise write "not identifiable". Do not invent names.
- **TLDR:** Must be self-contained. Someone reading only the TLDR should understand what the meeting was about and what was decided.
- **Development:** Use one subsection per distinct topic discussed. Do not merge unrelated topics into a single block.
- **Conclusions vs Open Questions:** Be strict about the distinction. Only mark something as a conclusion if it was clearly resolved. If there is any doubt, put it in Open Questions.
- **TODOs:** Only include tasks that were explicitly assigned or clearly implied. Include the priority disclaimer exactly as it appears in the template — do not remove or rephrase it.
- **Inferred values:** When filling in any field that is not explicitly stated in the transcript (duration, participant names, priority, due dates), make clear in that field's value that it was inferred. For example: _"~45 min (estimated)"_ or _"not specified"_.

---

## Step 7 — Save the summary

Write the completed summary to `$SUMMARY_FILE`.

Then tell the user:

> _"Done. Summary saved to `<SUMMARY_FILE>`."_

Also print the TLDR section inline so the user gets immediate value without opening the file.
