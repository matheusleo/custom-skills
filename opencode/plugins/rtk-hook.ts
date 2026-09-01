/**
 * rtk-hook — RTK (Rust Token Killer) adapter for OpenCode.
 *
 * Mirrors the Claude Code `rtk hook claude` PreToolUse behaviour: before a
 * Bash tool call runs, ask rtk whether the command would be rewritten into a
 * token-cheaper form (e.g. `git status` -> `rtk git status`) and apply it.
 * rtk itself compresses the command's output; this plugin only rewrites the
 * command, using `rtk hook check` (the dry-run rewrite engine).
 *
 * Failures are non-fatal: if rtk is missing, times out, or declines to
 * rewrite, the original command is left untouched.
 */
import { spawn } from "node:child_process"
import type { Plugin } from "@opencode-ai/plugin"

const RTK_TIMEOUT_MS = 2000

function rtkCheck(command: string): Promise<string> {
  return new Promise((resolve) => {
    let out = ""
    let settled = false
    const finish = (v: string) => {
      if (!settled) {
        settled = true
        resolve(v)
      }
    }
    try {
      const proc = spawn("rtk", ["hook", "check", "--agent", "claude", command], {
        stdio: ["ignore", "pipe", "ignore"],
      })
      const timer = setTimeout(() => {
        try {
          proc.kill("SIGKILL")
        } catch {}
        finish("")
      }, RTK_TIMEOUT_MS)
      proc.stdout?.on("data", (d) => {
        out += d.toString()
      })
      proc.on("error", () => {
        clearTimeout(timer)
        finish("")
      })
      proc.on("close", () => {
        clearTimeout(timer)
        finish(out)
      })
    } catch {
      finish("")
    }
  })
}

async function rtkRewrite(command: string): Promise<string> {
  const trimmed = command.trim()
  if (!trimmed) return command
  // Don't double-wrap rtk/gain invocations.
  if (/^(rtk|gain)\b/.test(trimmed)) return command
  const rewritten = (await rtkCheck(trimmed)).trim()
  if (!rewritten) return command
  if (rewritten.startsWith("No rewrite for:")) return command
  // Accept only a single-line rtk-/gain-prefixed result.
  if (!rewritten.includes("\n") && /^(rtk|gain)\s/.test(rewritten)) return rewritten
  return command
}

export const RtkHookPlugin: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool?.toLowerCase() !== "bash") return
      const args = output.args
      if (!args || typeof args !== "object" || typeof args.command !== "string") return
      const next = await rtkRewrite(args.command)
      if (next !== args.command) args.command = next
    },
  }
}

export default RtkHookPlugin
