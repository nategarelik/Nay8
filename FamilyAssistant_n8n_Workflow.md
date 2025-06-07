# Family Assistant n8n Workflow Plan

This document describes a comprehensive n8n workflow for a family assistant powered by OpenAI and integrated with a variety of tools (schedules, calendars, email, reservations, and more). It includes a sample n8n workflow JSON at the end.

---

## Workflow Overview

- **Trigger:** Webhook (receives messages from Nay8)
- **Agent:** OpenAI (interprets and routes requests)
- **Tools:** Calendar, Email, Reservations, Reminders, Notifications, Weather, and more
- **Response:** Returns results to Nay8 for the user/family

---

## Workflow Steps

### 1. Webhook Trigger
- **Node:** Webhook
- **Purpose:** Receives POSTs from Nay8 (your message relay).
- **Input:** `{ "sender": "...", "recipient": "...", "message": "..." }`

### 2. (Optional) Context Management
- **Node:** Function / Database / Google Sheet
- **Purpose:** Maintain chat context, user preferences, or conversation history for better agent memory and personalization.

### 3. OpenAI Agent Node
- **Node:** OpenAI (ChatGPT or GPT-4)
- **Purpose:** Interprets the incoming message, determines intent, and generates a response or action plan.
- **Input:**  
  - System prompt: "You are the family assistant. You can help with schedules, calendars, emails, reservations, and more. Use tools as needed."
  - User message: From webhook.
  - (Optional) Context/history.

### 4. Intent Detection & Routing
- **Node:** Switch / IF / Function
- **Purpose:** Decide what the user wants (e.g., "add event", "what's on my calendar", "send email", "book a table", etc.).
- **How:**  
  - Use OpenAI's response or a separate classification step.
  - Example intents: calendar_query, calendar_add, email_send, reservation_make, general_info, etc.

### 5. Tool Integration Nodes

#### a. Calendar (Google Calendar, Outlook, Apple Calendar)
- **Nodes:** Google Calendar or Microsoft Outlook Calendar
- **Actions:**
  - Query events (list, next event, etc.)
  - Add new events (with parsing for date/time/title/location)
  - Update/delete events
- **Input:** Event details parsed from OpenAI or user message.

#### b. Email (Gmail, Outlook)
- **Nodes:** Gmail, Microsoft Outlook Email, IMAP/SMTP
- **Actions:**
  - Send email (to family or external contacts)
  - Read/search inbox
  - Summarize unread emails
- **Input:** Recipient, subject, body from OpenAI or user.

#### c. Reservations (OpenTable, Google Reservations, Custom APIs)
- **Nodes:** HTTP Request (for APIs), OpenTable, or custom integrations
- **Actions:**
  - Make a reservation (restaurant, activity, etc.)
  - Query reservation status
- **Input:** Date, time, party size, location, etc.

#### d. Reminders/To-Do (Google Tasks, Todoist, Apple Reminders)
- **Nodes:** Google Tasks, Todoist, HTTP Request (for Apple Reminders via iCloud)
- **Actions:**
  - Add reminder/task
  - List reminders/tasks

#### e. Messaging/Notifications (SMS, Push, Email)
- **Nodes:** Twilio, Pushover, Email
- **Actions:**
  - Notify family members of events, reminders, or confirmations

#### f. Other Family Tools
- **Weather:** Weather API node for local forecasts
- **Groceries:** Google Sheets or Todoist for shared shopping lists
- **Location Sharing:** Life360, Find My, or Google Maps API

### 6. Tool Selection Logic
- **Node:** Function or OpenAI  
- **Purpose:** If OpenAI is the “agent” (ReAct/Toolformer style), let it decide which tool to call and with what parameters.
- **How:**  
  - Use OpenAI function calling (if available in n8n) or have OpenAI return a structured action (e.g., `{ "action": "add_calendar_event", "params": {...} }`).

### 7. Execute Tool Action
- The workflow executes the selected tool node(s) with the parameters provided by OpenAI.
- Capture the output/result.

### 8. Agent Response Composition
- **Node:** OpenAI (optional, for summarization)  
- **Purpose:** Summarize the result of the tool action (e.g., "Event added to your calendar for Saturday at 3pm", "Reservation confirmed at Luigi's", "Sent email to Mom").
- **Input:** Tool output.

### 9. Send Response Back to Nay8
- **Node:** HTTP Response
- **Purpose:** Return the agent’s reply to Nay8, which then relays it to the user/family group.

### 10. Logging & Error Handling
- **Nodes:** Function, Slack/Email notifications, error branches
- **Purpose:** Log all actions, handle errors gracefully, and notify if something goes wrong.

---

## Example System Prompt for OpenAI

```
You are the family assistant. You can help with:
- Scheduling and reading calendar events
- Sending and summarizing emails
- Making reservations
- Adding reminders
- Sharing weather, locations, and more

When you need to use a tool, reply with a JSON object describing the action and its parameters.
```

---

## Example Workflow Structure (Visual)

```
[Webhook]
   |
[Context Fetch (optional)]
   |
[OpenAI Agent]
   |
[Intent Switch]
   |         |         |         |
[Calendar] [Email] [Reservation] [Other]
   |         |         |         |
[OpenAI Response Compose (optional)]
   |
[HTTP Response]
```

---

## Security & Privacy
- Ensure sensitive data (emails, calendar, etc.) is handled securely.
- Use environment variables for API keys.
- Audit logs for all actions.

---

## Example n8n Workflow JSON

```json
{
  "nodes": [
    {
      "parameters": {
        "path": "family-assistant",
        "options": {}
      },
      "id": 1,
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [200, 300]
    },
    {
      "parameters": {
        "resource": "chat",
        "operation": "create",
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content": "You are the family assistant. You can help with schedules, calendars, emails, reservations, and more. Use tools as needed."
          },
          {
            "role": "user",
            "content": "={{$json[\"body\"][\"message\"]}}"
          }
        ]
      },
      "id": 2,
      "name": "OpenAI",
      "type": "n8n-nodes-base.openai",
      "typeVersion": 1,
      "position": [400, 300]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json[\"choices\"][0][\"message\"][\"content\"]}}",
              "operation": "contains",
              "value2": "calendar"
            }
          ]
        }
      },
      "id": 3,
      "name": "Switch",
      "type": "n8n-nodes-base.switch",
      "typeVersion": 1,
      "position": [600, 300]
    },
    {
      "parameters": {
        "calendar": "primary",
        "operation": "getAll",
        "options": {}
      },
      "id": 4,
      "name": "Google Calendar",
      "type": "n8n-nodes-base.googleCalendar",
      "typeVersion": 1,
      "position": [800, 200]
    },
    {
      "parameters": {
        "operation": "send",
        "to": "={{$json[\"to\"]}}",
        "subject": "={{$json[\"subject\"]}}",
        "text": "={{$json[\"body\"]}}"
      },
      "id": 5,
      "name": "Gmail",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 1,
      "position": [800, 400]
    },
    {
      "parameters": {
        "responseMode": "onReceived",
        "responseData": "={{$json}}"
      },
      "id": 6,
      "name": "Respond to Nay8",
      "type": "n8n-nodes-base.httpResponse",
      "typeVersion": 1,
      "position": [1000, 300]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "OpenAI",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenAI": {
      "main": [
        [
          {
            "node": "Switch",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Switch": {
      "main": [
        [
          {
            "node": "Google Calendar",
            "type": "main",
            "index": 0
          },
          {
            "node": "Gmail",
            "type": "main",
            "index": 1
          }
        ]
      ]
    },
    "Google Calendar": {
      "main": [
        [
          {
            "node": "Respond to Nay8",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Gmail": {
      "main": [
        [
          {
            "node": "Respond to Nay8",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

---

**Note:**
- This JSON is a template. You must configure credentials and may need to adapt nodes for your exact tools and logic.
- Add more branches/nodes for reservations, reminders, notifications, etc. as needed.
