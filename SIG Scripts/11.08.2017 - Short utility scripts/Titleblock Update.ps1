# Get document
$Doc = Get-PWDocumentsBySearch -FolderPath 'Titleblocks' -GetAttributes -Slow -JustThisFolder

# Look at the title attributes
$Doc.Attributes.Title1
$Doc.Attributes.Title2
$Doc.Attributes.Title3
$Doc.Attributes.Title4

# Update the title attributes
Update-PWDocumentAttributes -InputDocuments $Doc -Attributes @{Title1 = 'OLDTitle1';Title2 = 'OLDTitle2';Title3 = 'OLDTitle3';Title4 = 'OLDTitle4'}

# Get document again
$Doc = Get-PWDocumentsBySearch -FolderPath 'Titleblocks' -GetAttributes -Slow -JustThisFolder

# Check attributes have updated
$Doc.Attributes.Title1
$Doc.Attributes.Title2
$Doc.Attributes.Title3
$Doc.Attributes.Title4

# Attribute exchange is configured to update on Open, CheckOut, CopyOut, and Export
# Export doc before updating titleblocks
Export-PWDocuments -ProjectWiseFolder 'Titleblocks' -OutputFolder 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017' -JustOneFolder
Invoke-Item -Path 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017\Titleblock.cel'

# Rename the doc so we can export without overwriting
Rename-Item -Path 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017\Titleblock.cel' -NewName TitleblockOld.cel

# Update titleblocks
# This is one line below is all that's required, all the rest is just the proof
CheckOut-PWDocuments -InputDocument $Doc | CheckIn-PWDocumentsOrFree
# Just an example
# Could do this with a saved search or whole folder of documents or as a scheduled task

# Export doc after updating titleblocks
Export-PWDocuments -ProjectWiseFolder 'Titleblocks' -OutputFolder 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017' -JustOneFolder
Invoke-Item -Path 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017\Titleblock.cel'

# Remove items for reset
Remove-Item -Path 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017\TitleblockOld.cel'
Remove-Item -Path 'C:\Users\zachary.kerr\Documents\ProjectWise\PowerShell\SIG\Session 5 11.08.2017\Titleblock.cel'

# Mass update example
Get-PWDocumentsBySearch -FolderPath 'Titleblocks' | CheckOut-PWDocuments | CheckIn-PWDocumentsOrFree