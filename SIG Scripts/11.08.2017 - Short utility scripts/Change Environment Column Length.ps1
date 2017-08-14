# Get columns for environment
$Columns = Get-PWEnvironmentColumns -EnvironmentName Simple
$Columns | Format-Table

# Change column name
Update-PWEnvironmentColumnName -Environment Simple -Column Storage -NewName DefinitelyNotStorage -Verbose

# Check columns again - cannot see change yet
$Columns = Get-PWEnvironmentColumns -EnvironmentName Simple
$Columns | Format-Table

# Logout and Login
Undo-PWLogin
New-PWLogin @NALogin

# Check columns again - can see change
$Columns = Get-PWEnvironmentColumns -EnvironmentName Simple
$Columns | Format-Table

# Change column length
Update-PWEnvironmentColumnWidth -Environment Simple -Column Testbbb -NewWidth 200 -Verbose

# Logout and Login
Undo-PWLogin
New-PWLogin @NALogin

# Check columns again
$Columns = Get-PWEnvironmentColumns -EnvironmentName Simple
$Columns | Format-Table