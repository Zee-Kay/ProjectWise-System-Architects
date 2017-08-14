##  Create a ProjectWise session for both the source datasource
##  and the target datasource
##  Be sure to log out of each session.

$PWLogin = @{
    UserName = 'admin';
    Password = Read-Host -Prompt 'Enter password: ' -AsSecureString
}
New-PWLogin -DataSourceName 'BMF_W2K12R2:PSTraining' @PWLogin
$PWSessionSource = Get-PWCurrentDSSession

New-PWLogin -DataSourceName 'BMF_W2K12R2:PSTrainingArchive' @PWLogin
$PWSessionTarget = Get-PWCurrentDSSession

## Should return the target datasource
Get-PWCurrentDatasource

## Switch to the source datasource
Set-PWDSSession -PWDSSession $PWSessionSource -Verbose

## Should return the source datasource
Get-PWCurrentDatasource


##  Export entire project to sqlite datasource.
$ProjectToArchive = 'BSI900 - Adelaide Tower'
$Path = 'D:\TEMP\Export\PSTraining'

##  Get document information
if($ProjectToArchive.Length -gt 0) {
    $pwDocs = Get-PWDocumentsBySearch -FolderPath $ProjectToArchive -GetAttributes
}

##  View documents that will be exported. 
##  Notice not all have physical files associated with them.
# $pwDocs | Out-GridView

##  Use splatting
$Export = @{
    OutputFolder = $Path;
    ProjectWiseFolder = $ProjectToArchive;
    OutputFileName = "$ProjectToArchive.sqlite";
}

Export-PWDocumentsToArchive @Export -Verbose


. 'C:\Users\brian.flaherty\Downloads\sqlitestudio-3.1.1\SQLiteStudio\SQLiteStudio.exe'


##  Review what was included in the archive
##  Table / Description
##  -----------------------
##  General_AuditTrail table
##  -- Contains all audit trail information pertaining to the included documents.
##  General_Documents_Table
##  -- Contains list of all documents with general attribute information.
##  General_EnvironmentAttributes
##  -- Contains list of environment attribute definitions for each environment associated with the archived project.
##  General_Environments
##  -- Contains list of environments associated with the archived project.
##  General_ProjectProperties
##  -- Contains list of each rich Project Type and project property definitions.
##  General_ProjectTypes
##  -- Contains list of Rich Project Types included in the archived project.
##  General_RichProjectProperties
##  -- Contains the rich project properties and values for each rich project in the archived project.
##  General_RichProjects
##  -- Contains a list of the Rich Projects within the overall project archived
##  General_Users
##  -- Contains a list of user information for all users associated with the project
##  General_Workflows
##  -- Contains list of workflows and states associated with the folders.
##  General_ZipFiles
##  -- Contains list of archived documents. Each document is compressed in a zip files
##     and stored in the database as a blob. There are no separate folders/documents.
##     The archive is completely self contained.
##  Simple
##  -- Document attributes

##  NOTE:  The archive does not contain any empty folders. *****


##  Access Control
##  There are a couple of ways to export the access control for a project.
##    The following will demonstrate one way.

##  Get all access control items (User/Group/UserList)
$foldersecurity = Get-PWFolderSecurity -InputFolder $ProjectToArchive
$foldersecurity | ft

##  Populate array lists with unique access control item information
##    This will be used to create groups and userlists in target datasource
$sourceGroups = New-Object System.Collections.ArrayList
$sourceUserLists = New-Object System.Collections.ArrayList

$dt = New-Object System.Data.DataTable
$dt.Columns.Add("Name")
$dt.Columns.Add("Description")
$dt.Columns.Add("Type")

foreach($item in $foldersecurity) {
    switch ($item.Type) 
    { 
        'group' {
            if($sourceGroups.Capacity -eq 0) {
                $sourceGroups.Add((Get-PWGroup -GroupName $item.Name))
            } elseif(-not($sourceGroups.GroupName.Contains($item.Name))){
                $sourceGroups.Add((get-pwuserlist -GroupName $item.Name))
            }
            break;
        } 
        'userlist' {
            if($sourceUserLists.Capacity -eq 0) {
                $sourceUserLists.Add((get-pwuserlist -UserListName $item.Name))
            } elseif(-not($sourceUserLists.UserListName.Contains($item.Name))){
                $sourceUserLists.Add((get-pwuserlist -UserListName $item.Name))
            }
            break;
        } 
    }
}

foreach($group in $sourceGroups) {
    $dr = $dt.NewRow()
    $dr["Name"] = $group.Name
    $dr["Description"] = $group.Description
    $dr["Type"] = "Group"
    $dt.Rows.Add($dr)
}

foreach($userlist in $sourceUserLists) {
    $dr = $dt.NewRow()
    $dr["Name"] = $userlist.Name
    $dr["Description"] = $userlist.Description
    $dr["Type"] = "UserList"
    $dt.Rows.Add($dr)
}

##  Export group and userlist information to be included with archive.
$dt | Export-Csv -Path ("$Path\$ProjectToArchive" + "_AccessControlGroupsUserLists.csv") -NoTypeInformation

##  Exports the project access control using the same functionality as
##    the Access Control tab within the PW Explorer client.
$ExportAccessControl = @{
    ExportFolder = $Path;
    ExportFileName = $ProjectToArchive + '_accesscontrol';
    InputFolder = $ProjectToArchive;
    #ExportFileExtension = 'csv';
    #Levels = 2;
}
Export-PWAccessControlToExcel @ExportAccessControl -AllLevels

##  We have all of the information required for the archive.
##  Close the ProjectWise source datasource connection.
Close-PWConnection


## Switch to the target datasource
Set-PWDSSession -PWDSSession $PWSessionTarget -Verbose

## Should return the source datasource
Get-PWCurrentDatasource

$targetUsers = Get-PWUser
$targetGroups = Get-PWGroup
$targetUserLists = Get-PWUserList


##  Import
$Import = @{
    InputFile = "D:\TEMP\Export\PSTraining\BSI900 - Adelaide Tower.sqlite";
    TargetProjectWiseFolder = 'Projects';
    DefaultStorage = 'Storage';
}
Import-PWDocumentsFromArchive @Import -Verbose

## Access Control
##   Create required groups and userlists
$groupsAndUserLists = Import-Csv -Path ("$Path\$ProjectToArchive" + "_AccessControlGroupsUserLists.csv") 

foreach($item in $groupsAndUserLists) {
    switch ($item.Type) 
    { 
        'group' {
            if(($targetGroups.Count -eq 0) -or 
                (-not ($targetGroups.GroupName.Contains($item.Name)))) {
                
                if([string]::IsNullOrEmpty($item.Description)) {
                    $description = $item.Name    
                } else {
                    $description = $item.Description
                }

                New-PWGroup -GroupName $item.Name -Description $description
                Add-PWGroupMember -GroupName $item.Name -UserName $PWLogin.UserName
            }
            break;
        } 
        'userlist' {
            if(($targetUserLists.Count -eq 0) -or 
                (-not ($targetUserLists.UserListName.Contains($item.Name)))) {

                if([string]::IsNullOrEmpty($item.Description)) {
                    $description = $item.Name    
                } else {
                    $description = $item.Description
                }

                New-PWUserList -UserListName $item.Name -Description $description -Type AccessControl
                $UserListID = Get-PWUserList -UserListName $item.Name
                $UserID = Get-PWUser -UserName $PWLogin.UserName 
                Add-PWUserListMember -ID $UserListID.ID -UserID $UserID.ID
            }
            break;
        } 
    }
}


$ImportAccessControl = @{
    ImportFileNamePath = "$Path\$ProjectToArchive" + '_accesscontrol.xlsx';
    InputFolder = "Projects\$ProjectToArchive";
}

Import-PWAccessControlFromExcel @ImportAccessControl

Close-PWConnection

