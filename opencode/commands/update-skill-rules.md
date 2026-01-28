---
description: Update skill-rules.json to keep skill activation triggers current with installed plugins and local skills
---

# Update Skill Rules Command

You are tasked with updating the `~/.config/opencode/skills/skill-rules.json` file to keep skill activation triggers current with installed plugins AND local skills.

## How Skill Activation Works

The `skill-rules.json` file is read by the `~/.config/opencode/hooks/skill-activation-prompt.ts` hook on every user prompt. The hook matches the prompt against `promptTriggers.keywords` and `promptTriggers.intentPatterns` to suggest relevant skills.

```
Marketplace Plugins ──┐
                      ├──► /update-skill-rules ──► skill-rules.json ──► hook reads ──► skill suggestions
Local Skills ─────────┘
```

## Your Task

1. **Discover Current State**
   - Read the existing `~/.config/opencode/skills/skill-rules.json` file
   - **Marketplace Plugins:**
     - List all installed plugins based on ~/.config/opencode/plugins/installed_plugins.json
     - Cross check with ~/.config/opencode/plugins/marketplaces/*
     - Read `~/.config/opencode/settings.json` to see enabled plugins
   - **Local Skills:**
     - List all directories in `~/.config/opencode/skills/`
     - For each directory, check if `SKILL.md` exists
     - Parse YAML frontmatter for: name, description, version, license
     - Note skill capabilities from content

2. **Identify Changes**
   - Compare existing skill rules with currently installed/enabled plugins
   - Compare existing skill rules with local skills in `~/.config/opencode/skills/`
   - Identify NEW plugins/skills that need skill rules
   - Identify REMOVED plugins/skills that should be cleaned up
   - Check for plugins/skills with OUTDATED configurations

3. **Gather Information** (for new/updated)

   **For marketplace plugins:**
   - Explore the plugin directory structure
   - Read README.md or documentation files
   - Identify key capabilities, commands, and agents
   - Extract relevant keywords and trigger patterns

   **For local skills:**
   - Read `~/.config/opencode/skills/{skill-name}/SKILL.md`
   - Parse YAML frontmatter for metadata
   - Scan skill content for: technologies, frameworks, tools mentioned
   - Check for `references/` subdirectory and extract topics
   - Check for `scripts/` subdirectory and identify automation capabilities

4. **Update Strategy**
   Present options to the user:
   - **Full Regeneration**: Regenerate entire skill-rules.json from scratch
   - **Incremental Update**: Add only new plugins, keep existing customizations
   - **Merge Custom Skills**: Preserve any custom user-defined skills not tied to plugins
   - **Clean Removed**: Remove skills for uninstalled plugins

5. **Generate Updated Configuration**
   For each skill, ensure:
   - `type`: "domain" or "guardrail" (appropriate for the plugin)
   - `enforcement`: "suggest", "block", or "warn"
   - `priority`: "critical", "high", "medium", or "low"
   - `description`: Clear explanation of plugin purpose
   - `promptTriggers`:
     - `keywords`: 10-20 relevant terms
     - `intentPatterns`: 5-10 regex patterns for intent matching
   - `fileTriggers` (if applicable):
     - `pathPatterns`: File path patterns
     - `contentPatterns`: Code content patterns

6. **Validation**
   - Ensure JSON is valid and properly formatted
   - Verify all regex patterns are properly escaped
   - Check that skill names match plugin/command names
   - Confirm no duplicate keywords across skills

7. **Present Changes**
   Before updating, show:
   - Summary of changes (added, removed, updated skills)
   - New trigger keywords for each modified skill
   - Ask for user confirmation

8. **Backup and Update**
   - Create backup: `skill-rules.json.backup.TIMESTAMP`
   - Write updated `skill-rules.json`
   - Verify the file was written correctly

## Important Guidelines

- **Preserve Customizations**: If user has custom skills or modified triggers, preserve them
- **Dual Sources**: Handle both marketplace plugins AND local skills from `~/.config/opencode/skills/`
- **Non-Blocking**: Default to `enforcement: "suggest"` for most skills
- **High Priority**: Use `priority: "high"` for important domain skills
- **Comprehensive Triggers**: Include both broad and specific keywords/patterns
- **File Context**: Add `fileTriggers` when skills are relevant to specific file types
- **Source Tracking**: Track `source: "marketplace"` vs `source: "local"` for each skill

## Example Output Format

After analysis, present:

```
📊 SKILL RULES UPDATE ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━

MARKETPLACE PLUGINS:
  Installed: 11
  Enabled: 11
  With Rules: 10

LOCAL SKILLS:
  Directories: 13
  With SKILL.md: 12
  With Rules: 8

📥 NEW (need skill rules):
  Plugins:
    → plugin-name-1
    → plugin-name-2
  Local Skills:
    → chrome-devtools
    → media-processing

🗑️ REMOVED (clean up rules):
  Plugins:
    → old-plugin-name
  Local Skills:
    → deprecated-skill

✏️ CUSTOM SKILLS (preserve):
  → custom-skill-1

━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommended Action: [Full Regeneration | Incremental Update]

Proceed? [Show me the changes first | Yes, update now]
```

## User Preferences

Check if user wants to:
- Add custom skill rules not tied to plugins
- Modify enforcement levels (suggest vs block)
- Adjust priority levels
- Add project-specific triggers
- Enable/disable file triggers for certain skills

## Local Skill Rule Generation

When generating rules for local skills from `~/.config/opencode/skills/`:

1. **Parse SKILL.md Frontmatter**
   ```yaml
   ---
   name: skill-name
   description: Skill description for trigger matching
   version: 1.0.0
   ---
   ```

2. **Extract Keywords From:**
   - Skill description in frontmatter
   - H1/H2 headers in SKILL.md content
   - File names in `references/` directory (if exists)
   - Technology/framework mentions in content (React, Next.js, PostgreSQL, etc.)
   - Tool names mentioned (ffmpeg, puppeteer, imagemagick, etc.)

3. **Generate File Triggers From:**
   - Technologies mentioned (e.g., `.py` files for Python skills)
   - Framework patterns (e.g., `next.config.*` for Next.js)
   - Tool-specific files (e.g., `docker-compose.yml` for DevOps)
   - Database files (e.g., `*.sql`, `prisma/schema.prisma`)

4. **Default Configuration for Local Skills:**
   ```json
   {
     "type": "domain",
     "enforcement": "suggest",
     "priority": "medium",
     "source": "local",
     "promptTriggers": {
       "keywords": ["extracted", "from", "skill", "content"],
       "intentPatterns": ["regex patterns for common intents"]
     },
     "fileTriggers": {
       "pathPatterns": ["relevant file patterns"],
       "contentPatterns": ["code patterns"]
     }
   }
   ```

5. **Priority Guidelines for Local Skills:**
   - `"high"`: Core development skills (backend, frontend, databases)
   - `"medium"`: Utility skills (media-processing, document-skills)
   - `"low"`: Niche or specialized skills

## skill-rules.json Schema

The hook expects this schema:

```typescript
interface SkillRules {
    version: string;
    skills: Record<string, SkillRule>;
}

interface SkillRule {
    type: "guardrail" | "domain";
    enforcement: "block" | "suggest" | "warn";
    priority: "critical" | "high" | "medium" | "low";
    source?: "marketplace" | "local" | "custom";  // Track origin
    promptTriggers?: {
        keywords?: string[];        // Case-insensitive substring match
        intentPatterns?: string[];  // Regex patterns
    };
    fileTriggers?: {
        pathPatterns?: string[];    // Glob patterns for file paths
        contentPatterns?: string[]; // Regex patterns for file content
    };
}
```

Start by analyzing the current state and presenting options to the user.
