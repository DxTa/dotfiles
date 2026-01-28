---
name: gcal
description: Google Calendar & Meet skill - Search meetings, get event details, attendees, descriptions, and fetch Google Meet transcripts via Google Calendar API
version: "1.0.0"
license: MIT
compatibility: opencode
---

# Google Calendar & Meet

Search and manage Google Calendar events and fetch Google Meet transcripts.

## Overview

This skill provides comprehensive access to Google Calendar and Google Meet functionality:
- **Calendar Events**: List, search, and get detailed meeting information
- **Meet Transcripts**: Fetch transcripts from recorded Google Meet sessions
- **Meeting Invites**: Check both calendar and Gmail for upcoming meetings

## Prerequisites

**Required**:
- Google Cloud Project with Calendar API and Meet API enabled
- OAuth credentials in `~/.config/opencode/.mcp-credentials.json` (reuses 'gmail' section)
- First run will prompt for OAuth authorization

**Verify Credentials**:
```bash
cat ~/.config/opencode/.mcp-credentials.json
```

If not configured:
```bash
# Enable APIs in Google Cloud Console:
# - Calendar API (https://console.cloud.google.com/apis/library/calendar-json.googleapis.com)
# - Google Meet API (https://console.cloud.google.com/apis/library/meet.googleapis.com)
```

## Usage

### CLI Commands

```bash
# List meetings (default: past 30 days to next 30 days)
~/.config/opencode/skills/gcal/scripts/gcal.py list [days_past] [days_future]

# Search meetings by query
~/.config/opencode/skills/gcal/scripts/gcal.py search '<query>' [max_results]

# Get specific meeting details
~/.config/opencode/skills/gcal/scripts/gcal.py get '<query>' [index]

# List conference records (for transcripts)
~/.config/opencode/skills/gcal/scripts/gcal.py records [max_results]

# Get meeting transcript
~/.config/opencode/skills/gcal/scripts/gcal.py transcript [meeting_code] [index]

# Check all meetings (Calendar + Gmail invites)
~/.config/opencode/skills/gcal/scripts/gcal.py check [days_forward] [days_past]
```

### Command Examples

**List upcoming meetings for next 7 days:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py list 0 7
```

**Search for standup meetings:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py search "standup"
```

**Get details of first matching meeting:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py get "standup" 0
```

**List available conference records:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py records 10
```

**Get transcript by meeting code:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py transcript abc-mnop-xyz
```

**Get transcript by index:**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py transcript 0
```

**Comprehensive meeting check (Calendar + Gmail invites):**
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py check 7 1
```

## Authentication

On first run, the script will:
1. Open a browser window for OAuth authorization
2. Save token to `~/.config/opencode/skills/gcal/gcal_token.json` (Calendar API)
3. For Meet transcripts, run Meet API commands to create separate token

**To re-authenticate**:
```bash
# Delete token files and run again
rm ~/.config/opencode/skills/gcal/gcal_token.json
rm ~/.config/opencode/skills/gcal/gcal_meet_token.json
~/.config/opencode/skills/gcal/scripts/gcal.py list
```

## Output Format

**List output:**
```
Found 5 meetings:

1. Team Standup
   Start: 2025-01-02T09:00:00Z
   End: 2025-01-02T09:30:00Z
   Meet: https://meet.google.com/abc-mnop-xyz
   Attendees: user1@example.com, user2@example.com

2. Project Review
   Start: 2025-01-02T14:00:00Z
   ...
```

**Transcript output:**
```
Transcript for: abc-mnop-xyz
Meeting Code: abc-mnop-xyz
Start Time: 2025-01-02T09:00:00Z
Entries: 45

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[John Doe @ 2025-01-02T09:01:23Z]
Good morning everyone, let's get started

[Jane Smith @ 2025-01-02T09:01:45Z]
I'll start with the updates

...
```

## Error Handling

1. **OAuth credentials not found**
   - **Error**: `OAuth credentials not found at ~/.config/opencode/.mcp-credentials.json`
   - **Solution**: Create credentials file with Gmail/Google OAuth credentials

2. **API not enabled**
   - **Error**: `API is not enabled for this project`
   - **Solution**: Enable Calendar API and/or Meet API in Google Cloud Console

3. **Token expired**
   - **Error**: `Token has been revoked or expired`
   - **Solution**: Delete token files and re-run to re-authenticate

4. **No conference records**
   - **Error**: `No conference records found`
   - **Solution**: Transcripts are only available if meeting recording was enabled

## Examples

### Example 1: Daily Meeting Check

**User Request**: "What meetings do I have today?"

**Command**:
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py check 0 0
```

**Output**:
```
📅 Calendar Events (3 found):

1. Daily Standup
   Start: 2025-01-02T09:00:00Z
   End: 2025-01-02T09:30:00Z
   Meet: https://meet.google.com/abc-mnop-xyz
   Attendees: team@example.com

2. Client Call
   Start: 2025-01-02T11:00:00Z
   ...

📧 Email Invites: None found
```

### Example 2: Fetch Meeting Transcript

**User Request**: "Get the transcript from yesterday's standup"

**Command**:
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py records 10
# Then use meeting code from output
~/.config/opencode/skills/gcal/scripts/gcal.py transcript abc-mnop-xyz
```

### Example 3: Search Past Meetings

**User Request**: "Find meetings about the Q1 planning from last month"

**Command**:
```bash
~/.config/opencode/skills/gcal/scripts/gcal.py search "Q1 planning"
```
