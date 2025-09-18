# Testing Teams Meeting API with Bruno

This guide shows how to test Microsoft Teams meeting creation API using Bruno REST client after setting up your Application Access Policy.

## 📋 Prerequisites

Before testing with Bruno, ensure you have completed:

✅ **Azure App Registration** created with application permissions  
✅ **Application Access Policy** created and assigned to users  
✅ **30+ minutes waited** for policy propagation  
✅ **Bruno REST client** installed ([Download Bruno](https://www.usebruno.com/))  

### Required Information
- **Tenant ID** (from Azure Portal)
- **Client ID** (from App Registration)
- **Client Secret** (from App Registration)
- **Test user email** (who has the policy assigned)

## 🚀 Bruno Collection Setup

### Step 1: Create New Collection
1. Open Bruno
2. Click **"New Collection"**
3. Name: `Teams Meeting API Tests`
4. Location: Choose a folder to save your requests

### Step 2: Set Up Environment Variables

Click **"Environments"** in your collection and create these variables:

```json
{
  "tenantId": "your-actual-tenant-id-here",
  "clientId": "your-actual-client-id-here",
  "clientSecret": "your-actual-client-secret-here",
  "baseUrl": "https://graph.microsoft.com/v1.0",
  "authUrl": "https://login.microsoftonline.com",
  "testUser": "steve.smith@company.com",
  "accessToken": ""
}
```

**Example with real values:**
```json
{
  "tenantId": "c6d29e44-c3b2-4a22-8d73-xxxxxxxxx",
  "clientId": "ddb80e06-92f3-4978-bc22-xxxxx",
  "clientSecret": "your-secret-value-here",
  "baseUrl": "https://graph.microsoft.com/v1.0",
  "authUrl": "https://login.microsoftonline.com",
  "testUser": "rsteve.smith@ccompany.com",
  "accessToken": ""
}
```

## 🔐 Request 1: Get Access Token

### Create Authentication Request

**Request Name:** `Get Access Token`

#### URL
```
{{authUrl}}/{{tenantId}}/oauth2/v2.0/token
```

#### Method
```
POST
```

#### Headers
| Name | Value |
|------|-------|
| `Content-Type` | `application/x-www-form-urlencoded` |

#### Body Type
Select **"Form URL Encoded"**

#### Body Parameters
| Name | Value |
|------|-------|
| `grant_type` | `client_credentials` |
| `client_id` | `{{clientId}}` |
| `client_secret` | `{{clientSecret}}` |
| `scope` | `https://graph.microsoft.com/.default` |

#### Post-Response Script
Add this script to automatically save the token:

```javascript
// Bruno Post-Response Script
if (res.status === 200) {
    const response = res.body;
    bru.setEnvVar("accessToken", response.access_token);
    console.log("✓ Access token saved to environment");
} else {
    console.log("✗ Failed to get access token");
    console.log("Status:", res.status);
    console.log("Response:", res.body);
}
```

### Test the Authentication
1. Click **"Send"** on your authentication request
2. **Expected Response:**
```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "access_token": "eyJ0eXAiOiJKV1..."
}
```
3. The `accessToken` environment variable should be automatically populated

## 👥 Request 2: Create Teams Meeting

### Create Meeting Request

**Request Name:** `Create Teams Meeting with Specific Organizer`

#### URL
```
{{baseUrl}}/users/{{testUser}}/onlineMeetings
```

#### Method
```
POST
```

#### Headers
| Name | Value |
|------|-------|
| `Authorization` | `Bearer {{accessToken}}` |
| `Content-Type` | `application/json` |

#### Body Type
Select **"JSON"**

#### Body Content
```json
{
  "subject": "Test Meeting - API Created",
  "startDateTime": "2025-09-20T14:30:00.000Z",
  "endDateTime": "2025-09-20T15:30:00.000Z",
  "joinMeetingIdSettings": {
    "isPasscodeRequired": false
  },
  "chatInfo": {
    "threadId": null
  }
}
```

#### Advanced Meeting Example
```json
{
  "subject": "Advanced Test Meeting - Breakout Room Ready",
  "startDateTime": "2025-09-20T14:30:00.000Z",
  "endDateTime": "2025-09-20T16:00:00.000Z",
  "allowMeetingChat": "enabled",
  "allowTeamworkReactions": true,
  "allowedPresenters": "everyone",
  "autoAdmittedUsers": "everyoneInCompanyExcludingGuests",
  "isEntryExitAnnounced": true,
  "joinMeetingIdSettings": {
    "isPasscodeRequired": false
  },
  "lobbyBypassSettings": {
    "scope": "organization",
    "isDialInBypassEnabled": false
  },
  "participants": {
    "attendees": [
      {
        "upn": "attendee1@company.com",
        "role": "attendee"
      },
      {
        "upn": "attendee2@company.com", 
        "role": "presenter"
      }
    ]
  }
}
```

### Test Meeting Creation
1. **First**: Run the "Get Access Token" request to get a fresh token
2. **Then**: Run the "Create Teams Meeting" request
3. **Expected Response:**
```json
{
  "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users('user-guid')/onlineMeetings/$entity",
  "id": "MSpkYzE3Njc0Yy04MWQ5LTRhZGItYmZi...",
  "creationDateTime": "2025-09-18T12:00:00.000Z",
  "startDateTime": "2025-09-20T14:30:00.000Z",
  "endDateTime": "2025-09-20T15:30:00.000Z",
  "joinWebUrl": "https://teams.microsoft.com/l/meetup-join/...",
  "subject": "Test Meeting - API Created",
  "participants": {
    "organizer": {
      "upn": "steve.smith@company.com",
      "role": "presenter",
      "identity": {
        "user": {
          "id": "user-guid-here",
          "displayName": "Steve Smith"
        }
      }
    }
  }
}
```

## 🧪 Additional Test Requests

### Request 3: List User's Meetings
**Verify the meeting was created under the correct user**

#### URL
```
{{baseUrl}}/users/{{testUser}}/onlineMeetings
```

#### Method
```
GET
```

#### Headers
| Name | Value |
|------|-------|
| `Authorization` | `Bearer {{accessToken}}` |

### Request 4: Get Specific Meeting
**Get details of a created meeting**

#### URL
```
{{baseUrl}}/users/{{testUser}}/onlineMeetings/{{meetingId}}
```

#### Method
```
GET
```

#### Headers
| Name | Value |
|------|-------|
| `Authorization` | `Bearer {{accessToken}}` |

*Note: Replace `{{meetingId}}` with actual meeting ID from creation response*

### Request 5: Delete Meeting
**Clean up test meetings**

#### URL
```
{{baseUrl}}/users/{{testUser}}/onlineMeetings/{{meetingId}}
```

#### Method
```
DELETE
```

#### Headers
| Name | Value |
|------|-------|
| `Authorization` | `Bearer {{accessToken}}` |

## 🔍 Testing Checklist

### Before Testing
- [ ] App registration created with application permissions
- [ ] Application Access Policy created and assigned
- [ ] Waited 30+ minutes for policy propagation
- [ ] Bruno environment variables configured
- [ ] Test user email has the policy assigned

### Test Sequence
1. [ ] **Get Access Token** - Should return 200 with token
2. [ ] **Create Meeting** - Should return 201 with meeting details
3. [ ] **Verify Organizer** - Check `participants.organizer.upn` matches test user
4. [ ] **Test Meeting URL** - Open `joinWebUrl` in browser
5. [ ] **Join as Organizer** - Test user should be able to create breakout rooms

### Success Indicators
✅ **Token Request**: Status 200, access_token received  
✅ **Meeting Creation**: Status 201, meeting object returned  
✅ **Correct Organizer**: `organizer.upn` matches your test user  
✅ **Meeting Accessible**: Join URL works in Teams  
✅ **Breakout Rooms**: Organizer can create breakout rooms in Teams UI  

## 🚨 Troubleshooting

### Authentication Issues

#### Error: "invalid_client"
**Cause**: Wrong client ID or secret
```json
{
  "error": "invalid_client",
  "error_description": "AADSTS7000215: Invalid client secret is provided."
}
```
**Fix**: Verify `clientId` and `clientSecret` in environment variables

#### Error: "invalid_scope"
**Cause**: Wrong scope parameter
**Fix**: Ensure scope is exactly `https://graph.microsoft.com/.default`

### Meeting Creation Issues

#### Error: "Forbidden" or "Access denied"
```json
{
  "error": {
    "code": "Forbidden",
    "message": "Insufficient privileges to complete the operation."
  }
}
```

**Possible Causes:**
1. **Policy not propagated**: Wait longer (up to 60 minutes)
2. **User doesn't have policy**: Verify with PowerShell:
   ```powershell
   Get-CsUserPolicyAssignment -Identity "user@domain.com" -PolicyType ApplicationAccessPolicy
   ```
3. **Wrong permissions**: Ensure app has `OnlineMeetings.ReadWrite.All` (application)
4. **Token expired**: Get fresh token (expires after ~1 hour)

#### Error: "User not found"
```json
{
  "error": {
    "code": "NotFound",
    "message": "User not found"
  }
}
```
**Fix**: Verify user email exists in your tenant and has correct spelling

#### Error: "BadRequest" - Invalid DateTime
```json
{
  "error": {
    "code": "BadRequest",
    "message": "Invalid date time format"
  }
}
```
**Fix**: Use ISO 8601 format: `2025-09-20T14:30:00.000Z`

### Token Issues

#### Token Expires Quickly
- Tokens expire after ~1 hour
- Re-run authentication request to get fresh token
- Consider implementing token refresh in your actual application

#### Environment Variable Not Updating
- Check post-response script in authentication request
- Manually copy token if script fails
- Verify script syntax in Bruno

## 🔧 Bruno Tips & Tricks

### 1. Organize Requests
Create folders in your collection:
- **📁 Authentication**
  - Get Access Token
- **📁 Meeting Management** 
  - Create Meeting
  - List Meetings
  - Get Meeting
  - Delete Meeting

### 2. Use Pre-Request Scripts
Add to meeting creation requests:
```javascript
// Check if token exists and is not expired
if (!bru.getEnvVar("accessToken")) {
    throw new Error("No access token found. Run authentication request first.");
}
```

### 3. Response Validation
Add to meeting creation request:
```javascript
// Validate response
if (res.status === 201) {
    const meeting = res.body;
    console.log("✓ Meeting created successfully");
    console.log("Meeting ID:", meeting.id);
    console.log("Organizer:", meeting.participants.organizer.upn);
    console.log("Join URL:", meeting.joinWebUrl);
    
    // Save meeting ID for other requests
    bru.setEnvVar("lastMeetingId", meeting.id);
} else {
    console.log("✗ Meeting creation failed");
    console.log("Status:", res.status);
    console.log("Error:", res.body);
}
```

### 4. Dynamic Test Data
Use variables for dates:
```javascript
// Pre-request script for meeting creation
const now = new Date();
const startTime = new Date(now.getTime() + (24 * 60 * 60 * 1000)); // Tomorrow
const endTime = new Date(startTime.getTime() + (60 * 60 * 1000)); // +1 hour

bru.setVar("startDateTime", startTime.toISOString());
bru.setVar("endDateTime", endTime.toISOString());
```

Then use in body:
```json
{
  "subject": "Dynamic Test Meeting",
  "startDateTime": "{{startDateTime}}",
  "endDateTime": "{{endDateTime}}"
}
```

## 📊 Testing Different Scenarios

### Scenario 1: Multiple Organizers
Test with different users who have the policy:
```json
// Environment variables
{
  "testUser1": "steve.smith@company.com",
  "testUser2": "sam.smith@company.com",
  "testUser3": "facilitator@company.com"
}
```

### Scenario 2: Different Meeting Types
Test various meeting configurations:
- Basic meetings (minimal payload)
- Advanced meetings (with attendees, settings)
- Recurring meetings (if supported)
- Meetings with specific permissions

### Scenario 3: Error Handling
Intentionally test error conditions:
- Invalid user emails
- Expired tokens
- Missing permissions
- Invalid date formats

## 📈 Monitoring and Logging

### Bruno Console Logs
Use console.log in scripts to track:
- Token expiration times
- Meeting creation success/failure
- Organizer verification
- Response times

### Azure Logs
Monitor in Azure Portal:
- **Azure AD Sign-in logs**: App authentication
- **Azure AD Audit logs**: Permission grants
- **Application Insights**: API usage (if configured)

## ✅ Final Verification

Your setup is working correctly when:

1. ✅ **Authentication succeeds**: Bruno gets valid access tokens
2. ✅ **Meeting creation works**: Returns 201 with meeting object  
3. ✅ **Correct organizer assigned**: Specified user becomes organizer
4. ✅ **Teams integration works**: Meeting opens in Teams client
5. ✅ **Breakout rooms possible**: Organizer can create breakout rooms in Teams UI

## 🎯 Next Steps

After successful Bruno testing:

1. **Document working requests**: Export/save your Bruno collection
2. **Implement in your application**: Use the same API calls in xMatters
3. **Handle token refresh**: Implement automatic token renewal
4. **Add error handling**: Handle various API error conditions
5. **Monitor usage**: Set up logging and monitoring in production

---

**🎉 Success!** Once your Bruno tests are working, you're ready to integrate the same API calls into your xMatters workflow with confidence that the Microsoft Teams meeting creation will work with the correct organizers who can create breakout rooms.