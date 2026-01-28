---
name: gmail
description: Gmail search skill - Search and read Gmail messages, email content, attachments, and metadata via Gmail API
version: "1.0.0"
license: MIT
compatibility: opencode
---

# Gmail

Search and read Gmail messages including email content, attachments, and metadata.

## Overview

This skill provides comprehensive access to Gmail for:
- **Email Search**: Search using Gmail's powerful query syntax
- **Email Reading**: Get full email content including body and headers
- **Recent Emails**: List recent inbox messages
- **Meeting Invites**: Search specifically for calendar/meeting invitations

## Prerequisites

**Required**:
- Google Cloud Project with Gmail API enabled
- OAuth credentials in `~/.config/opencode/.mcp-credentials.json` (requires 'gmail' section)
- First run will prompt for OAuth authorization

**Verify Credentials**:
```bash
cat ~/.config/opencode/.mcp-credentials.json
```

If not configured:
```bash
# Enable Gmail API in Google Cloud Console:
# https://console.cloud.google.com/apis/library/gmail.googleapis.com
```

## Usage

### CLI Commands

```bash
# Search Gmail
~/.config/opencode/skills/gmail/scripts/gmail.py search '<query>' [max_results]

# Read specific email by search query
~/.config/opencode/skills/gmail/scripts/gmail.py get '<query>' [index]

# List recent emails from inbox
~/.config/opencode/skills/gmail/scripts/gmail.py list [count]

# Search for meeting invites
~/.config/opencode/skills/gmail/scripts/gmail.py invites [days_forward] [max_results]
```

### Command Examples

**Search for emails from a specific sender:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "from:john@example.com"
```

**Search for emails with specific subject:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "subject:project update"
```

**Search for emails with attachments:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "has:attachment"
```

**Search with date range:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "after:2024/12/01 before:2024/12/31"
```

**Read first matching email:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py get "important" 0
```

**List 10 most recent emails:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py list 10
```

**Search for meeting invites in next 7 days:**
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py invites 7 20
```

## Authentication

On first run, script will:
1. Open a browser window for OAuth authorization
2. Save token to `~/.config/opencode/skills/gmail/gmail_token.json`

**To re-authenticate**:
```bash
rm ~/.config/opencode/skills/gmail/gmail_token.json
~/.config/opencode/skills/gmail/scripts/gmail.py list
```

## Gmail Search Syntax

The `search` command supports Gmail's full search syntax:

| Operator | Example | Description |
|----------|----------|-------------|
| `from:` | `from:john@example.com` | From specific sender |
| `to:` | `to:team@example.com` | To specific recipient |
| `subject:` | `subject:project` | Subject contains text |
| `in:` | `in:inbox`, `in:sent` | Search specific folder |
| `is:` | `is:unread`, `is:starred` | Filter by status |
| `has:attachment` | `has:attachment` | Has attachments |
| `after:` | `after:2024/12/01` | After date |
| `before:` | `before:2024/12/31` | Before date |
| `OR` | `from:a OR from:b` | Boolean OR |
| `-` | `project -update` | Exclude word |

### Complex Examples

```bash
# Unread emails from boss with attachments
~/.config/opencode/skills/gmail/scripts/gmail.py search "is:unread from:boss@example.com has:attachment"

# Emails sent this week
~/.config/opencode/skills/gmail/scripts/gmail.py search "in:sent after:2025-01-01"

# Subject or body contains "urgent", not from newsletter
~/.config/opencode/skills/gmail/scripts/gmail.py search "urgent -from:newsletter"
```

## Output Format

**Search output:**
```
Found 3 emails:

1. From: john@example.com
   Subject: Project Update
   Date: Thu, 2 Jan 2025 10:30:45 +0000
   Preview: Hi team, I wanted to share the latest updates on our project...

2. From: support@service.com
   Subject: Your ticket has been resolved
   Date: Thu, 2 Jan 2025 09:15:20 +0000
   Preview: Thank you for contacting us. Your support ticket...
```

**Get email output:**
```
From: john@example.com
To: team@example.com
Cc: manager@example.com
Subject: Project Update
Date: Thu, 2 Jan 2025 10:30:45 +0000

Hi team,

I wanted to share the latest updates on our project.

## Progress
- Phase 1 is complete
- Phase 2 is 80% done

## Next Steps
1. Review the attached report
2. Schedule follow-up meeting
3. Update stakeholders

Best,
John
```

**List recent output:**
```
Recent 10 emails from inbox:

1. john@example.com: Project Update
   Thu, 2 Jan 2025 10:30:45 +0000
   Hi team, I wanted to share the latest updates on our project...

2. support@service.com: Your ticket has been resolved
   Thu, 2 Jan 2025 09:15:20 +0000
   Thank you for contacting us. Your support ticket...
```

**Meeting invites output:**
```
Found 3 meeting invites in next 7 days:

1. From: calendar-team@company.com
   Subject: Inviting you to: Team Standup
   Date: Thu, 2 Jan 2025 09:00:00 +0000
   Preview: *Invitation* You are invited to Team Standup on...
```

## Error Handling

1. **OAuth credentials not found**
   - **Error**: `OAuth credentials not found at ~/.config/opencode/.mcp-credentials.json`
   - **Solution**: Create credentials file with Gmail OAuth credentials

2. **API not enabled**
   - **Error**: `API is not enabled for this project`
   - **Solution**: Enable Gmail API in Google Cloud Console

3. **No emails found**
   - **Error**: `No emails found matching: <query>`
   - **Solution**: Try different search terms or check date range

4. **Email not found by index**
   - **Error**: `Email not found (tried index 1 of 1 results)`
   - **Solution**: Index is out of range, use smaller index number

## Examples

### Example 1: Search for Urgent Emails

**User Request**: "Find urgent emails I need to respond to"

**Command**:
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "urgent is:unread"
```

### Example 2: Read Specific Email

**User Request**: "Read the latest email from John"

**Command**:
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py get "from:john@example.com" 0
```

### Example 3: Check Recent Activity

**User Request**: "What's in my inbox?"

**Command**:
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py list 10
```

### Example 4: Find Meeting Invites

**User Request**: "Check if I have any meeting invites for next week"

**Command**:
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py invites 7 20
```

### Example 5: Search with Date Range

**User Request**: "Find emails about project sent last month"

**Command**:
```bash
~/.config/opencode/skills/gmail/scripts/gmail.py search "project after:2024/12/01 before:2025/01/01"
```

## Notes

- Email content is extracted from text/plain or stripped from text/html
- Special characters and encoding issues are handled with UTF-8 fallback
- Search uses Gmail's query language (same as Gmail web search)
- Snippets are truncated to ~100-150 characters
- Full email body is retrieved when using `get` command
