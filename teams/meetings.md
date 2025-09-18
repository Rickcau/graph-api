# Microsoft Teams Breakout Rooms: Restrictions and API Limitations

## Overview

Microsoft Teams breakout rooms allow meeting organizers to create smaller discussion groups within a larger meeting. However, there are significant restrictions around who can create and manage these rooms, especially when meetings are created via the Microsoft Graph API.

## Who Can Create Breakout Rooms

### **Primary Restriction: Only Meeting Organizers**
- **Meeting Organizers**: Only the person who organized the meeting can create breakout rooms
- **Co-Organizers**: Cannot create breakout rooms before the meeting starts, but can manage them during the meeting (if from the same organization as the organizer)
- **Presenters**: Cannot create breakout rooms independently - they can only be appointed as "breakout room managers" by the organizer

### **Role Hierarchy for Breakout Rooms**
1. **Meeting Organizer** - Full control: create, manage, assign participants
2. **Co-Organizer** - Can manage during meeting if from same organization as organizer
3. **Breakout Room Manager** - Presenters appointed by organizer to help manage rooms
4. **Regular Presenters** - Cannot create or manage breakout rooms
5. **Attendees** - Cannot create or manage breakout rooms

## API Restrictions and Limitations

### **Critical API Limitation**
**No API Support**: As of 2025, Microsoft Graph API does **not** support creating or managing breakout rooms programmatically

### **UI-Only Creation Requirement**
**Breakout rooms MUST be created through the Teams UI** - there is no programmatic way to create them via any API or automated method.

### **Your Specific Issue Explained**
The problem described in your document is a **known limitation**:

```
POST /v1.0/me/onlineMeetings
```

When using this endpoint:
- The authenticated user (Dan in your case) automatically becomes the meeting organizer
- There's no API parameter to specify a different organizer
- The "With delegated permission only /me endpoint is supported" error confirms this limitation

### **Why Alternative Endpoints Don't Work**
Your attempt to use:
```
/v1.0/users/{userId}/onlineMeetings
```
Failed because:
- Delegated permissions only support the `/me` endpoint
- The API enforces that the token owner becomes the organizer
- Application permissions might work differently, but still don't solve the breakout room API limitation

## Meeting Size and Technical Restrictions

### **Participant Limits**
- Maximum 300 participants when breakout rooms are enabled
- Creating breakout rooms automatically limits meeting attendance to 300 people
- Up to 50 breakout rooms can be created per meeting

### **Platform Requirements**
- Organizers must use Teams desktop or web version to create breakout rooms (not mobile)
- Participants can join breakout rooms from any platform (desktop, web, mobile)

## Organizational Restrictions

### **Internal vs External Users**
- External users cannot manage breakout rooms
- External users need to join the team and be assigned Presenter role
- Only presenters from the organizer's organization can be breakout room managers
- Microsoft Teams (free) account users cannot be assigned to breakout rooms

### **Licensing Requirements**
- Breakout rooms available in Teams for Education and Teams for Business editions
- Personal Teams accounts may not have breakout room capabilities

## UI Creation Requirements

### **Teams UI is the Only Option**
Breakout rooms **must** be created through the Teams user interface - there is no programmatic alternative:

#### **Platform Requirements for Creation**
- **Teams Desktop App** (Windows/Mac) - Primary option for organizers
- **Teams Web App** - Also supports breakout room creation  
- **Teams Mobile App** - Does **NOT** support creating breakout rooms

#### **Two UI Creation Methods**

**1. Pre-Meeting Setup:**
- Access meeting details in Teams calendar
- Navigate to meeting options → Breakout rooms
- Pre-configure rooms and assign participants
- Rooms remain configured for future meeting occurrences

**2. During Active Meeting:**
- Click "Breakout Rooms" button in meeting controls
- Create rooms in real-time during the meeting
- Assign participants as they join the meeting
- More flexible but requires organizer presence

#### **Why This UI Limitation Exists**
Microsoft designed breakout rooms around human facilitation because:
- Room assignments often require real-time judgment about group dynamics
- Breakout decisions are typically made spontaneously during meetings
- The feature prioritizes meeting facilitation over automated scheduling
- Participant engagement and group composition need human oversight

### **Impact on API-Created Meetings**
Even when meetings are created programmatically via Graph API:
- The meeting will function normally for all other features
- Breakout rooms must still be created manually by the organizer through Teams UI
- No workaround exists to automate this process

## Steps to Enable Breakout Room Creation

Since API creation isn't supported, here are the manual steps required:

### **Before the Meeting**
1. **Schedule Meeting**: Create meeting through Teams desktop app
2. **Assign Co-Organizers**: Add up to 10 co-organizers from same organization
3. **Configure Breakout Settings**: Access meeting options to pre-configure rooms
4. **Assign Presenters**: Designate who can be breakout room managers

### **During the Meeting**
1. **Join as Organizer**: Organizer must join from Teams desktop app to create breakout rooms
2. **Create Rooms**: Select "Breakout Rooms" from meeting controls
3. **Configure Assignment**: Choose automatic or manual participant assignment
4. **Manage Rooms**: Only one person can manage breakout rooms at a time

## Workarounds for Your Use Case

Given your API-created meeting scenario, here are potential solutions:

### **Option 1: Hybrid Approach**
1. Create meeting via API with Dan as organizer
2. Have the intended facilitator join as co-organizer
3. Co-organizer can manage breakout rooms during the meeting

### **Option 2: Meeting Templates** 
Microsoft has introduced custom meeting templates with properties like `allowBreakoutRooms`, but this still doesn't solve the organizer assignment issue.

### **Option 3: Application Permissions**
Consider using application permissions instead of delegated permissions, though this would require different authentication setup and may still not resolve the breakout room limitation.

## Current Status and Future Outlook

### **API Development Status**
- Microsoft has breakout rooms "in the backlog" for API support since 2021
- As of March 2025, no Graph API exists for breakout room details or management
- No official timeline provided for API support

### **Recent Updates**
- Recent Teams updates have actually removed some breakout room management features
- New meeting template properties include breakout room settings, but don't address programmatic creation

## Recommendations

1. **Immediate Solution**: Use the hybrid approach where Dan remains organizer but assigns co-organizers who can manage rooms during meetings

2. **Process Change**: Consider having the actual meeting facilitator create meetings directly instead of using a service account

3. **Monitor Updates**: Keep watching for Microsoft Graph API updates that might add breakout room support

4. **Feature Request**: Submit feature requests through Microsoft's support channels to prioritize breakout room API development

## Bottom Line

**The core issue is that Microsoft Teams breakout rooms are fundamentally designed around human organizers, not programmatic creation.** The API limitation you're experiencing is by design, and there's currently no programmatic way to:
- Specify a different organizer when creating meetings via API
- Create or manage breakout rooms through any API
- Grant breakout room creation permissions to anyone other than the meeting organizer

This represents a significant gap in Microsoft's API offerings for automated meeting management scenarios.
