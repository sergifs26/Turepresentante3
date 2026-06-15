# Statusline: muestra las skills activas del proyecto (.claude\skills).
# Claude Code envia un JSON por stdin; lo leemos para localizar la raiz del proyecto.
$ErrorActionPreference = 'SilentlyContinue'

# Raiz del proyecto = carpeta padre de skills-library (donde vive este script).
$projectRoot = Split-Path (Split-Path $PSCommandPath -Parent) -Parent

# Si el JSON de stdin trae el dir de trabajo, lo preferimos.
try {
  $raw = [Console]::In.ReadToEnd()
  if ($raw) {
    $j = $raw | ConvertFrom-Json
    $cwd = $j.workspace.current_dir
    if (-not $cwd) { $cwd = $j.cwd }
    if ($cwd -and (Test-Path (Join-Path $cwd '.claude\skills'))) { $projectRoot = $cwd }
  }
} catch { }

$skillsDir = Join-Path $projectRoot '.claude\skills'
$libDir    = Join-Path $projectRoot 'skills-library'

if (Test-Path $skillsDir) {
  $skills = Get-ChildItem -Path $skillsDir -Directory | Select-Object -ExpandProperty Name | Sort-Object
} else {
  $skills = @()
}

# Total de skills disponibles en la biblioteca (carpetas con SKILL.md).
$total = 0
if (Test-Path $libDir) {
  $total = (Get-ChildItem -Path $libDir -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue).Count
}

if ($skills.Count -eq 0) {
  Write-Output ("[*] Skills activas: 0 / {0} disponibles  (activar.ps1 -Menu)" -f $total)
} else {
  Write-Output ("[*] Activas {0}/{1}: {2}" -f $skills.Count, $total, ($skills -join ', '))
}
