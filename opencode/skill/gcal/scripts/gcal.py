#!/home/dxta/.config/opencode/venv/bin/python
"""
Google Calendar & Meet Skill - Search meetings, get details, and fetch transcripts

Requirements:
1. Google Cloud Project with Calendar API enabled
2. OAuth credentials in ~/.config/opencode/.mcp-credentials.json (reuses 'gmail' section)
3. For Meet transcripts: Enable "Google Meet API" in Google Cloud Console
4. pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
   (installed in ~/.config/opencode/venv)
"""

import os
import sys
import json
import tempfile
import subprocess
from datetime import datetime, timedelta
from datetime import timezone as tz
from pathlib import Path
from typing import Optional, List

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Configuration
CREDENTIALS_PATH = Path.home() / ".config" / "opencode" / ".mcp-credentials.json"
CALENDAR_TOKEN_PATH = Path.home() / ".config" / "opencode" / "skill" / "gcal" / "gcal_token.json"
MEET_TOKEN_PATH = Path.home() / ".config" / "opencode" / "skill" / "gcal" / "gcal_meet_token.json"

CALENDAR_SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']
MEET_SCOPES = ['https://www.googleapis.com/auth/meetings.space.created']


def get_credentials(scopes: list, token_path: Path) -> Credentials:
    """Get OAuth credentials for specified scopes"""
    creds = None

    # Load existing token
    if token_path.exists():
        creds = Credentials.from_authorized_user_file(token_path, scopes)

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
                    tmp_path, scopes
                )
                creds = flow.run_local_server(port=0)
            finally:
                os.unlink(tmp_path)

        # Save credentials for next run
        token_path.parent.mkdir(parents=True, exist_ok=True)
        with open(token_path, 'w') as token:
            token.write(creds.to_json())

    return creds


def get_calendar_service():
    """Get authenticated Calendar API service"""
    creds = get_credentials(CALENDAR_SCOPES, CALENDAR_TOKEN_PATH)
    return build('calendar', 'v3', credentials=creds)


def get_meet_service():
    """Get authenticated Meet API service (separate OAuth flow)"""
    creds = get_credentials(MEET_SCOPES, MEET_TOKEN_PATH)
    return build('meet', 'v2', credentials=creds)


def format_datetime(dt: datetime) -> str:
    """Format datetime for Google Calendar API (RFC3339 UTC)"""
    return dt.strftime('%Y-%m-%dT%H:%M:%SZ')


def list_events(time_min: Optional[str] = None, time_max: Optional[str] = None,
                max_results: int = 50) -> list:
    """
    List events in specified time range

    Args:
        time_min: Start time in RFC3339 format (optional)
        time_max: End time in RFC3339 format (optional)
        max_results: Maximum number of results

    Returns:
        List of event dictionaries
    """
    service = get_calendar_service()

    # Default: past 30 days to next 30 days
    if not time_min:
        time_min = format_datetime(datetime.now(tz.utc) - timedelta(days=30))
    if not time_max:
        time_max = format_datetime(datetime.now(tz.utc) + timedelta(days=30))

    results = service.events().list(
        calendarId='primary',
        timeMin=time_min,
        timeMax=time_max,
        maxResults=max_results,
        orderBy='startTime',
        singleEvents=True
    ).execute()

    items = results.get('items', [])

    events = []
    for item in items:
        # Extract Google Meet link
        meet_link = None
        if 'conferenceData' in item:
            entry_points = item['conferenceData'].get('entryPoints', [])
            if entry_points:
                meet_link = entry_points[0].get('uri')
        elif 'hangoutLink' in item:
            meet_link = item['hangoutLink']

        # Format start/end times
        start = item.get('start', {})
        end = item.get('end', {})
        start_time = start.get('dateTime', start.get('date', ''))
        end_time = end.get('dateTime', end.get('date', ''))

        # Get attendees
        attendees = item.get('attendees', [])
        attendee_list = [a.get('email', '') for a in attendees if a.get('email')]

        events.append({
            'id': item['id'],
            'summary': item.get('summary', '(No title)'),
            'description': item.get('description', ''),
            'start': start_time,
            'end': end_time,
            'location': item.get('location', ''),
            'meet_link': meet_link,
            'attendees': attendee_list,
            'status': item.get('status', ''),
        })

    return events


def get_event(event_id: str) -> dict:
    """
    Get detailed event information

    Args:
        event_id: Google Calendar event ID

    Returns:
        Event dictionary with full details
    """
    service = get_calendar_service()

    event = service.events().get(
        calendarId='primary',
        eventId=event_id
    ).execute()

    return event


def search_events(query: str, time_min: Optional[str] = None,
                 time_max: Optional[str] = None, max_results: int = 10) -> list:
    """
    Search events by query string in summary and description

    Args:
        query: Search query string
        time_min: Start time in RFC3339 format (optional)
        time_max: End time in RFC3339 format (optional)
        max_results: Maximum number of results

    Returns:
        List of matching events
    """
    all_events = list_events(time_min, time_max, max_results=100)

    query_lower = query.lower()
    matching = []

    for event in all_events:
        summary = event.get('summary', '').lower()
        description = event.get('description', '').lower()

        if query_lower in summary or query_lower in description:
            matching.append(event)
            if len(matching) >= max_results:
                break

    return matching


def list_conference_records(max_results: int = 10) -> list:
    """
    List conference records from Meet API

    Args:
        max_results: Maximum number of results

    Returns:
        List of conference record dictionaries
    """
    try:
        service = get_meet_service()

        results = service.conferenceRecords().list(
            pageSize=max_results
        ).execute()

        records = results.get('conferenceRecords', [])

        formatted = []
        for record in records:
            formatted.append({
                'name': record.get('name', ''),
                'meeting_code': record.get('meetingCode', ''),
                'start_time': record.get('startTime', ''),
                'end_time': record.get('endTime', ''),
            })

        return formatted

    except HttpError as e:
        if e.status_code == 403:
            return ["Error: Meet API not enabled. Please enable 'Google Meet API' in Google Cloud Console."]
        return [f"Error: {str(e)}"]
    except Exception as e:
        return [f"Error: {str(e)}"]


def get_transcript(conference_record_name: str) -> dict:
    """
    Get transcript entries from a conference record

    Args:
        conference_record_name: Format 'conferenceRecords/RECORD_ID'

    Returns:
        Dictionary with transcript entries
    """
    try:
        service = get_meet_service()

        # List transcripts for this conference
        transcripts = service.conferenceRecords().transcripts().list(
            parent=conference_record_name
        ).execute()

        transcript_list = transcripts.get('transcripts', [])

        all_entries = []
        for transcript in transcript_list:
            transcript_name = transcript.get('name', '')

            # Get entries for this transcript
            entries_result = service.conferenceRecords().transcripts().entries().list(
                parent=transcript_name
            ).execute()

            entries = entries_result.get('entries', [])
            for entry in entries:
                all_entries.append({
                    'text': entry.get('text', ''),
                    'start_time': entry.get('startTime', ''),
                    'participant': entry.get('participant', {}).get('displayName', 'Unknown'),
                    'language_code': entry.get('languageCode', ''),
                })

        return {
            'conference_record': conference_record_name,
            'entries': all_entries,
            'entry_count': len(all_entries),
        }

    except HttpError as e:
        return {'error': f'HTTP Error {e.status_code}: {str(e)}'}
    except Exception as e:
        return {'error': str(e)}


# ============================================================================
# Skill interface functions
# ============================================================================

def skill_list_meetings(days_past: int = 30, days_future: int = 30) -> str:
    """List meetings from past N days to next N days"""
    try:
        time_min = format_datetime(datetime.now(tz.utc) - timedelta(days=days_past))
        time_max = format_datetime(datetime.now(tz.utc) + timedelta(days=days_future))

        events = list_events(time_min, time_max)

        if not events:
            return f"No meetings found in the past {days_past} days to next {days_future} days"

        summary = f"Found {len(events)} meetings:\n\n"
        for i, event in enumerate(events, 1):
            summary += f"{i}. {event['summary']}\n"
            summary += f"   Start: {event['start']}\n"
            summary += f"   End: {event['end']}\n"
            if event['meet_link']:
                summary += f"   Meet: {event['meet_link']}\n"
            if event['attendees']:
                summary += f"   Attendees: {', '.join(event['attendees'][:5])}"
                if len(event['attendees']) > 5:
                    summary += f" (+{len(event['attendees']) - 5} more)"
                summary += "\n"
            summary += "\n"

        return summary

    except Exception as e:
        return f"Error listing meetings: {str(e)}"


def skill_search_meetings(query: str, max_results: int = 10) -> str:
    """Search meetings by query"""
    try:
        events = search_events(query, max_results=max_results)

        if not events:
            return f"No meetings found matching: {query}"

        summary = f"Found {len(events)} meetings matching '{query}':\n\n"
        for i, event in enumerate(events, 1):
            summary += f"{i}. {event['summary']}\n"
            summary += f"   Start: {event['start']}\n"
            summary += f"   End: {event['end']}\n"
            if event['description']:
                desc_preview = event['description'][:100]
                if len(event['description']) > 100:
                    desc_preview += "..."
                summary += f"   Description: {desc_preview}\n"
            if event['meet_link']:
                summary += f"   Meet: {event['meet_link']}\n"
            summary += "\n"

        return summary

    except Exception as e:
        return f"Error searching meetings: {str(e)}"


def skill_get_meeting(query: str, index: int = 0) -> str:
    """Search and get specific meeting by index"""
    try:
        events = search_events(query, max_results=10)

        if not events or index >= len(events):
            return f"Meeting not found (tried index {index} of {len(events)} results)"

        event = events[index]
        full_event = get_event(event['id'])

        result = f"""Summary: {event['summary']}
Start: {event['start']}
End: {event['end']}
Location: {event.get('location', 'N/A')}
Status: {event.get('status', '')}

Attendees:
"""

        for attendee in event.get('attendees', []):
            result += f"  - {attendee}\n"

        if event['description']:
            result += f"\nDescription:\n{event['description']}\n"

        if event['meet_link']:
            result += f"\nGoogle Meet: {event['meet_link']}\n"

        return result

    except Exception as e:
        return f"Error retrieving meeting: {str(e)}"


def skill_list_conference_records(max_results: int = 10) -> str:
    """List available conference records for transcript fetching"""
    try:
        records = list_conference_records(max_results)

        if isinstance(records, list) and len(records) > 0 and isinstance(records[0], str):
            # Error message
            return records[0]

        if not records:
            return "No conference records found. Transcripts are only available if recording was enabled."

        summary = f"Found {len(records)} conference records:\n\n"
        for i, record in enumerate(records, 1):
            summary += f"{i}. Meeting Code: {record['meeting_code']}\n"
            summary += f"   Start: {record['start_time']}\n"
            summary += f"   End: {record.get('end_time', 'N/A')}\n"
            summary += f"   Record: {record['name']}\n\n"

        return summary

    except Exception as e:
        return f"Error listing conference records: {str(e)}"


def skill_get_transcript(meeting_code: str = None, index: int = 0) -> str:
    """
    Get transcript for a meeting

    Args:
        meeting_code: Google Meet meeting code (e.g., 'abc-mnop-xyz')
        index: If no meeting_code, use index from list
    """
    try:
        records = list_conference_records(max_results=20)

        if isinstance(records, list) and len(records) > 0 and isinstance(records[0], str):
            return records[0]

        if not records:
            return "No conference records found. Transcripts are only available if recording was enabled."

        # Find target record
        target_record = None
        if meeting_code:
            for record in records:
                if record['meeting_code'] == meeting_code:
                    target_record = record
                    break
            if not target_record:
                return f"Meeting code '{meeting_code}' not found in conference records"
        elif index < len(records):
            target_record = records[index]
        else:
            return f"Index {index} out of range (found {len(records)} records)"

        # Get transcript
        transcript_data = get_transcript(target_record['name'])

        if 'error' in transcript_data:
            return f"Error fetching transcript: {transcript_data['error']}"

        entries = transcript_data.get('entries', [])

        if not entries:
            return f"No transcript entries found for meeting {target_record['meeting_code']}"

        result = f"""Transcript for: {target_record['meeting_code']}
Meeting Code: {target_record['meeting_code']}
Start Time: {target_record['start_time']}
Entries: {len(entries)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""

        for entry in entries:
            participant = entry.get('participant', 'Unknown')
            text = entry.get('text', '')
            start_time = entry.get('start_time', '')
            result += f"[{participant} @ {start_time}]\n{text}\n\n"

        result += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        return result

    except Exception as e:
        return f"Error retrieving transcript: {str(e)}"


def skill_check_meetings(days_forward: int = 7, days_past: int = 1) -> str:
    """
    Check both Calendar API and Gmail for comprehensive meeting information

    Args:
        days_forward: Number of days ahead to search
        days_past: Number of days past to include

    Returns:
        Combined summary of calendar events and email invites
    """
    try:
        result = ""

        # Get calendar events
        time_min = format_datetime(datetime.now(tz.utc) - timedelta(days=days_past))
        time_max = format_datetime(datetime.now(tz.utc) + timedelta(days=days_forward))

        calendar_events = list_events(time_min, time_max, max_results=50)

        if calendar_events:
            result += f"📅 Calendar Events ({len(calendar_events)} found):\n\n"
            for i, event in enumerate(calendar_events, 1):
                result += f"{i}. {event['summary']}\n"
                result += f"   Start: {event['start']}\n"
                result += f"   End: {event['end']}\n"
                if event['meet_link']:
                    result += f"   Meet: {event['meet_link']}\n"
                if event['attendees']:
                    attendee_list = ', '.join(event['attendees'][:5])
                    if len(event['attendees']) > 5:
                        attendee_list += f" (+{len(event['attendees']) - 5} more)"
                    result += f"   Attendees: {attendee_list}\n"
                result += "\n"
        else:
            result += f"📅 Calendar Events: None found\n\n"

        # Get email invites via gmail skill
        try:
            gmail_skill_path = Path.home() / ".config" / "opencode" / "skills" / "gmail"
            invite_result = subprocess.run(
                [str(gmail_skill_path), "invites", str(days_forward), "20"],
                capture_output=True,
                text=True,
                timeout=30
            )

            if invite_result.returncode == 0 and invite_result.stdout:
                invites_output = invite_result.stdout.strip()
                # Only add if there are actual invites (not "No meeting invites found")
                if "No meeting invites found" not in invites_output:
                    result += f"📧 Email Invites:\n\n{invites_output}\n"
                else:
                    result += f"📧 Email Invites: None found\n"
            else:
                result += f"📧 Email Invites: Unable to fetch\n"

        except subprocess.TimeoutExpired:
            result += f"📧 Email Invites: Request timed out\n"
        except FileNotFoundError:
            result += f"📧 Email Invites: Gmail skill not found\n"
        except Exception as e:
            result += f"📧 Email Invites: Error - {str(e)}\n"

        return result.strip()

    except Exception as e:
        return f"Error checking meetings: {str(e)}"


# ============================================================================
# CLI interface
# ============================================================================

def main():
    """CLI interface for testing"""
    if len(sys.argv) < 2:
        print("Usage: gcal list|search|get|records|transcript|check [args...]")
        print("  gcal list [days_past] [days_future]")
        print("  gcal search '<query>' [max_results]")
        print("  gcal get '<query>' [index]")
        print("  gcal records [max_results]")
        print("  gcal transcript [meeting_code] [index]")
        print("  gcal check [days_forward] [days_past]")
        sys.exit(1)

    command = sys.argv[1]

    if command == "list":
        days_past = int(sys.argv[2]) if len(sys.argv) > 2 else 30
        days_future = int(sys.argv[3]) if len(sys.argv) > 3 else 30
        print(skill_list_meetings(days_past, days_future))

    elif command == "search":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        print(skill_search_meetings(query, max_results))

    elif command == "get":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        index = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        print(skill_get_meeting(query, index))

    elif command == "records":
        max_results = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        print(skill_list_conference_records(max_results))

    elif command == "transcript":
        # Check if arg is meeting code or index
        if len(sys.argv) > 2:
            arg = sys.argv[2]
            # Try to parse as index first
            try:
                index = int(arg)
                meeting_code = None
            except ValueError:
                # It's a meeting code
                meeting_code = arg
                index = 0
        else:
            meeting_code = None
            index = 0

        # Override index if third arg provided
        if len(sys.argv) > 3 and meeting_code:
            index = int(sys.argv[3])

        print(skill_get_transcript(meeting_code, index))

    elif command == "check":
        days_forward = int(sys.argv[2]) if len(sys.argv) > 2 else 7
        days_past = int(sys.argv[3]) if len(sys.argv) > 3 else 1
        print(skill_check_meetings(days_forward, days_past))

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
