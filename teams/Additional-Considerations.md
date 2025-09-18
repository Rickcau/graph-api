# Additional Considerations: Multiple Breakout Room Managers

This document explains the various options available to allow multiple people to create and manage breakout rooms, beyond just the primary meeting organizer.

## 🎯 Overview

By default, only the meeting organizer can create breakout rooms. However, Microsoft Teams provides several mechanisms to delegate breakout room management to others during the meeting. **Important:** All breakout room creation still happens manually through the Teams UI - there is no API to create breakout rooms programmatically.

## 🔑 Available Options

### Option 1: Co-Organizers (Recommended)
**What:** Assign up to 10 co-organizers who have near-organizer permissions  
**When:** Best for regular collaborators from the same organization  
**Limitation:** Can only manage breakout rooms during live meetings, not before  

### Option 2: Breakout Room Managers
**What:** Appoint presenters as dedicated breakout room managers  
**When:** Good for delegating specific breakout room responsibilities  
**Limitation:** Must be configured during the meeting or in meeting options  

### Option 3: Multiple Primary Organizers (Different Meetings)
**What:** Create different meetings with different organizers via API  
**When:** Best for rotating responsibilities or different incident types  
**Limitation:** Each meeting needs a different primary organizer  

---

## 📋 Option 1: Co-Organizers

Co-organizers have the most comprehensive permissions and can manage breakout rooms during live meetings.

### Requirements
- ✅ Must be from the same Microsoft 365 organization
- ✅ Must be invited as required attendees
- ✅ Can manage breakout rooms only during live meetings
- ❌ Cannot pre-create breakout rooms before meeting starts

### API Implementation

```json
{
  "subject": "Incident Response - Multiple Co-Organizers",
  "startDateTime": "2025-09-20T14:30:00.000Z",
  "endDateTime": "2025-09-20T16:00:00.000Z",
  "allowedPresenters": "specificPeople",
  "participants": {
    "organizer": {
      "upn": "primary.organizer@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "co.organizer1@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "co.organizer2@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "backup.manager@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "team.member@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "external.contractor@othertenant.com",
        "role": "presenter"
      }
    ]
  }
}
```

### Co-Organizer Capabilities
- ✅ Create and delete breakout rooms during meeting
- ✅ Assign and reassign participants to rooms
- ✅ Open and close rooms
- ✅ Join any room at any time
- ✅ Set time limits for room sessions
- ✅ Send announcements to all rooms
- ✅ Recreate rooms if needed
- ❌ Cannot pre-configure rooms before meeting

### Complete API Example - Co-Organizers

```http
POST https://graph.microsoft.com/v1.0/users/richard.walsh@contoso.com/onlineMeetings
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "subject": "Emergency Response - System Outage Incident",
  "startDateTime": "2025-09-20T09:00:00.000Z",
  "endDateTime": "2025-09-20T11:00:00.000Z",
  "allowMeetingChat": "enabled",
  "allowTeamworkReactions": true,
  "allowedPresenters": "specificPeople",
  "autoAdmittedUsers": "everyoneInCompanyExcludingGuests",
  "isEntryExitAnnounced": false,
  "lobbyBypassSettings": {
    "scope": "organization",
    "isDialInBypassEnabled": true
  },
  "participants": {
    "organizer": {
      "upn": "richard.walsh@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "dan.famiglietti@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "safety.manager@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "operations.lead@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "field.supervisor@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "response.team@contoso.com",
        "role": "attendee"
      }
    ]
  }
}
```

**Result:** Richard, Dan, Safety Manager, and Operations Lead can all create and manage breakout rooms during the live meeting.

---

## 📋 Option 2: Breakout Room Managers

Breakout room managers are presenters who are specifically appointed to manage breakout rooms.

### Requirements
- ✅ Must be presenters in the meeting
- ✅ Must be from the organizer's organization  
- ✅ Appointed by organizer during meeting or in meeting options
- ⚠️ Only one person can manage breakout rooms at a time

### API Implementation

```json
{
  "subject": "Training Session - Breakout Room Managers",
  "startDateTime": "2025-09-20T14:30:00.000Z",
  "endDateTime": "2025-09-20T17:00:00.000Z",
  "allowedPresenters": "specificPeople",
  "participants": {
    "organizer": {
      "upn": "training.coordinator@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "senior.trainer@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "assistant.trainer@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "safety.instructor@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "trainee1@contoso.com",
        "role": "attendee"
      },
      {
        "upn": "trainee2@contoso.com",
        "role": "attendee"
      }
    ]
  }
}
```

### Manual Setup Required
After meeting creation, the organizer must manually:
1. Join the meeting from Teams desktop app
2. Go to Breakout rooms → Room settings
3. Toggle "Assign presenters to manage rooms" ON
4. Select specific presenters to be breakout room managers
5. Save settings

### Breakout Room Manager Capabilities
- ✅ Create and delete breakout rooms (one at a time)
- ✅ Assign and reassign participants
- ✅ Open and close rooms
- ✅ Join any room
- ✅ Set time limits
- ✅ Send announcements
- ❌ Only one manager can control rooms at a time

---

## 📋 Option 3: Multiple Primary Organizers

Create different meetings with different organizers based on requirements.

### Requirements
- ✅ All potential organizers need Application Access Policy
- ✅ Different meetings for different scenarios
- ✅ Full organizer control for each person

### API Implementation - Scenario-Based Organizers

```javascript
// xMatters Logic Example
function selectOrganizer(incidentType, timeOfDay, availability) {
  if (incidentType === 'security' && availability.includes('security.manager@contoso.com')) {
    return 'security.manager@contoso.com';
  } else if (timeOfDay === 'night' && availability.includes('night.supervisor@contoso.com')) {
    return 'night.supervisor@contoso.com';
  } else if (incidentType === 'infrastructure') {
    return 'infrastructure.lead@contoso.com';
  } else {
    return 'richard.walsh@contoso.com'; // Default fallback
  }
}

const organizer = selectOrganizer('security', 'day', availableManagers);
```

### Security Incident Meeting
```http
POST https://graph.microsoft.com/v1.0/users/security.manager@contoso.com/onlineMeetings
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "subject": "URGENT: Security Breach Response",
  "startDateTime": "2025-09-20T08:30:00.000Z",
  "endDateTime": "2025-09-20T10:30:00.000Z",
  "participants": {
    "organizer": {
      "upn": "security.manager@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "security.team@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "site.supervisor@contoso.com",
        "role": "presenter"
      }
    ]
  }
}
```

### Infrastructure Incident Meeting  
```http
POST https://graph.microsoft.com/v1.0/users/infrastructure.lead@contoso.com/onlineMeetings
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "subject": "Infrastructure Outage Response",
  "startDateTime": "2025-09-20T13:00:00.000Z", 
  "endDateTime": "2025-09-20T14:30:00.000Z",
  "participants": {
    "organizer": {
      "upn": "infrastructure.lead@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "network.admin@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "systems.admin@contoso.com",
        "role": "presenter"
      }
    ]
  }
}
```

---

## 🔄 Hybrid Approach: Best of All Options

Combine multiple approaches for maximum flexibility:

```json
{
  "subject": "Multi-Tier Incident Response",
  "startDateTime": "2025-09-20T07:00:00.000Z",
  "endDateTime": "2025-09-20T09:00:00.000Z",
  "allowedPresenters": "specificPeople",
  "participants": {
    "organizer": {
      "upn": "incident.commander@contoso.com",
      "role": "presenter"
    },
    "attendees": [
      {
        "upn": "deputy.commander@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "safety.manager@contoso.com", 
        "role": "coOrganizer"
      },
      {
        "upn": "operations.manager@contoso.com",
        "role": "coOrganizer"
      },
      {
        "upn": "shift.supervisor1@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "shift.supervisor2@contoso.com",
        "role": "presenter"
      },
      {
        "upn": "field.teams@contoso.com",
        "role": "attendee"
      },
      {
        "upn": "external.contractor@partner.com",
        "role": "presenter"
      }
    ]
  }
}
```

**Result:**
- **4 people** can create breakout rooms (1 organizer + 3 co-organizers)
- **2 additional presenters** can be appointed as breakout room managers
- **Flexible coverage** if primary people are unavailable
- **External contractors** can present but not manage breakout rooms

---

## 🚨 Important Limitations

### Universal Limitations
- ❌ **No API for breakout room creation** - all breakout rooms must be created manually in Teams UI
- ❌ **Desktop only for creation** - breakout rooms can only be created from Teams desktop app
- ❌ **One manager at a time** - only one person can actively manage breakout rooms simultaneously
- ❌ **Same organization requirement** - co-organizers must be from the same Microsoft 365 tenant

### Co-Organizer Limitations
- ❌ **No pre-meeting setup** - co-organizers cannot create breakout rooms before the meeting starts
- ❌ **Live meeting only** - can only manage breakout rooms during active meetings

### Breakout Room Manager Limitations
- ❌ **Manual appointment** - organizer must manually appoint managers during or before meeting
- ❌ **One at a time** - managers must "take control" to manage breakout rooms

---

## 📊 Comparison Matrix

| Feature | Primary Organizer | Co-Organizer | Breakout Room Manager | External User |
|---------|------------------|--------------|----------------------|---------------|
| **Create breakout rooms** | ✅ Before & during | ✅ During only | ✅ During only | ❌ Never |
| **Pre-meeting setup** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Full meeting control** | ✅ Yes | ✅ Yes | ❌ Breakout only | ❌ No |
| **Same tenant required** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ Any |
| **API assignment** | ✅ Via URL | ✅ Via JSON | ❌ Manual only | ✅ Via JSON |
| **Multiple simultaneous** | ❌ Only 1 | ✅ Up to 10 | ❌ Only 1 active | ✅ Unlimited |

---

## 🎯 Recommended Implementations

### For Contoso Incident Response

#### Scenario 1: Standard Incident
```json
{
  "subject": "Incident Response - Standard Protocol",
  "participants": {
    "organizer": { "upn": "incident.manager@contoso.com" },
    "attendees": [
      { "upn": "deputy.manager@contoso.com", "role": "coOrganizer" },
      { "upn": "operations.lead@contoso.com", "role": "coOrganizer" },
      { "upn": "site.supervisor@contoso.com", "role": "presenter" }
    ]
  }
}
```

#### Scenario 2: Security Emergency
```json
{
  "subject": "URGENT: Security Incident Response",
  "participants": {
    "organizer": { "upn": "security.specialist@contoso.com" },
    "attendees": [
      { "upn": "security.commander@contoso.com", "role": "coOrganizer" },
      { "upn": "incident.coordinator@contoso.com", "role": "coOrganizer" },
      { "upn": "compliance.officer@contoso.com", "role": "presenter" }
    ]
  }
}
```

#### Scenario 3: Multi-Site Coordination
```json
{
  "subject": "Multi-Site Incident Coordination", 
  "participants": {
    "organizer": { "upn": "regional.manager@contoso.com" },
    "attendees": [
      { "upn": "site1.manager@contoso.com", "role": "coOrganizer" },
      { "upn": "site2.manager@contoso.com", "role": "coOrganizer" },
      { "upn": "site3.manager@contoso.com", "role": "coOrganizer" },
      { "upn": "corporate.liaison@contoso.com", "role": "presenter" }
    ]
  }
}
```

---

## 🛠️ PowerShell Policy Requirements

For all scenarios above, ensure your Application Access Policy includes all potential primary organizers:

```powershell
# All users who might be primary organizers
$PotentialOrganizers = @(
    "incident.manager@contoso.com",
    "security.specialist@contoso.com", 
    "regional.manager@contoso.com",
    "operations.manager@contoso.com",
    "infrastructure.lead@contoso.com",
    "night.supervisor@contoso.com",
    "richard.walsh@contoso.com",
    "dan.famiglietti@contoso.com"
)

foreach ($User in $PotentialOrganizers) {
    Grant-CsApplicationAccessPolicy -PolicyName "xMatters-TeamsPolicy" -Identity $User
    Write-Host "✓ Policy granted to potential organizer: $User"
}
```

---

## 🧪 Testing Multiple Breakout Room Managers

### Bruno Test Collection

Create these test requests in Bruno to verify different scenarios:

#### Test 1: Co-Organizer Setup
```http
POST {{baseUrl}}/users/{{testUser}}/onlineMeetings
{
  "subject": "Test - Co-Organizer Breakout Management",
  "participants": {
    "organizer": { "upn": "{{testUser}}" },
    "attendees": [
      { "upn": "{{coOrganizerUser}}", "role": "coOrganizer" }
    ]
  }
}
```

#### Test 2: Multiple Co-Organizers
```http  
POST {{baseUrl}}/users/{{testUser}}/onlineMeetings
{
  "subject": "Test - Multiple Co-Organizers",
  "participants": {
    "organizer": { "upn": "{{testUser}}" },
    "attendees": [
      { "upn": "{{coOrg1}}", "role": "coOrganizer" },
      { "upn": "{{coOrg2}}", "role": "coOrganizer" },
      { "upn": "{{coOrg3}}", "role": "coOrganizer" }
    ]
  }
}
```

#### Test 3: Mixed Roles
```http
POST {{baseUrl}}/users/{{testUser}}/onlineMeetings  
{
  "subject": "Test - Mixed Roles for Breakout Management",
  "participants": {
    "organizer": { "upn": "{{testUser}}" },
    "attendees": [
      { "upn": "{{coOrg1}}", "role": "coOrganizer" },
      { "upn": "{{presenter1}}", "role": "presenter" },
      { "upn": "{{presenter2}}", "role": "presenter" },
      { "upn": "{{attendee1}}", "role": "attendee" }
    ]
  }
}
```

---

## ✅ Success Verification

After creating meetings with multiple breakout room managers:

### 1. **API Response Verification**
- ✅ Meeting created successfully (201 response)
- ✅ Organizer correctly set in response
- ✅ Co-organizers listed in attendees with correct roles
- ✅ Join URL accessible

### 2. **Teams UI Verification**
- ✅ Primary organizer can create breakout rooms immediately
- ✅ Co-organizers see breakout room management options during meeting
- ✅ Only one person can manage breakout rooms at a time
- ✅ Co-organizers can "take control" of breakout room management

### 3. **Functional Testing**
- ✅ Any co-organizer can create breakout rooms during live meeting
- ✅ Breakout rooms can be reassigned between managers
- ✅ All managers can join any breakout room
- ✅ Announcements work from any manager

---

## 🚀 Implementation Recommendations

### For Production Use
1. **Start with co-organizers** - most flexible option
2. **Add multiple potential primary organizers** to Application Access Policy  
3. **Use scenario-based organizer selection** in xMatters logic
4. **Train all potential managers** on Teams breakout room creation
5. **Document escalation procedures** for when primary manager is unavailable

### For Testing
1. **Test each role type** (organizer, co-organizer, presenter)
2. **Verify same-tenant requirements** 
3. **Test "take control" functionality**
4. **Confirm external user limitations**

---

**📝 Bottom Line:** While breakout rooms must still be created manually in Teams UI, you now have multiple options to ensure several people can create and manage them, providing redundancy and flexibility for your incident response or business coordination scenarios.