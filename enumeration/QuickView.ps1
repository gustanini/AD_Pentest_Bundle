# QuickView by Gustanini
# Github: https://github.com/gustanini

# Set the file path to save the output
$outputFilePath = ".\output.txt"

# ANSI escape sequence for red color
$redColor = [char]27 + "[31m"

# ANSI escape sequence for green color
$greenColor = [char]27 + "[32m"

# ANSI escape sequence to reset color
$resetColor = [char]27 + "[0m"

# Function to execute a command and return the output as a formatted string
function ExecuteCommand($command, $commandName) {
    $output = Invoke-Expression -Command $command
    $formattedOutput = $output | Out-String
    $formattedCommandName = "$greenColor$commandName$resetColor"
    return "`nCommand: $formattedCommandName`n`n$formattedOutput`n"
}

# Function to display a progress bar
function Show-ProgressBar($current, $total) {
    $progressBarWidth = 40
    $completedWidth = $current / $total * $progressBarWidth
    $remainingWidth = $progressBarWidth - $completedWidth

    $progressBar = "[" + "#" * $completedWidth + " " * $remainingWidth + "]"
    Write-Host "`rProgress: $progressBar" -NoNewline
}

# Insert your ASCII art title here
echo ""

# Check if the -Thorough flag is provided
$thoroughFlag = $false
if ($args -contains "-Thorough") {
    $thoroughFlag = $true
}

# Check if the -h or --help flag is provided
$helpFlag = $args -contains "-h" -or $args -contains "--help"

if ($helpFlag) {
    # Display help section
    Write-Host "Usage: .\QuickView.ps1 [-Thorough] [-h | --help]"
    Write-Host
    Write-Host "Optional Arguments:"
    Write-Host "  -Thorough     Execute additional commands (Find-LocalAdminAccess, Invoke-UserHunter, Find-DomainShare)."
    Write-Host "  -h, --help    Display this help message."
    exit
}

# Array of commands to execute
$commands = @(
    @{ Command = "Get-NetDomain"; CommandName = "Get-NetDomain" },
    @{ Command = "Get-NetUser -UACFilter NOT_ACCOUNTDISABLE | Select-Object samaccountname, description"; CommandName = "Get-NetUser" },
    @{ Command = "Get-DomainUser -SPN | Select-Object name, description, objectsid, serviceprincipalname"; CommandName = "Get-DomainUser -SPN"},
    @{ Command = "Get-NetGroup | Select-Object samaccountname, admincount"; CommandName = "Get-NetGroup" },
    @{ Command = "net accounts"; CommandName = "net accounts" },
    @{ Command = "Get-NetComputer | Select-Object operatingsystem, dnshostname"; CommandName = "Get-NetComputer" }
)

# Add optional commands if -Thorough flag is provided
if ($thoroughFlag) {
    $commands += @(
        @{ Command = "Invoke-UserHunter -CheckAccess"; CommandName = "Invoke-UserHunter" },
        @{ Command = "Find-LocalAdminAccess"; CommandName = "Find-LocalAdminAccess" },
        @{ Command = "Find-DomainShare"; CommandName = "Find-DomainShare" }
    )
}

# Execute commands
$totalCommands = $commands.Count
$currentCommand = 1

Write-Host "$redColor"
echo "            _     __        _           "
echo " ___ ___ __(_)___/ /___  __(_)__ _    __"
echo "/ _ '/ // / / __/  '_/ |/ / / -_) |/|/ /"
echo "\_  /\___/_/\__/_/\_\|___/_/\__/|__v__/ "
echo " /_/                                    "
Write-Host $resetColor

Write-Host "Executing commands..."

ForEach ($cmd in $commands) {
    $output = ExecuteCommand -command $cmd.Command -commandName $cmd.CommandName
    Write-Output $output | Out-File -FilePath $outputFilePath -Append
    Show-ProgressBar -current $currentCommand -total $totalCommands
    $currentCommand++
}

# Display completion message
Write-Output "`nScript execution completed. Output saved to: $outputFilePath"
