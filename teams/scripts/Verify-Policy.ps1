# Connect to Teams
Connect-MicrosoftTeams

# Verify policy exists
Get-CsApplicationAccessPolicy -Identity "xMatters-TeamsPolicy"

# Verify user has policy assigned  
Get-CsUserPolicyAssignment -Identity "codewith@MngEnv364940.onmicrosoft.com" -PolicyType ApplicationAccessPolicy

# Show all users with this policy
Get-CsOnlineUser | Where-Object {$_.ApplicationAccessPolicy -eq "xMatters-TeamsPolicy"} | Select-Object UserPrincipalName