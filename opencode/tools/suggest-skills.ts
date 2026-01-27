import { tool } from "@opencode-ai/plugin";
import { readFileSync } from "fs";
import { join } from "path";

interface SkillData {
  type: string;
  enforcement: string;
  priority: string;
  source: string;
  description: string;
  promptTriggers?: {
    keywords?: string[];
    intentPatterns?: string[];
  };
}

interface SkillRulesData {
  version: string;
  description: string;
  skills: Record<string, SkillData>;
}

export default tool({
  description: "Analyze text and return matching skills from skill-rules.json based on keywords and intent patterns. Returns JSON array of matched skills with metadata.",
  args: {
    text: tool.schema.string().describe("The user message or conversation context to analyze for skill matching"),
    maxResults: tool.schema.number().optional().describe("Maximum number of skills to return (default: 10)"),
  },
  async execute(args) {
    try {
      // Load skill-rules.json
      const configDir = process.env.HOME + "/.config/opencode";
      const rulesPath = join(configDir, "skill-rules.json");
      const rulesContent = readFileSync(rulesPath, "utf-8");
      const skillRulesData: SkillRulesData = JSON.parse(rulesContent);

      // Helper functions for matching
      function normalizeText(text: string): string {
        return text.toLowerCase().trim();
      }

      function matchKeywords(text: string, keywords: string[]): boolean {
        const normalizedText = normalizeText(text);
        return keywords.some((keyword) =>
          normalizedText.includes(keyword.toLowerCase())
        );
      }

      function matchIntents(text: string, intents: string[]): boolean {
        return intents.some((intent) => {
          try {
            const regex = new RegExp(intent, "i");
            return regex.test(text);
          } catch {
            return false;
          }
        });
      }

      function getMatchedKeywords(text: string, keywords: string[]): string[] {
        const normalizedText = normalizeText(text);
        return keywords.filter((keyword) =>
          normalizedText.includes(keyword.toLowerCase())
        );
      }

      // Find matching skills
      const matchedSkills: Array<{
        name: string;
        description: string;
        priority: string;
        source: string;
        matchType: string;
        matchedKeywords: string[];
      }> = [];

      for (const [skillName, skillData] of Object.entries(skillRulesData.skills)) {
        const triggers = skillData.promptTriggers || {};
        const keywords = triggers.keywords || [];
        const intents = triggers.intentPatterns || [];

        const keywordMatch = keywords.length > 0 ? matchKeywords(args.text, keywords) : false;
        const intentMatch = intents.length > 0 ? matchIntents(args.text, intents) : false;

        if (keywordMatch || intentMatch) {
          matchedSkills.push({
            name: skillName,
            description: skillData.description,
            priority: skillData.priority,
            source: skillData.source,
            matchType: keywordMatch ? "keyword" : "intent",
            matchedKeywords: keywordMatch ? getMatchedKeywords(args.text, keywords) : [],
          });
        }
      }

      // Sort by priority
      const priorityOrder: Record<string, number> = {
        critical: 0,
        high: 1,
        medium: 2,
        low: 3,
      };

      const sortedSkills = matchedSkills.sort((a, b) => {
        return (priorityOrder[a.priority] || 999) - (priorityOrder[b.priority] || 999);
      });

      // Limit results
      const maxResults = args.maxResults || 10;
      const limitedSkills = sortedSkills.slice(0, maxResults);

      // Return as formatted JSON
      return JSON.stringify(
        {
          totalMatches: matchedSkills.length,
          returned: limitedSkills.length,
          skills: limitedSkills,
        },
        null,
        2
      );
    } catch (error) {
      return JSON.stringify({
        error: "Failed to load or process skill-rules.json",
        message: error instanceof Error ? error.message : String(error),
        totalMatches: 0,
        returned: 0,
        skills: [],
      });
    }
  },
});
