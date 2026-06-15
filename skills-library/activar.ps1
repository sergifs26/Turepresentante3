<#
.SYNOPSIS
  Activa / desactiva skills de la biblioteca local (skills-library) en este proyecto.

.DESCRIPTION
  Las skills viven inactivas en .\skills-library\<repo>\<skill>.
  Activar una skill = copiarla a .\.claude\skills\<skill> (donde Claude Code la detecta).
  Desactivar = borrarla de .\.claude\skills\<skill>.

.EXAMPLE
  .\skills-library\activar.ps1 -List
  .\skills-library\activar.ps1 design
  .\skills-library\activar.ps1 design,brutalist-skill,ui-ux-pro-max
  .\skills-library\activar.ps1 -Off design
  .\skills-library\activar.ps1 -Status
#>

[CmdletBinding(DefaultParameterSetName='Activate')]
param(
  [Parameter(ParameterSetName='Activate', Position=0)]
  [string[]] $Skill,

  [Parameter(ParameterSetName='Activate')]
  [switch] $Off,

  [Parameter(ParameterSetName='List')]
  [switch] $List,

  [Parameter(ParameterSetName='Status')]
  [switch] $Status,

  [Parameter(ParameterSetName='Menu')]
  [switch] $Menu
)

$ErrorActionPreference = 'Stop'
$LibRoot     = $PSScriptRoot
$ProjectRoot = Split-Path $LibRoot -Parent
$ActiveDir   = Join-Path $ProjectRoot '.claude\skills'

function Get-LibrarySkills {
  Get-ChildItem -Path $LibRoot -Directory | ForEach-Object {
    $repo = $_.Name
    Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
      [pscustomobject]@{ Name = $_.Name; Repo = $repo; Path = $_.FullName }
    }
  }
}

function Test-Active([string]$name) {
  Test-Path (Join-Path $ActiveDir $name)
}

if ($List) {
  Get-LibrarySkills | Sort-Object Repo, Name |
    Format-Table @{N='Skill';E={$_.Name}}, @{N='Paquete';E={$_.Repo}},
                 @{N='Activa';E={ if (Test-Active $_.Name) {'SI'} else {'-'} }} -AutoSize
  return
}

if ($Status) {
  if (Test-Path $ActiveDir) {
    $active = Get-ChildItem $ActiveDir -Directory -ErrorAction SilentlyContinue
    if ($active) {
      Write-Host "Skills activas ($($active.Count)):" -ForegroundColor Green
      $active | ForEach-Object { Write-Host "  + $($_.Name)" }
    } else { Write-Host 'No hay skills activas.' -ForegroundColor Yellow }
  } else { Write-Host 'No hay skills activas (no existe .claude\skills).' -ForegroundColor Yellow }
  return
}

if ($Menu) {
  $all = Get-LibrarySkills | Sort-Object Repo, Name
  $i = 0
  $index = @{}
  $lastRepo = ''
  Write-Host ''
  Write-Host '=== Skills disponibles (escribe los numeros a activar, separados por coma) ===' -ForegroundColor Cyan
  foreach ($it in $all) {
    if ($it.Repo -ne $lastRepo) {
      Write-Host ''
      Write-Host "-- $($it.Repo) --" -ForegroundColor DarkCyan
      $lastRepo = $it.Repo
    }
    $i++
    $index[$i] = $it.Name
    $mark = if (Test-Active $it.Name) { '[ON] ' } else { '     ' }
    $color = if (Test-Active $it.Name) { 'Green' } else { 'Gray' }
    Write-Host ("{0}{1,3}. {2}" -f $mark, $i, $it.Name) -ForegroundColor $color
  }
  Write-Host ''
  $sel = Read-Host 'Numeros a activar (Enter para salir)'
  if (-not $sel) { return }
  $picked = @()
  foreach ($tok in ($sel -split '[,\s]+')) {
    $tok = $tok.Trim()
    if ($tok -match '^\d+$' -and $index.ContainsKey([int]$tok)) { $picked += $index[[int]$tok] }
  }
  if ($picked.Count -eq 0) { Write-Host 'Nada seleccionado.' -ForegroundColor Yellow; return }
  $Skill = $picked
}

if (-not $Skill -or $Skill.Count -eq 0) {
  Write-Host 'Uso: activar.ps1 <skill[,skill2,...]> | -Off <skill> | -List | -Status | -Menu' -ForegroundColor Cyan
  return
}

$lib = Get-LibrarySkills

foreach ($s in $Skill) {
  $match = $lib | Where-Object { $_.Name -eq $s }

  if ($Off) {
    $target = Join-Path $ActiveDir $s
    if (Test-Path $target) {
      Remove-Item $target -Recurse -Force
      Write-Host "Desactivada: $s" -ForegroundColor Yellow
    } else {
      Write-Host "No estaba activa: $s" -ForegroundColor DarkGray
    }
    continue
  }

  if (-not $match) {
    Write-Host "No encontrada en la biblioteca: $s" -ForegroundColor Red
    continue
  }
  if ($match.Count -gt 1) {
    Write-Host "Nombre ambiguo '$s' en varios paquetes: $($match.Repo -join ', '). Borra duplicados o renombra." -ForegroundColor Red
    continue
  }

  if (-not (Test-Path $ActiveDir)) { New-Item -ItemType Directory -Path $ActiveDir -Force | Out-Null }
  $target = Join-Path $ActiveDir $s
  if (Test-Path $target) { Remove-Item $target -Recurse -Force }
  Copy-Item -Path $match.Path -Destination $target -Recurse -Force
  Write-Host "Activada: $s  (desde $($match.Repo))" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Reinicia Claude Code (o recarga skills) para que detecte los cambios.' -ForegroundColor Cyan
