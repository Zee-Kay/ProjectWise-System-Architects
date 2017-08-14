## Check storage areas
Get-PWStorage

## Create new storage area
New-PWStorage -Name Storage2 -Description Storage2 -Path 'C:\PW Storage\PW_NA_2' -Type WindowsFileSystem -HostName 'W12R2PWDI.bentley.com'
New-PWStorage -Name Storage3 -Description Storage3 -Path 'C:\PW Storage\PW_NA_3' -Type WindowsFileSystem -HostName 'W12R2PWDI.bentley.com'
New-PWStorage -Name Storage4 -Description Storage4 -Path 'C:\PW Storage\PW_NA_4' -Type WindowsFileSystem -HostName 'W12R2PWDI.bentley.com'

## Check storage areas again
Get-PWStorage

## Get folder tree and storage area details
$FolderTree = Get-PWFolders -FolderPath 'Permissions Testing Confidential' -Slow
$FolderTree | Select-Object FullPath, Storage, StorageID | ogv

# Already deleted displays if there is nothing in the folders
Update-PWStorageAreaForProjectTree -FolderPath 'Permissions Testing Confidential\Folder 2' -NewStorageArea Storage2 -JustOne -UseAdminPaths -Verbose
Update-PWStorageAreaForProjectTree -FolderPath 'Permissions Testing Confidential\Folder 3' -NewStorageArea Storage3 -UseAdminPaths -Verbose
Update-PWStorageAreaForProjectTree -FolderPath 'Permissions Testing Confidential\Confidential' -NewStorageArea Storage4 -DoNotDeleteFromSourceStorage -UseAdminPaths -Verbose

## Get folder tree and storage area details
$FolderTree = Get-PWFolders -FolderPath 'Permissions Testing Confidential' -Slow
$FolderTree | Select-Object FullPath, Storage, StorageID | Out-GridView

# Reset
Update-PWStorageAreaForProjectTree -FolderPath 'Permissions Testing Confidential' -NewStorageArea Storage -UseAdminPaths
$FolderTree = Get-PWFolders -FolderPath 'Permissions Testing Confidential' -Slow
$FolderTree | Select-Object FullPath, Storage, StorageID
Remove-PWStorage -StorageID 21
Remove-PWStorage -StorageID 22 -Force
Remove-PWStorage -StorageID 24 -Force