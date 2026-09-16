#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Create (or update) a GitHub release and attach backup-explorer.html.

.EXAMPLE
  ./scripts/release.ps1 v2.3.0
  ./scripts/release.ps1 v2.3.0 -Notes "Bug fixes"
  ./scripts/release.ps1 v2.3.0 -GenerateNotes
  ./scripts/release.ps1 v2.3.0 -AssetOnly
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^v?\d+\.\d+\.\d+')]
    [string]$Tag,

    [string]$Notes,

    [switch]$GenerateNotes,

    [switch]$AssetOnly,

    [switch]$Draft,

    [switch]$Prerelease
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

if (-not $Tag.StartsWith('v')) {
    $Tag = "v$Tag"
}

$html = Join-Path $repoRoot 'backup-explorer.html'
if (-not (Test-Path $html)) {
    throw "Missing backup-explorer.html in repo root."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is required. Install from https://cli.github.com/"
}

$releaseExists = $false
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
gh release view $Tag --json tagName 1>$null 2>$null
if ($LASTEXITCODE -eq 0) {
    $releaseExists = $true
}
$ErrorActionPreference = $prevEap

if ($AssetOnly) {
    if (-not $releaseExists) {
        throw "Release $Tag does not exist. Omit -AssetOnly to create it."
    }
    gh release upload $Tag $html --clobber
    if ($LASTEXITCODE -ne 0) { throw "Failed to upload asset to $Tag." }
    Write-Host "Attached backup-explorer.html to $Tag"
    gh release view $Tag --json url --jq .url
    exit 0
}

# Ensure annotated tag exists locally
$ErrorActionPreference = 'Continue'
git rev-parse "refs/tags/$Tag" 1>$null 2>$null
$tagMissing = $LASTEXITCODE -ne 0
$ErrorActionPreference = $prevEap
if ($tagMissing) {
    Write-Host "Creating tag $Tag at HEAD..."
    git tag -a $Tag -m $Tag
    if ($LASTEXITCODE -ne 0) { throw "Failed to create tag $Tag." }
}

Write-Host "Pushing tag $Tag..."
git push origin $Tag
if ($LASTEXITCODE -ne 0) { throw "Failed to push tag $Tag." }

if ($releaseExists) {
    Write-Host "Release $Tag already exists; uploading asset..."
    gh release upload $Tag $html --clobber
    if ($LASTEXITCODE -ne 0) { throw "Failed to upload asset to $Tag." }
} else {
    $createArgs = @('release', 'create', $Tag, $html, '--title', $Tag)
    if ($Draft) { $createArgs += '--draft' }
    if ($Prerelease) { $createArgs += '--prerelease' }

    if ($GenerateNotes) {
        $createArgs += '--generate-notes'
    } elseif ($Notes) {
        $createArgs += '--notes'
        $createArgs += $Notes
    } else {
        $createArgs += '--notes'
        $createArgs += "Release $Tag"
    }

    Write-Host "Creating release $Tag with backup-explorer.html..."
    & gh @createArgs
    if ($LASTEXITCODE -ne 0) { throw "Failed to create release $Tag." }
}

Write-Host "Done."
gh release view $Tag --json url,assets --jq '{url, assets: [.assets[].name]}'
