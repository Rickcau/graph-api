# Create App Registration in Azure Portal

## Step 1: Access App Registrations

1. **Go to Azure Portal**: https://portal.azure.com
2. **Search**: Type "App registrations" in the top search bar
3. **Select**: "App registrations" from the results
4. **Click**: "New registration"

## Step 2: Register the Application

### Basic Information
- **Name**: `xMatters Teams Integration` (or your preferred name)
- **Supported account types**: 
  - Select "Accounts in this organizational directory only (Single tenant)"
- **Redirect URI**: 
  - Leave blank for now (not needed for client credentials flow)

**Click "Register"**

## Step 3: Note Important Values

After registration, you'll see the app overview. **Copy and save these values**:

```
Application (client) ID: [guid - save this]
Directory (tenant) ID: [guid - save this]
Object ID: [guid - for reference]
```

## Step 4: Create Client Secret

1. **Navigate**: Go to "Certificates & secrets" in the left menu
2. **Click**: "New client secret"
3. **Configure**:
   - **Description**: `xMatters API Secret`
   - **Expires**: Choose appropriate duration (6 months, 12 months, etc.)
4. **Click**: "Add"
5. **IMPORTANT**: **Copy the secret VALUE immediately** - it won't be shown again

```
Client Secret Value: [string - save this immediately]
```

## Step 5: Add API Permissions

1. **Navigate**: Go to "API permissions" in the left menu
2. **Click**: "Add a permission"
3. **Select**: "Microsoft Graph"
4. **Choose**: "Application permissions" (NOT Delegated permissions)

### Add Required Permissions

**Add these application permissions one by one:**

1. **OnlineMeetings.ReadWrite.All**
   - Expand "OnlineMeetings"
   - Check "OnlineMeetings.ReadWrite.All"
   - Click "Add permissions"

2. **User.Read.All** (to look up user information)
   - Click "Add a permission" again
   - Select "Microsoft Graph" → "Application permissions"
   - Expand "User"
   - Check "User.Read.All"
   - Click "Add permissions"

### Your permissions list should show:
```
✓ Microsoft Graph - OnlineMeetings.ReadWrite.All (Application)
✓ Microsoft Graph - User.Read.All (Application)
```

## Step 6: Grant Admin Consent

**CRITICAL**: Application permissions require admin consent

1. **Click**: "Grant admin consent for [Your Organization]"
2. **Confirm**: Click "Yes" in the popup
3. **Verify**: Green checkmarks should appear next to both permissions

### Status should show:
```
✓ OnlineMeetings.ReadWrite.All - Granted for [org]
✓ User.Read.All - Granted for [org]
```

## Step 7: Configure Authentication (Optional)

For completeness, go to "Authentication":
- **Platform configurations**: None needed for client credentials
- **Advanced settings**: 
  - Allow public client flows: **No**

## Step 8: Summary - Values You Need

Save these values for your application:

```json
{
  "tenantId": "your-tenant-id-guid",
  "clientId": "your-client-id-guid", 
  "clientSecret": "your-secret-value",
  "scope": "https://graph.microsoft.com/.default"
}
```

## Step 9: Test Authentication

You can test your app registration with this HTTP request:

```http
POST https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&
client_id={client-id}&
client_secret={client-secret}&
scope=https://graph.microsoft.com/.default
```

**Successful Response:**
```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "access_token": "eyJ0eXAiOiJKV1QiLCJub25jZSI6Ij..."
}
```

## Common Issues and Solutions

### Issue: "Access denied" when getting token
- **Cause**: Admin consent not granted
- **Fix**: Go back to API permissions → Grant admin consent

### Issue: "Invalid client" error  
- **Cause**: Wrong client ID or secret
- **Fix**: Verify values copied correctly from Azure Portal

### Issue: "Permission denied" when calling Graph API
- **Cause**: Missing application access policy
- **Fix**: Create the PowerShell policy (next step after app registration)

## Next Steps

After completing the app registration:

1. **✅ App Registration Complete**
2. **⏭️ Next**: Create Application Access Policy via PowerShell
3. **⏭️ Then**: Update xMatters to use client credentials authentication
4. **⏭️ Finally**: Test creating meetings with specific organizers

## Security Notes

- **Client Secret**: Treat like a password - store securely
- **Permissions**: These are powerful - app can create meetings for any user granted the policy
- **Regular Rotation**: Consider rotating client secrets periodically
- **Principle of Least Privilege**: Only grant permissions you actually need

## Verification Checklist

Before proceeding to PowerShell policy setup:

- [ ] App registration created
- [ ] Client secret created and saved
- [ ] Application permissions added (not delegated)
- [ ] Admin consent granted (green checkmarks visible)
- [ ] Can successfully get access token via client credentials
- [ ] All IDs and secret values saved securely