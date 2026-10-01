param([Parameter(ValueFromRemainingArguments=$true)][string[]]$MoonArgs)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$localHome = Join-Path (Split-Path $root -Parent) '.tools/moonjmes-toolchain'
$localMoon = Join-Path $localHome 'bin/moon.exe'
if (Test-Path -LiteralPath $localMoon) {
  $env:MOON_HOME = $localHome
  $binary = $localMoon
} else {
  $binary = (Get-Command moon -ErrorAction Stop).Source
}
Push-Location $root
try {
  & $binary @MoonArgs
  $status = $LASTEXITCODE
} finally {
  Pop-Location
}
exit $status
