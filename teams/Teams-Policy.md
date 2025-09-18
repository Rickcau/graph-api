# Teams Application Access Policy Setup

This PowerShell script automates the creation and assignment of Microsoft Teams Application Access Policies, allowing your application to create Teams meetings on behalf of specific users.

## 🎯 What This Solves

**Problem**: When creating Teams meetings via Microsoft Graph API, the authenticated user always becomes the meeting organizer, preventing others from creating breakout rooms.

**Solution**: This script creates an Application Access Policy that allows your app to create meetings where any specified user becomes the organizer and can create breakout rooms.

## 📋 Prerequisites

### Required Permissions
- **Teams Administrator** OR **Global Administrator** role in your Microsoft 365 tenant
- PowerShell execution policy that allows running scripts

### Required Information
- **Azure App Registration Client ID** (from your app registration)
- **User email addresses** that should be able to have meetings created on their behalf

### System Requirements
- Windows PowerShell 5.1+ or PowerShell 7+
- Internet connection
- Administrator privileges to install PowerShell modules

## 🚀 Quick Start

### Step 1: Download the Script
Save the PowerShell script as `Setup-TeamsPolicy.ps1`

### Step 2: Get Your App Client ID
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **App registrations**
3. Find your app registration
4. Copy the **Application (client) ID**

### Step 3: Run PowerShell as Administrator
- Right-click **PowerShell**
- Select **"Run as Administrator"**

### Step 4: Execute the Script
```powershell
# Navigate to script location
cd C:\path\to\your\script

# Run with specific users (recommended)
When you run this script it is very important that the AppClientId matches the ID you have for the app registeration otherwise you will have issues creating meetings.
.\Setup-TeamsPolicy.ps1 -AppClientId "your-app-client-id-here" -UserEmails @("user1@company.com", "user2@company.com")
```

## 📖 Usage Examples

### Example 1: Grant Policy to Specific Users
```powershell
.\Setup-TeamsPolicy.ps1 -AppClientId "your-app-client-id-here"" -UserEmails @("steve.smith@company.com", "sam.smith@company.com")
```

### Example 2: Apply Policy Globally (All Users)
```powershell
.\Setup-TeamsPolicy.ps1 -AppClientId "your-app-client-id-here"" -GlobalPolicy
```

### Example 3: Custom Policy Name
```powershell
.\Setup-TeamsPolicy.ps1 -AppClientId "your-app-client-id-here"" -UserEmails @("user@company.com") -PolicyName "MyCustomPolicy"
```

### Example 4: Interactive Mode
```powershell
.\Setup-TeamsPolicy.ps1 -AppClientId "your-app-client-id-here""
# Script will prompt for user assignment choice
```

## 🔧 Script Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `-AppClientId` | ✅ Yes | Azure App Registration Client ID | `"ddb80e06-92f3-4978-bc22-a0eee85e6a9e"` |
| `-UserEmails` | ❌ No | Array of user emails to grant policy to | `@("user1@domain.com", "user2@domain.com")` |
| `-PolicyName` | ❌ No | Custom policy name (default: "xMatters-TeamsPolicy") | `"MyCustomPolicy"` |
| `-GlobalPolicy` | ❌ No | Apply policy to all users in tenant | Switch parameter |

## 🏃‍♂️ What the Script Does

### Automatic Steps
1. **✅ Module Check**: Installs/updates MicrosoftTeams PowerShell module
2. **🔐 Authentication**: Connects to Microsoft Teams (prompts for admin login)
3. **📊 Verification**: Shows tenant information to confirm connection
4. **🔍 Policy Check**: Checks if policy already exists
5. **📝 Policy Creation**: Creates new policy or updates existing one
6. **👥 User Assignment**: Grants policy to specified users or globally
7. **✔️ Verification**: Confirms policy was created and assigned correctly
8. **🔌 Cleanup**: Disconnects from Teams service

### Manual Steps Required
- **Admin Login**: You'll be prompted to sign in with admin credentials
- **Policy Decisions**: If policy exists, you'll choose whether to update it
- **User Assignment**: If no users specified, you'll choose global assignment

## ⏱️ After Running the Script

### Immediate Results
- ✅ Policy created in your Teams tenant
- ✅ Policy assigned to specified users
- ✅ Confirmation of successful setup

### Wait Period
⚠️ **Important**: Wait **30 minutes** for policy propagation before testing

### Test Your Setup
After 30 minutes, test with this API call:

```http
POST https://graph.microsoft.com/v1.0/users/steve.smith@company.com/onlineMeetings
Authorization: Bearer {your-app-access-token}
Content-Type: application/json

{
  "subject": "Test Meeting - Steve as Organizer",
  "startDateTime": "2025-09-19T14:30:00.000Z",
  "endDateTime": "2025-09-19T15:30:00.000Z"
}
```

**Expected Result**: Steve becomes the meeting organizer and can create breakout rooms in Teams UI.

## 🚨 Troubleshooting

### Common Issues

#### "Execution Policy" Error
```powershell
# Fix execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### "Connect-MicrosoftTeams" Not Found
```powershell
# Manually install module
Install-Module -Name MicrosoftTeams -Force -AllowClobber
```

#### "Access Denied" During Connection
- Ensure you have **Teams Administrator** or **Global Administrator** role
- Try running PowerShell as Administrator
- Check if MFA is required for your admin account

#### "Policy Already Exists" Warning
- Script will ask if you want to update it
- Choose 'y' to update with new App ID
- Choose 'n' to keep existing policy unchanged

#### API Still Returns "Access Denied" After Script Success
1. **Wait**: Policy propagation can take up to 30 minutes
2. **Check User**: Ensure user has policy assigned:
   ```powershell
   Get-CsUserPolicyAssignment -Identity "user@domain.com" -PolicyType ApplicationAccessPolicy
   ```
3. **Verify App Token**: Ensure you're using application token (not delegated)
4. **Check App Permissions**: Verify app has `OnlineMeetings.ReadWrite.All` application permission

### Getting Help

#### Check Policy Status
```powershell
# Connect to Teams
Connect-MicrosoftTeams

# View all policies
Get-CsApplicationAccessPolicy

# Check specific user assignment
Get-CsUserPolicyAssignment -Identity "user@domain.com" -PolicyType ApplicationAccessPolicy

# Disconnect
Disconnect-MicrosoftTeams
```

#### Script Debug Mode
Run script with verbose output:
```powershell
.\Setup-TeamsPolicy.ps1 -AppClientId "your-id" -UserEmails @("user@domain.com") -Verbose
```

## 🔒 Security Considerations

### Principle of Least Privilege
- **Recommended**: Grant policy to specific users only
- **Avoid**: Global policies unless absolutely necessary
- **Regular Review**: Audit policy assignments periodically

### App Security
- Store App Client ID and secrets securely
- Use managed identities where possible
- Monitor app usage through Azure logs

### Policy Scope Impact
```powershell
# Specific users (recommended)
-UserEmails @("facilitator1@company.com", "facilitator2@company.com")

# Global (use with caution)
-GlobalPolicy
```

## 📚 Additional Resources

### Microsoft Documentation
- [Application Access Policy](https://docs.microsoft.com/en-us/graph/cloud-communication-online-meeting-application-access-policy)
- [Microsoft Graph Permissions](https://docs.microsoft.com/en-us/graph/permissions-reference)
- [Teams PowerShell Module](https://docs.microsoft.com/en-us/powershell/module/teams/)

### Prerequisites Setup
Before running this script, ensure you have:
1. ✅ [Azure App Registration created](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
2. ✅ Application permissions granted (`OnlineMeetings.ReadWrite.All`)
3. ✅ Admin consent provided for the application
4. ✅ Teams Administrator or Global Administrator role

## 🔄 Script Maintenance

### Updating App IDs
```powershell
# Update existing policy with new app ID
Set-CsApplicationAccessPolicy -Identity "xMatters-TeamsPolicy" -AppIds "new-app-id"
```

### Adding Users to Existing Policy
```powershell
# Grant existing policy to new user
Grant-CsApplicationAccessPolicy -PolicyName "xMatters-TeamsPolicy" -Identity "newuser@company.com"
```

### Removing Policy
```powershell
# Remove policy assignment from user
Grant-CsApplicationAccessPolicy -PolicyName $null -Identity "user@company.com"

# Delete policy completely (after removing all assignments)
Remove-CsApplicationAccessPolicy -Identity "xMatters-TeamsPolicy"
```

## ✅ Success Criteria

You'll know the setup worked when:

1. ✅ Script completes without errors
2. ✅ Policy visible in `Get-CsApplicationAccessPolicy`
3. ✅ Users show policy assignment in `Get-CsUserPolicyAssignment`
4. ✅ After 30 minutes: API calls succeed with specified organizers
5. ✅ Meeting organizers can create breakout rooms in Teams UI

## 🎯 Next Steps

After successful policy creation:

1. **Wait 30 minutes** for propagation
2. **Test API endpoint** with different organizers
3. **Update your application code** to use `/users/{userId}/onlineMeetings`
4. **Train organizers** on creating breakout rooms in Teams UI
5. **Monitor and maintain** policy assignments

---

## 📞 Support

For issues with:
- **This script**: Check troubleshooting section above
- **Microsoft Graph API**: Refer to [Microsoft Graph documentation](https://docs.microsoft.com/en-us/graph/)
- **Teams Administration**: Contact your Microsoft 365 administrator

---

**⚠️ Important Limitation**: Even after this setup, breakout rooms must still be created manually through the Teams UI. There is currently no API to create breakout rooms programmatically.