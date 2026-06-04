# ~ History.
Set-PSReadLineOption -HistorySavePath "$HOME\.ps_history"
Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistoryNoDuplicates

# ~ Environment.
$env:EDITOR = "code"
$env:VISUAL = "code"

# ~ Aliases.
# Navigation.
Set-Alias -Name cls -Value Clear-Host
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function mkdirp { New-Item -ItemType Directory -Force -Path @args }

# Git.
function gs { git status @args }
function gd { git diff @args }
function gl { git log --oneline --graph @args }
function gp { git push -u origin main @args }
function ga { git add . @args }

# ~ Source powershell-specific config.
$pwshConfigDir = "$HOME\.config\shell\powershell"
if (Test-Path $pwshConfigDir) {
    Get-ChildItem "$pwshConfigDir\*.ps1" | ForEach-Object { . $_.FullName }
}

# ~ Shell Integrations.
if (Get-Command zoxide -ErrorAction SilentlyContinue) { Invoke-Expression (& { (zoxide init powershell | Out-String) }) }
if (Get-Command fnm -ErrorAction SilentlyContinue) { fnm env --use-on-cd | Out-String | Invoke-Expression }
if (Get-Command starship -ErrorAction SilentlyContinue) { Invoke-Expression (&starship init powershell) }
