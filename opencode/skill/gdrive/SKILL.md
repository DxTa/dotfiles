---
name: gdrive
description: Google Drive search skill - Search and read Google Drive files including Docs, Sheets, Slides, PDFs, and other file types via Google Drive API
version: "1.0.0"
license: MIT
compatibility: opencode
---

# Google Drive

Search and read Google Drive files including Docs, Sheets, Slides, and other file types.

## Overview

This skill provides access to Google Drive for:
- **File Search**: Search by name or content across all Drive files
- **File Reading**: Read content from Google Docs, Sheets, Slides, PDFs, text files
- **Recent Files**: List recently modified files
- **File Metadata**: Get owner, modified time, file type, and web links

## Prerequisites

**Required**:
- Google Cloud Project with Drive API enabled
- OAuth credentials in `~/.config/opencode/.mcp-credentials.json` (reuses 'gmail' or 'google' section)
- First run will prompt for OAuth authorization

**Verify Credentials**:
```bash
cat ~/.config/opencode/.mcp-credentials.json
```

If not configured:
```bash
# Enable Drive API in Google Cloud Console:
# https://console.cloud.google.com/apis/library/drive.googleapis.com
```

## Usage

### CLI Commands

```bash
# Search Google Drive
~/.config/opencode/skill/gdrive/scripts/gdrive.py search '<query>' [max_results]

# Read specific file by search query
~/.config/opencode/skill/gdrive/scripts/gdrive.py read '<query>' [index]

# List recent files
~/.config/opencode/skill/gdrive/scripts/gdrive.py list [count]
```

### Command Examples

**Search for project files:**
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py search "project plan"
```

**Read first matching file:**
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py read "quarterly report" 0
```

**List 20 most recent files:**
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py list 20
```

## Authentication

On first run, script will:
1. Open a browser window for OAuth authorization
2. Save token to `~/.config/opencode/skill/gdrive/gdrive_token.json`

**To re-authenticate**:
```bash
rm ~/.config/opencode/skill/gdrive/gdrive_token.json
~/.config/opencode/skill/gdrive/scripts/gdrive.py list
```

## Supported File Types

| File Type | Can Read | Notes |
|-----------|-----------|--------|
| Google Docs | ✅ Yes | Exported as plain text |
| Google Sheets | ✅ Yes | Exported as CSV |
| Google Slides | ✅ Yes | Exported as plain text |
| Google Scripts | ✅ Yes | Exported as plain text |
| Google Drawings | ✅ Yes | Exported as plain text |
| Text files | ✅ Yes | Direct download |
| PDF | ✅ Yes | Text extraction (if possible) |
| Images | ❌ No | Returns "[Binary file]" |
| Binaries | ❌ No | Returns "[Binary file]" |

## Output Format

**Search output:**
```
Found 5 files:

1. Project Plan.docx [Google Doc]
   Type: application/vnd.google-apps.document
   Owner: John Doe
   Modified: 2024-12-15T10:30:45Z
   Link: https://drive.google.com/file/d/abc123/view

2. Meeting Notes [Google Doc]
   Type: application/vnd.google-apps.document
   Owner: Jane Smith
   Modified: 2024-12-14T16:20:30Z
   Link: https://drive.google.com/file/d/def456/view
```

**Read output:**
```
File: Project Plan.docx
Type: application/vnd.google-apps.document
Modified: 2024-12-15T10:30:45Z

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Project Plan

## Overview
This document outlines the project plan for Q1 2025...

## Milestones
1. January: Requirements gathering
2. February: Design phase
3. March: Development sprint
...
```

**List recent files output:**
```
Recent 10 files from Drive:

1. Budget 2025.xlsx [Google Sheet]
   Modified: 2024-12-20T14:15:00Z

2. Presentation.pptx [Google Slides]
   Modified: 2024-12-20T13:45:30Z

3. Meeting notes.docx [Google Doc]
   Modified: 2024-12-20T11:30:00Z
...
```

## Error Handling

1. **OAuth credentials not found**
   - **Error**: `OAuth credentials not found at ~/.config/opencode/.mcp-credentials.json`
   - **Solution**: Create credentials file with Gmail/Google OAuth credentials

2. **API not enabled**
   - **Error**: `API is not enabled for this project`
   - **Solution**: Enable Drive API in Google Cloud Console

3. **File not found**
   - **Error**: `File not found (tried index 0 of 0 results)`
   - **Solution**: Search query returned no results, try different keywords

4. **Binary file**
   - **Error**: `[Binary file - 12345 bytes]`
   - **Solution**: This file type cannot be read as text (e.g., images, executables)

5. **Permission denied**
   - **Error**: `Insufficient permission`
   - **Solution**: You don't have read access to this file

## Examples

### Example 1: Find Project Documentation

**User Request**: "Search for project documentation in Drive"

**Command**:
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py search "project documentation"
```

### Example 2: Read a Specific Document

**User Request**: "Read the quarterly report I just created"

**Command**:
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py read "quarterly report" 0
```

### Example 3: Check Recent Activity

**User Request**: "What files have I modified recently?"

**Command**:
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py list 10
```

### Example 4: Search Multiple Keywords

**User Request**: "Find all files related to budget"

**Command**:
```bash
~/.config/opencode/skill/gdrive/scripts/gdrive.py search "budget"
```

## Notes

- Search uses Google Drive's `fullText` operator, which searches both file names and content
- Trashed files are excluded from search results by default
- Google Docs are exported as text format for reading (original formatting is lost)
- For Google Sheets, CSV export includes row/column structure but not formulas
- Content is limited to first 10,000 characters for readability
