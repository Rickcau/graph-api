# Complete Teams Application Access Policy Setup Script
# Run this as a Teams Administrator or Global Administrator

param(
    [Parameter(Mandatory=$true, HelpMessage="Enter your Azure App Registration Client ID")]
    [string]$AppClientId,
    
    [Parameter(Mandatory=$false, HelpMessage="List of user emails to grant policy to (leave empty for global)")]
    [string[]]$UserEmails = @(),
    
    [Parameter(Mandatory=$false, HelpMessage="Policy name")]
    [string]$PolicyName = "xMatters-TeamsPolicy",
    
    [Parameter(Mandatory=$false, HelpMessage="Apply policy globally instead of to specific users")]
    [switch]$GlobalPolicy
)

Write-Host "=== Teams Application Access Policy Setup ===" -ForegroundColor Cyan
Write-Host "App Client ID: $AppClientId" -ForegroundColor Yellow
Write-Host "Policy Name: $PolicyName" -ForegroundColor Yellow

# Step 1: Check and install MicrosoftTeams module
Write-Host "`n[1/6] Checking MicrosoftTeams PowerShell module..." -ForegroundColor Green

if (!(Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Write-Host "MicrosoftTeams module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name MicrosoftTeams -Force -AllowClobber -Scope CurrentUser
        Write-Host "✓ MicrosoftTeams module installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install MicrosoftTeams module: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "✓ MicrosoftTeams module already installed" -ForegroundColor Green
    
    # Check if update is needed
    try {
        Update-Module -Name MicrosoftTeams -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Module updated to latest version" -ForegroundColor Green
    }
    catch {
        Write-Host "ℹ Module update skipped (already latest or no permission)" -ForegroundColor Yellow
    }
}

# Step 2: Connect to Microsoft Teams
Write-Host "`n[2/6] Connecting to Microsoft Teams..." -ForegroundColor Green

try {
    Connect-MicrosoftTeams -ErrorAction Stop
    Write-Host "✓ Connected to Microsoft Teams successfully" -ForegroundColor Green
    
    # Verify connection and show tenant info
    $TenantInfo = Get-CsTenant | Select-Object DisplayName, TenantId
    Write-Host "✓ Connected to tenant: $($TenantInfo.DisplayName) ($($TenantInfo.TenantId))" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Microsoft Teams: $($_.Exception.Message)"
    Write-Error "Please ensure you have Teams Administrator or Global Administrator permissions"
    exit 1
}

# Step 3: Check if policy already exists
Write-Host "`n[3/6] Checking existing policies..." -ForegroundColor Green

$ExistingPolicy = Get-CsApplicationAccessPolicy -Identity $PolicyName -ErrorAction SilentlyContinue

if ($ExistingPolicy) {
    Write-Host "⚠ Policy '$PolicyName' already exists" -ForegroundColor Yellow
    Write-Host "Current App IDs: $($ExistingPolicy.AppIds -join ', ')" -ForegroundColor Yellow
    
    $Overwrite = Read-Host "Do you want to update it with the new App ID? (y/n)"
    if ($Overwrite -eq 'y' -or $Overwrite -eq 'Y') {
        try {
            Set-CsApplicationAccessPolicy -Identity $PolicyName -AppIds $AppClientId -Description "Allow xMatters to create Teams meetings on behalf of users (Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
            Write-Host "✓ Policy updated successfully" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to update policy: $($_.Exception.Message)"
            exit 1
        }
    } else {
        Write-Host "Using existing policy without changes" -ForegroundColor Yellow
    }
} else {
    # Step 4: Create new policy
    Write-Host "`n[4/6] Creating application access policy..." -ForegroundColor Green
    
    try {
        New-CsApplicationAccessPolicy -Identity $PolicyName -AppIds $AppClientId -Description "Allow xMatters to create Teams meetings on behalf of users (Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
        Write-Host "✓ Policy '$PolicyName' created successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create policy: $($_.Exception.Message)"
        exit 1
    }
}

# Step 5: Grant policy to users or globally
Write-Host "`n[5/6] Assigning policy..." -ForegroundColor Green

if ($GlobalPolicy) {
    Write-Host "Applying policy globally to all users..." -ForegroundColor Yellow
    try {
        Grant-CsApplicationAccessPolicy -PolicyName $PolicyName -Global
        Write-Host "✓ Policy granted globally to all users" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to grant policy globally: $($_.Exception.Message)"
        exit 1
    }
}
elseif ($UserEmails.Count -gt 0) {
    Write-Host "Granting policy to specified users..." -ForegroundColor Yellow
    $SuccessCount = 0
    $FailCount = 0
    
    foreach ($User in $UserEmails) {
        try {
            Grant-CsApplicationAccessPolicy -PolicyName $PolicyName -Identity $User.Trim()
            Write-Host "✓ Policy granted to: $User" -ForegroundColor Green
            $SuccessCount++
        }
        catch {
            Write-Host "✗ Failed to grant policy to: $User - $($_.Exception.Message)" -ForegroundColor Red
            $FailCount++
        }
    }
    
    Write-Host "`nSummary: $SuccessCount successful, $FailCount failed" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Yellow" })
}
else {
    Write-Host "⚠ No users specified and GlobalPolicy not set" -ForegroundColor Yellow
    Write-Host "Please specify users or use -GlobalPolicy switch" -ForegroundColor Yellow
    
    $Choice = Read-Host "Do you want to apply globally to all users? (y/n)"
    if ($Choice -eq 'y' -or $Choice -eq 'Y') {
        try {
            Grant-CsApplicationAccessPolicy -PolicyName $PolicyName -Global
            Write-Host "✓ Policy granted globally to all users" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to grant policy globally: $($_.Exception.Message)"
            exit 1
        }
    } else {
        Write-Host "Policy created but not assigned to any users" -ForegroundColor Yellow
    }
}

# Step 6: Verify setup
Write-Host "`n[6/6] Verifying setup..." -ForegroundColor Green

try {
    $PolicyDetails = Get-CsApplicationAccessPolicy -Identity $PolicyName
    Write-Host "✓ Policy verification:" -ForegroundColor Green
    Write-Host "  Name: $($PolicyDetails.Identity)" -ForegroundColor White
    Write-Host "  Description: $($PolicyDetails.Description)" -ForegroundColor White
    Write-Host "  App IDs: $($PolicyDetails.AppIds -join ', ')" -ForegroundColor White
}
catch {
    Write-Error "Failed to verify policy: $($_.Exception.Message)"
}

# Show next steps
Write-Host "`n=== SETUP COMPLETE ===" -ForegroundColor Cyan
Write-Host "✓ Application Access Policy created and assigned" -ForegroundColor Green
Write-Host ""
Write-Host "⏰ IMPORTANT: Wait 30 minutes for policy propagation before testing" -ForegroundColor Yellow
Write-Host ""
Write-Host "🧪 Test with this API call:" -ForegroundColor Cyan
Write-Host "POST https://graph.microsoft.com/v1.0/users/{user-email}/onlineMeetings" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Wait 30 minutes for policy to propagate" -ForegroundColor White
Write-Host "2. Test meeting creation with your application token" -ForegroundColor White
Write-Host "3. Verify the correct user becomes the meeting organizer" -ForegroundColor White
Write-Host "4. That user can now create breakout rooms in Teams UI" -ForegroundColor White
Write-Host ""

# Cleanup: Disconnect from Teams
Write-Host "Disconnecting from Microsoft Teams..." -ForegroundColor Gray
Disconnect-MicrosoftTeams

Write-Host "Script completed successfully! 🎉" -ForegroundColor Green