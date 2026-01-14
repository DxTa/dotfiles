#!/home/dxta/.config/opencode/venv/bin/python
"""
Gmail Search Skill - Search and read Gmail via Google API

Requirements:
1. Google Cloud Project with Gmail API enabled
2. OAuth credentials in ~/.config/opencode/.mcp-credentials.json
3. pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
   (installed in ~/.config/opencode/venv)
"""

import os
import sys
import json
import base64
import email
import tempfile
import re
from datetime import datetime, timedelta
from email.header import decode_header
from pathlib import Path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Configuration
CREDENTIALS_PATH = Path.home() / ".config" / "opencode" / ".mcp-credentials.json"
TOKEN_PATH = (
    Path.home() / ".config" / "opencode" / "skill" / "gmail" / "gmail_token.json"
)
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]


def get_gmail_service():
    """Get authenticated Gmail API service"""
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
                    "Create ~/.config/opencode/.mcp-credentials.json with Gmail credentials"
                )

            # Load credentials from .mcp-credentials.json
            with open(CREDENTIALS_PATH, "r") as f:
                mcp_creds = json.load(f)

            if "gmail" not in mcp_creds:
                raise KeyError("'gmail' section not found in .mcp-credentials.json")

            # Create a temporary client secrets file for InstalledAppFlow
            client_secrets = {"installed": mcp_creds["gmail"]}

            with tempfile.NamedTemporaryFile(
                mode="w", suffix=".json", delete=False
            ) as tmp:
                json.dump(client_secrets, tmp)
                tmp_path = tmp.name

            try:
                flow = InstalledAppFlow.from_client_secrets_file(tmp_path, SCOPES)
                creds = flow.run_local_server(port=0)
            finally:
                os.unlink(tmp_path)

        # Save credentials for next run
        TOKEN_PATH.parent.mkdir(parents=True, exist_ok=True)
        with open(TOKEN_PATH, "w") as token:
            token.write(creds.to_json())

    return build("gmail", "v1", credentials=creds)


def decode_mime_words(header_value):
    """Decode email header"""
    if not header_value:
        return ""
    decoded = []
    for content, encoding in decode_header(header_value):
        if isinstance(content, bytes):
            decoded.append(content.decode(encoding or "utf-8", errors="replace"))
        else:
            decoded.append(str(content))
    return "".join(decoded)


def get_message_body(service, user_id, msg_id):
    """Extract message body from Gmail API response"""
    message = (
        service.users()
        .messages()
        .get(userId=user_id, id=msg_id, format="raw")
        .execute()
    )

    # Decode raw message
    msg_raw = base64.urlsafe_b64decode(message["raw"])
    msg = email.message_from_bytes(msg_raw)

    # Extract body
    body = ""
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            if content_type == "text/plain":
                payload = part.get_payload(decode=True)
                charset = part.get_content_charset() or "utf-8"
                body = payload.decode(charset, errors="replace")
                break
            elif content_type == "text/html" and not body:
                # Strip HTML
                payload = part.get_payload(decode=True)
                charset = part.get_content_charset() or "utf-8"
                html = payload.decode(charset, errors="replace")
                body = re.sub("<[^<]+?>", "", html)
    else:
        payload = msg.get_payload(decode=True)
        charset = msg.get_content_charset() or "utf-8"
        body = payload.decode(charset, errors="replace")

    return body


def search_emails(query: str, max_results: int = 10) -> list:
    """
    Search Gmail with query string

    Args:
        query: Gmail search query (same syntax as Gmail web search)
        max_results: Maximum number of results

    Returns:
        List of email dictionaries
    """
    service = get_gmail_service()
    results = (
        service.users()
        .messages()
        .list(userId="me", q=query, maxResults=max_results)
        .execute()
    )

    messages = results.get("messages", [])
    emails = []

    for msg in messages:
        msg_detail = (
            service.users()
            .messages()
            .get(
                userId="me",
                id=msg["id"],
                format="metadata",
                metadataHeaders=["From", "To", "Subject", "Date"],
            )
            .execute()
        )

        headers = {
            h["name"]: h["value"] for h in msg_detail["payload"].get("headers", [])
        }

        emails.append(
            {
                "id": msg["id"],
                "from": decode_mime_words(headers.get("From", "")),
                "to": decode_mime_words(headers.get("To", "")),
                "subject": decode_mime_words(headers.get("Subject", "")),
                "date": headers.get("Date", ""),
                "snippet": msg_detail.get("snippet", ""),
            }
        )

    return emails


def get_email(message_id: str) -> dict:
    """
    Get full email content by ID

    Args:
        message_id: Gmail message ID

    Returns:
        Email dictionary with full body
    """
    service = get_gmail_service()

    msg_detail = (
        service.users()
        .messages()
        .get(
            userId="me",
            id=message_id,
            format="metadata",
            metadataHeaders=["From", "To", "Cc", "Subject", "Date"],
        )
        .execute()
    )

    headers = {h["name"]: h["value"] for h in msg_detail["payload"].get("headers", [])}

    body = get_message_body(service, "me", message_id)

    return {
        "id": message_id,
        "from": decode_mime_words(headers.get("From", "")),
        "to": decode_mime_words(headers.get("To", "")),
        "cc": decode_mime_words(headers.get("Cc", "")),
        "subject": decode_mime_words(headers.get("Subject", "")),
        "date": headers.get("Date", ""),
        "body": body,
    }


def list_recent_emails(max_results: int = 10) -> list:
    """List recent emails from inbox"""
    service = get_gmail_service()
    results = (
        service.users()
        .messages()
        .list(userId="me", labelIds=["INBOX"], maxResults=max_results)
        .execute()
    )

    messages = results.get("messages", [])
    emails = []

    for msg in messages:
        msg_detail = (
            service.users()
            .messages()
            .get(
                userId="me",
                id=msg["id"],
                format="metadata",
                metadataHeaders=["From", "Subject", "Date"],
            )
            .execute()
        )

        headers = {
            h["name"]: h["value"] for h in msg_detail["payload"].get("headers", [])
        }

        emails.append(
            {
                "id": msg["id"],
                "from": decode_mime_words(headers.get("From", "")),
                "subject": decode_mime_words(headers.get("Subject", "")),
                "date": headers.get("Date", ""),
                "snippet": msg_detail.get("snippet", ""),
            }
        )

    return emails


# Skill interface functions
def skill_search_email(query: str, max_results: int = 5) -> str:
    """Search Gmail and return summary"""
    try:
        emails = search_emails(query, max_results)

        if not emails:
            return f"No emails found matching: {query}"

        summary = f"Found {len(emails)} emails:\n\n"
        for i, email in enumerate(emails, 1):
            summary += f"{i}. From: {email['from']}\n"
            summary += f"   Subject: {email['subject']}\n"
            summary += f"   Date: {email['date']}\n"
            summary += f"   Preview: {email['snippet'][:150]}...\n\n"

        return summary

    except Exception as e:
        return f"Error searching Gmail: {str(e)}"


def skill_get_email(query: str, index: int = 0) -> str:
    """Search and get specific email by index"""
    try:
        emails = search_emails(query, max_results=10)

        if not emails or index >= len(emails):
            return f"Email not found (tried index {index} of {len(emails)} results)"

        email = get_email(emails[index]["id"])

        return f"""From: {email["from"]}
To: {email["to"]}
Cc: {email["cc"]}
Subject: {email["subject"]}
Date: {email["date"]}

{email["body"]}
"""

    except Exception as e:
        return f"Error retrieving email: {str(e)}"


def skill_list_recent_emails(count: int = 10) -> str:
    """List recent emails from inbox"""
    try:
        emails = list_recent_emails(count)

        summary = f"Recent {len(emails)} emails from inbox:\n\n"
        for i, email in enumerate(emails, 1):
            summary += f"{i}. {email['from']}: {email['subject']}\n"
            summary += f"   {email['snippet'][:100]}...\n\n"

        return summary

    except Exception as e:
        return f"Error listing emails: {str(e)}"


def skill_search_meeting_invites(days_forward: int = 7, max_results: int = 20) -> str:
    """
    Search Gmail for meeting invites in the next N days

    Args:
        days_forward: Number of days ahead to search
        max_results: Maximum number of results

    Returns:
        Formatted summary of meeting invites
    """
    try:
        from datetime import datetime

        # Build date range query
        today = datetime.now()
        future_date = today + timedelta(days=days_forward)

        # Gmail search for calendar invites using method:invite operator
        # and date range filters
        query = f"after:{today.strftime('%Y/%m/%d')} "
        query += f"before:{future_date.strftime('%Y/%m/%d')} "
        query += '(method:invite OR "calendar invitation" OR "meeting invite" OR "invite" OR "invitation")'

        emails = search_emails(query, max_results)

        if not emails:
            return f"No meeting invites found in the next {days_forward} days"

        summary = (
            f"Found {len(emails)} meeting invites in the next {days_forward} days:\n\n"
        )
        for i, email_data in enumerate(emails, 1):
            summary += f"{i}. From: {email_data['from']}\n"
            summary += f"   Subject: {email_data['subject']}\n"
            summary += f"   Date: {email_data['date']}\n"
            summary += f"   Preview: {email_data['snippet'][:150]}...\n\n"

        return summary

    except Exception as e:
        return f"Error searching meeting invites: {str(e)}"


def main():
    """CLI interface for testing"""
    if len(sys.argv) < 2:
        print("Usage: gmail search|get|list|invites [args...]")
        print("  gmail search '<query>' [max_results]")
        print("  gmail get '<query>' [index]")
        print("  gmail list [count]")
        print("  gmail invites [days_forward] [max_results]")
        sys.exit(1)

    command = sys.argv[1]

    if command == "search":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 5
        print(skill_search_email(query, max_results))

    elif command == "get":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        index = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        print(skill_get_email(query, index))

    elif command == "list":
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        print(skill_list_recent_emails(count))

    elif command == "invites":
        days_forward = int(sys.argv[2]) if len(sys.argv) > 2 else 7
        max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 20
        print(skill_search_meeting_invites(days_forward, max_results))

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
