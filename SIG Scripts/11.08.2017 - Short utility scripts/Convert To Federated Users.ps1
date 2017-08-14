# Get Windows users on the Bentley domain
$Users = Get-PWUsersByMatch -SecProvider BENTLEY

# Check users
$Users | Select-Object UserName,Email,Type,SecProvider

# Convert to federated
foreach ($User in $Users)
{
    $User | Convert-PWUserToFederated -NewUserName $User.Email
}

# Check users
$FedUsers = Get-PWUser | Where-Object {$PSItem.Type -eq "FederatedIdentity"}
$FedUsers | Select-Object UserName,Email,Type,IdentityProvider

# Login (in pw explorer) and check users again to show Identity Provider
$FedUsers = Get-PWUser | Where-Object {$PSItem.Type -eq "FederatedIdentity"}
$FedUsers | Select-Object UserName,Email,Type,IdentityProvider

# Reset
foreach ($User in $FedUsers)
{
    $User.Type = 'WINDOWS'
    $User.SecProvider = 'BENTLEY'
    $User.Identity = ''
    $User.UserName = $User.Email.Substring(0,$User.Email.Length-12)
    Update-PWUser -User $User -ClearIdentityProvider
}