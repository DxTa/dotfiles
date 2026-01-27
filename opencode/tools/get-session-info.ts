import { tool } from "@opencode-ai/plugin"
import { basename } from "path"

export default tool({
  description: "Get current opencode session ID and project slug for plan file naming. Call this at the start of any task that requires planning.",
  args: {},
  async execute(args, context) {
    const { sessionID } = context
    
    // Get project slug from current working directory
    const cwd = process.cwd()
    const dirName = basename(cwd)
    
    // Sanitize: lowercase, replace special chars with underscore
    const projectSlug = dirName
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '_')
      .replace(/^_+|_+$/g, '') // trim leading/trailing underscores
      || 'global'
    
    return JSON.stringify({
      sessionID: sessionID || 'unknown',
      projectSlug,
      planFilePrefix: `${projectSlug}_${sessionID || 'unknown'}`,
      taskPlanPath: `~/.config/opencode/plans/${projectSlug}_${sessionID}_task_plan.md`,
      notesPath: `~/.config/opencode/plans/${projectSlug}_${sessionID}_notes.md`
    }, null, 2)
  }
})
