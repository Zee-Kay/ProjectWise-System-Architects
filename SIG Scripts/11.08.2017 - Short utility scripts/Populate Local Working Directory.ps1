# Datasource Settings
$Datasource = 'W12R2PWDI:PW_NA'

# Logging settings
$LogPath = "$env:USERPROFILE" + "\AppData\Local\Bentley\Logs\PowerShellLogging.txt"
$Task = "Populate Local Working Directory - "

#### Login to datasource

New-PWLogin -DatasourceName $Datasource

if (!(Get-PWCurrentDatasource))
{
    "$(Get-Date) " + "[ERROR] " + $Task + "Could not log in to $Datasource as $env:USERDOMAIN\$env:USERNAME." | Out-File -FilePath $LogPath -Append
    "$(Get-Date) " + "[INFO] " + $Task + "Login has failed, aborting script." | Out-File -FilePath $LogPath -Append
    break
}

#### Pull back documents
try
{
    $Documents = Get-PWDocumentsBySearch -Attributes @{MarkForCopyOut = 1} -ErrorVariable DocumentsError -ErrorAction Stop
}
catch
{
    "$(Get-Date) " + "[ERROR] " + $Task + $DocumentsError.ErrorRecord + "." | Out-File -FilePath $LogPath -Append
    "$(Get-Date) " + "[INFO] " + $Task + "Documents have not been returned, aborting script." | Out-File -FilePath $LogPath -Append
    Undo-PWLogin
    break
}


#### Copy out files
# Doesn't return error messages just yet
try
{
    $Documents | CheckOut-PWDocuments -CopyOut -ErrorAction Stop -ErrorVariable CopyOutError
}
catch
{
    "$(Get-Date) " + "[ERROR] " + $Task + $CopyOutError.ErrorRecord + "." | Out-File -FilePath $LogPath -Append
    "$(Get-Date) " + "[INFO] " + $Task + "Documents have not been copied out, aborting script." | Out-File -FilePath $LogPath -Append
    Undo-PWLogin
    break    
}

#### Logout
Undo-PWLogin -ErrorAction Stop -ErrorVariable LogoutError


############## Bonus Fetchfiles - can use this on a caching server
<#
CheckOut-PWDocuments -InputDocument $Documents -CopyOut -RemoveCopies
#>