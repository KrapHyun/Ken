$ErrorActionPreference = "Stop"

$pluginName = "harness-codex"
$skillName = "harness"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$homeDir = $env:USERPROFILE

$pluginTarget = Join-Path $homeDir "plugins\$pluginName"
$skillTarget = Join-Path $homeDir ".codex\skills\$skillName"
$marketplacePath = Join-Path $homeDir ".agents\plugins\marketplace.json"

function Write-JsonFile {
  param(
    [string]$Path,
    [object]$Data
  )

  $parent = Split-Path $Path -Parent
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  $json = $Data | ConvertTo-Json -Depth 20
  [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
}

function Ensure-MarketplaceEntry {
  param(
    [string]$Path,
    [string]$Name
  )

  if (Test-Path $Path) {
    $payload = Get-Content $Path -Raw | ConvertFrom-Json
  } else {
    $payload = [ordered]@{
      name = "local-home-marketplace"
      interface = [ordered]@{
        displayName = "Local Home Plugins"
      }
      plugins = @()
    }
  }

  if (-not $payload.plugins) {
    if ($payload.PSObject.Properties.Name -contains "plugins") {
      $payload.plugins = @()
    } else {
      $payload | Add-Member -NotePropertyName plugins -NotePropertyValue @()
    }
  }

  $plugins = @($payload.plugins)
  $existing = @($plugins | Where-Object { $_.name -eq $Name })
  $newEntry = [ordered]@{
    name = $Name
    source = [ordered]@{
      source = "local"
      path = "./plugins/$Name"
    }
    policy = [ordered]@{
      installation = "AVAILABLE"
      authentication = "ON_INSTALL"
    }
    category = "Productivity"
  }

  if ($existing.Count -gt 0) {
    $plugins = @($plugins | ForEach-Object {
      if ($_.name -eq $Name) { $newEntry } else { $_ }
    })
  } else {
    $plugins = @($plugins + $newEntry)
  }

  $payload.plugins = @($plugins)
  Write-JsonFile -Path $Path -Data $payload
}

Write-Host "Installing global skill to $skillTarget"
if (Test-Path $skillTarget) {
  Remove-Item -LiteralPath $skillTarget -Recurse -Force
}
New-Item -ItemType Directory -Path (Split-Path $skillTarget -Parent) -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repoRoot "skills\$skillName") -Destination $skillTarget -Recurse -Force

Write-Host "Installing global plugin to $pluginTarget"
if (Test-Path $pluginTarget) {
  Remove-Item -LiteralPath $pluginTarget -Recurse -Force
}
New-Item -ItemType Directory -Path (Split-Path $pluginTarget -Parent) -Force | Out-Null
Copy-Item -LiteralPath $repoRoot -Destination $pluginTarget -Recurse -Force

Write-Host "Updating marketplace at $marketplacePath"
Ensure-MarketplaceEntry -Path $marketplacePath -Name $pluginName

Write-Host ""
Write-Host "Installed successfully."
Write-Host "Restart Codex to pick up the new global skill and plugin."
