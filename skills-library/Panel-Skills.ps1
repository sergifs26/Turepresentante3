# Panel grafico para activar/desactivar PAQUETES de skills con un clic.
# Cada paquete (ruflo, taste-skill, etc.) se activa/desactiva entero.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ProjectRoot = Split-Path (Split-Path $PSCommandPath -Parent) -Parent
$LibRoot     = Join-Path $ProjectRoot 'skills-library'
$ActiveDir   = Join-Path $ProjectRoot '.claude\skills'

function Get-PackageSkills([string]$repo) {
  $repoDir = Join-Path $LibRoot $repo
  Get-ChildItem -Path $repoDir -Directory -ErrorAction SilentlyContinue | Where-Object {
    Test-Path (Join-Path $_.FullName 'SKILL.md')
  }
}
function Test-Active([string]$n) { Test-Path (Join-Path $ActiveDir $n) }

function Get-Packages {
  Get-ChildItem -Path $LibRoot -Directory | ForEach-Object {
    $skills = @(Get-PackageSkills $_.Name)
    if ($skills.Count -eq 0) { return }
    $active = @($skills | Where-Object { Test-Active $_.Name }).Count
    [pscustomobject]@{ Repo = $_.Name; Total = $skills.Count; Active = $active; Skills = $skills }
  }
}

function Activate-Package($pkg) {
  if (-not (Test-Path $ActiveDir)) { New-Item -ItemType Directory -Path $ActiveDir -Force | Out-Null }
  foreach ($s in $pkg.Skills) {
    $target = Join-Path $ActiveDir $s.Name
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item -Path $s.FullName -Destination $target -Recurse -Force
  }
}
function Deactivate-Package($pkg) {
  foreach ($s in $pkg.Skills) {
    $target = Join-Path $ActiveDir $s.Name
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
  }
}

# --- Ventana ---
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Panel de Skills (por paquete)'
$form.Size = New-Object System.Drawing.Size(620, 520)
$form.StartPosition = 'CenterScreen'

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Location = New-Object System.Drawing.Point(14, 12)
$lblInfo.Size = New-Object System.Drawing.Size(580, 22)
$lblInfo.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblInfo)

$panel = New-Object System.Windows.Forms.FlowLayoutPanel
$panel.Location = New-Object System.Drawing.Point(14, 42)
$panel.Size = New-Object System.Drawing.Size(580, 380)
$panel.FlowDirection = 'TopDown'
$panel.WrapContents = $false
$panel.AutoScroll = $true
$form.Controls.Add($panel)

function Refresh-UI {
  $panel.Controls.Clear()
  $pkgs = Get-Packages | Sort-Object Repo
  $totalAll = ($pkgs | Measure-Object -Property Total -Sum).Sum
  $actAll   = ($pkgs | Measure-Object -Property Active -Sum).Sum
  $lblInfo.Text = "Activas: $actAll / $totalAll skills    (un clic activa el paquete entero)"

  foreach ($pkg in $pkgs) {
    $row = New-Object System.Windows.Forms.Panel
    $row.Size = New-Object System.Drawing.Size(545, 52)
    $row.BorderStyle = 'FixedSingle'

    $allOn = ($pkg.Active -eq $pkg.Total)
    $someOn = ($pkg.Active -gt 0)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Location = New-Object System.Drawing.Point(10, 8)
    $lbl.Size = New-Object System.Drawing.Size(300, 36)
    $estado = if ($allOn) { 'ACTIVO' } elseif ($someOn) { "$($pkg.Active)/$($pkg.Total) activas" } else { 'inactivo' }
    $lbl.Text = "$($pkg.Repo)`n$($pkg.Total) skills  -  $estado"
    $lbl.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    if ($allOn) { $lbl.ForeColor = [System.Drawing.Color]::ForestGreen }
    elseif ($someOn) { $lbl.ForeColor = [System.Drawing.Color]::DarkGoldenrod }
    $row.Controls.Add($lbl)

    $btnOn = New-Object System.Windows.Forms.Button
    $btnOn.Text = 'Activar todo'
    $btnOn.Location = New-Object System.Drawing.Point(320, 10)
    $btnOn.Size = New-Object System.Drawing.Size(105, 32)
    $btnOn.Tag = $pkg
    $btnOn.Enabled = -not $allOn
    $btnOn.add_Click({ Activate-Package $this.Tag; Refresh-UI }.GetNewClosure())
    $row.Controls.Add($btnOn)

    $btnOff = New-Object System.Windows.Forms.Button
    $btnOff.Text = 'Quitar todo'
    $btnOff.Location = New-Object System.Drawing.Point(432, 10)
    $btnOff.Size = New-Object System.Drawing.Size(100, 32)
    $btnOff.Tag = $pkg
    $btnOff.Enabled = $someOn
    $btnOff.add_Click({ Deactivate-Package $this.Tag; Refresh-UI }.GetNewClosure())
    $row.Controls.Add($btnOff)

    $panel.Controls.Add($row)
  }
}

$btnReload = New-Object System.Windows.Forms.Button
$btnReload.Text = 'Avisar: recargar Claude Code'
$btnReload.Location = New-Object System.Drawing.Point(14, 434)
$btnReload.Size = New-Object System.Drawing.Size(230, 34)
$btnReload.add_Click({
  [System.Windows.Forms.MessageBox]::Show('Tras activar/quitar paquetes, reinicia o recarga Claude Code para que detecte los cambios.', 'Panel de Skills') | Out-Null
})
$form.Controls.Add($btnReload)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = 'Cerrar'
$btnClose.Location = New-Object System.Drawing.Point(494, 434)
$btnClose.Size = New-Object System.Drawing.Size(100, 34)
$btnClose.add_Click({ $form.Close() })
$form.Controls.Add($btnClose)

Refresh-UI
[void]$form.ShowDialog()
