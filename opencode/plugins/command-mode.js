/**
 * Command Mode Plugin for OpenCode
 *
 * Automatically injects `OPENCODE_COMMAND_MODE=1` into prompts
 * triggered by TUI slash commands (e.g. /push-all, /codex-status).
 *
 * This marker tells AGENTS.md to skip tier-detector, skill-suggests,
 * and sia-code unless the command template explicitly requests them.
 */

const MARKER = 'OPENCODE_COMMAND_MODE=1';
const PENDING_TTL_MS = 2000;
let pendingCommandAt = 0;

export const CommandModePlugin = async ({ client }) => {
  return {
    'tui.prompt.append': async (_input, output) => {
      // If this prompt was triggered by a slash command,
      // the tui.command.execute event fires first.
      // We check if the marker is already present to avoid duplication.
      if (output.text && !output.text.includes(MARKER)) {
        // Inject if a command was just executed (recently) or if the prompt flags it.
        const pendingFresh = pendingCommandAt > 0 && (Date.now() - pendingCommandAt) <= PENDING_TTL_MS;
        if (pendingFresh || output.command) {
          output.text = `${MARKER}\n\n${output.text}`;
          pendingCommandAt = 0;
        }
      }
    },

    event: async ({ event }) => {
      // Log command executions for debugging (visible with --print-logs)
      if (event.type === 'tui.command.execute' || event.type === 'command.executed') {
        pendingCommandAt = Date.now();
        try {
          await client.app.log({
            body: {
              service: 'command-mode',
              level: 'debug',
              message: `Command executed: ${event.properties?.command || 'unknown'}`,
            },
          });
        } catch (_error) {
          // Ignore logging failures; marker injection should still work.
        }
      }
    },
  };
};
