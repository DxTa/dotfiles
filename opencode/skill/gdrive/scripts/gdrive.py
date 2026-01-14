#!/home/dxta/.config/opencode/venv/bin/python
"""
Google Drive Search Skill - Search and read Google Drive files via Google API

Requirements:
1. Google Cloud Project with Drive API enabled
2. OAuth credentials in ~/.config/opencode/.mcp-credentials.json (reuses 'gmail' section)
3. pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
   (installed in ~/.config/opencode/venv)
"""

import os
import sys
import json
import io
import tempfile
from pathlib import Path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaIoBaseDownload

# Configuration
CREDENTIALS_PATH = Path.home() / ".config" / "opencode" / ".mcp-credentials.json"
TOKEN_PATH = Path.home() / ".config" / "opencode" / "skill" / "gdrive" / "gdrive_token.json"
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']

# Google MIME types
GOOGLE_DOC_MIMES = {
    'application/vnd.google-apps.document': 'text/plain',
    'application/vnd.google-apps.spreadsheet': 'text/csv',
    'application/vnd.google-apps.presentation': 'text/plain',
    'application/vnd.google-apps.script': 'text/plain',
    'application/vnd.google-apps.drawing': 'text/plain',
}


def get_drive_service():
    """Get authenticated Drive API service"""
    creds = None

    # Load existing token
    if TOKEN_PATH.exists():
        creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)

    # If no valid credentials, get new ones
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not CREDENTIALS_PATH.exists():
                raise FileNotFoundError(
                    f"OAuth credentials not found at {CREDENTIALS_PATH}\n"
                    "Create ~/.config/opencode/.mcp-credentials.json with credentials"
                )

            # Load credentials from .mcp-credentials.json
            with open(CREDENTIALS_PATH, 'r') as f:
                mcp_creds = json.load(f)

            # Check for 'google' or 'gmail' section
            google_creds = mcp_creds.get('google') or mcp_creds.get('gmail')
            if not google_creds:
                raise KeyError("'google' or 'gmail' section not found in .mcp-credentials.json")

            # Create a temporary client secrets file for InstalledAppFlow
            client_secrets = {
                "installed": google_creds
            }

            with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as tmp:
                json.dump(client_secrets, tmp)
                tmp_path = tmp.name

            try:
                flow = InstalledAppFlow.from_client_secrets_file(
                    tmp_path, SCOPES
                )
                creds = flow.run_local_server(port=0)
            finally:
                os.unlink(tmp_path)

        # Save credentials for next run
        TOKEN_PATH.parent.mkdir(parents=True, exist_ok=True)
        with open(TOKEN_PATH, 'w') as token:
            token.write(creds.to_json())

    return build('drive', 'v3', credentials=creds)


def search_files(query: str, max_results: int = 10) -> list:
    """
    Search Google Drive files

    Args:
        query: Search query (will search in file names and content)
        max_results: Maximum number of results

    Returns:
        List of file dictionaries
    """
    service = get_drive_service()

    # Build search query - exclude trashed files by default
    # Use 'fullText contains' to search both names and content
    if query:
        full_query = f"fullText contains '{query}' and trashed=false"
    else:
        full_query = "trashed=false"

    results = service.files().list(
        q=full_query,
        pageSize=max_results,
        orderBy='modifiedTime desc',
        fields="files(id,name,mimeType,modifiedTime,webViewLink,owners,thumbnailLink)"
    ).execute()

    items = results.get('files', [])

    files = []
    for item in items:
        owners = item.get('owners', [])
        owner_name = owners[0].get('displayName', 'Unknown') if owners else 'Unknown'

        files.append({
            'id': item['id'],
            'name': item['name'],
            'mimeType': item['mimeType'],
            'modifiedTime': item.get('modifiedTime', ''),
            'webViewLink': item.get('webViewLink', ''),
            'owner': owner_name,
            'isGoogleDoc': item['mimeType'] in GOOGLE_DOC_MIMES
        })

    return files


def get_file_content(file_id: str) -> dict:
    """
    Get file content by ID

    Args:
        file_id: Google Drive file ID

    Returns:
        Dictionary with file metadata and content
    """
    service = get_drive_service()

    # Get file metadata
    file_metadata = service.files().get(
        fileId=file_id,
        fields="id,name,mimeType,owners,modifiedTime"
    ).execute()

    mime_type = file_metadata.get('mimeType', '')
    content = ""
    encoding = "utf-8"

    # Handle Google Docs (need to export)
    if mime_type in GOOGLE_DOC_MIMES:
        export_mime = GOOGLE_DOC_MIMES[mime_type]
        response = service.files().export(
            fileId=file_id,
            mimeType=export_mime
        ).execute()
        content = response.decode('utf-8', errors='replace')

    # Handle regular files (download)
    else:
        request = service.files().get_media(fileId=file_id)
        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while done is False:
            status, done = downloader.next_chunk()

        # Try to decode as text
        raw_bytes = fh.getvalue()
        try:
            content = raw_bytes.decode('utf-8', errors='replace')
        except UnicodeDecodeError:
            # Try other common encodings
            for enc in ['latin-1', 'iso-8859-1', 'cp1252']:
                try:
                    content = raw_bytes.decode(enc, errors='replace')
                    encoding = enc
                    break
                except:
                    continue
            else:
                content = f"[Binary file - {len(raw_bytes)} bytes]"

    return {
        'id': file_metadata['id'],
        'name': file_metadata['name'],
        'mimeType': mime_type,
        'content': content,
        'encoding': encoding,
        'modifiedTime': file_metadata.get('modifiedTime', ''),
    }


def list_recent_files(max_results: int = 10) -> list:
    """List recent files from Drive"""
    return search_files("", max_results)


# Skill interface functions
def skill_search_files(query: str, max_results: int = 10) -> str:
    """Search Google Drive and return summary"""
    try:
        files = search_files(query, max_results)

        if not files:
            return f"No files found matching: {query}"

        summary = f"Found {len(files)} files:\n\n"
        for i, file in enumerate(files, 1):
            doc_type = " [Google Doc]" if file['isGoogleDoc'] else ""
            summary += f"{i}. {file['name']}{doc_type}\n"
            summary += f"   Type: {file['mimeType']}\n"
            summary += f"   Owner: {file['owner']}\n"
            summary += f"   Modified: {file['modifiedTime']}\n"
            summary += f"   Link: {file['webViewLink']}\n\n"

        return summary

    except Exception as e:
        return f"Error searching Drive: {str(e)}"


def skill_read_file(query: str, index: int = 0) -> str:
    """Search and read specific file by index"""
    try:
        files = search_files(query, max_results=10)

        if not files or index >= len(files):
            return f"File not found (tried index {index} of {len(files)} results)"

        file_data = get_file_content(files[index]['id'])

        result = f"""File: {file_data['name']}
Type: {file_data['mimeType']}
Modified: {file_data['modifiedTime']}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{file_data['content'][:10000]}"""

        # Truncate if too long
        if len(file_data['content']) > 10000:
            result += f"\n\n[... Content truncated ({len(file_data['content'])} total bytes) ...]"

        result += "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        return result

    except Exception as e:
        return f"Error reading file: {str(e)}"


def skill_list_recent_files(count: int = 10) -> str:
    """List recent files from Drive"""
    try:
        files = list_recent_files(count)

        summary = f"Recent {len(files)} files from Drive:\n\n"
        for i, file in enumerate(files, 1):
            doc_type = " [Google Doc]" if file['isGoogleDoc'] else ""
            summary += f"{i}. {file['name']}{doc_type}\n"
            summary += f"   Modified: {file['modifiedTime']}\n\n"

        return summary

    except Exception as e:
        return f"Error listing files: {str(e)}"


def main():
    """CLI interface for testing"""
    if len(sys.argv) < 2:
        print("Usage: gdrive search|read|list [args...]")
        print("  gdrive search '<query>' [max_results]")
        print("  gdrive read '<query>' [index]")
        print("  gdrive list [count]")
        sys.exit(1)

    command = sys.argv[1]

    if command == "search":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        print(skill_search_files(query, max_results))

    elif command == "read":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        index = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        print(skill_read_file(query, index))

    elif command == "list":
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        print(skill_list_recent_files(count))

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
