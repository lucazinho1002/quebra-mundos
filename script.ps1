Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Quebra Mundos"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

$lblTitulo = New-Object System.Windows.Forms.Label
$lblTitulo.Text = "QUEBRA MUNDOS"
$lblTitulo.Font = New-Object System.Drawing.Font("Arial", 26, [System.Drawing.FontStyle]::Bold)
$lblTitulo.Size = New-Object System.Drawing.Size(500, 60)
$lblTitulo.Location = New-Object System.Drawing.Point(50, 110)
$lblTitulo.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($lblTitulo)

$btnJogar = New-Object System.Windows.Forms.Button
$btnJogar.Text = "JOGAR"
$btnJogar.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$btnJogar.Size = New-Object System.Drawing.Size(120, 40)
$btnJogar.Location = New-Object System.Drawing.Point(240, 200)

# Garante que o caminho base está correto mesmo se executado fora do contexto padrão
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$global:jogoEscolhido = Join-Path $scriptDir "game.ps1"

$btnJogar.Add_Click({
    $form.Tag = "JOGAR"
    $form.Close()
})

$form.Controls.Add($btnJogar)

$lblVersao = New-Object System.Windows.Forms.Label
$lblVersao.Text = "v0.1"
$lblVersao.Font = New-Object System.Drawing.Font("Arial", 9)
$lblVersao.ForeColor = [System.Drawing.Color]::Gray
$lblVersao.Size = New-Object System.Drawing.Size(60, 20)
$lblVersao.Location = New-Object System.Drawing.Point(10, 335)
$form.Controls.Add($lblVersao)

[void]$form.ShowDialog()

if ($form.Tag -eq "JOGAR") {
    if (Test-Path $global:jogoEscolhido) {
        Start-Process powershell.exe -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$global:jogoEscolhido`""
    } else {
    }
}