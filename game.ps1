Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:count = 0
$arquivoTxt = Join-Path $PSScriptRoot "quebras.txt"

if (Test-Path $arquivoTxt) {
    $script:count = [int](Get-Content $arquivoTxt -ErrorAction SilentlyContinue)
} else {
    "0" | Out-File -FilePath $arquivoTxt -Encoding utf8
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Quebras"
$form.ClientSize = New-Object System.Drawing.Size(600, 400)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$labelCount = New-Object System.Windows.Forms.Label
$labelCount.Text = "Quebras: $script:count"
$labelCount.Location = New-Object System.Drawing.Point(10, 10)
$labelCount.AutoSize = $true
$labelCount.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelCount)

$labelVersion = New-Object System.Windows.Forms.Label
$labelVersion.Text = "v0.1"
$labelVersion.ForeColor = [System.Drawing.Color]::Gray
$labelVersion.Location = New-Object System.Drawing.Point(10, 375)
$labelVersion.AutoSize = $true
$labelVersion.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
$form.Controls.Add($labelVersion)

$btn = New-Object System.Windows.Forms.Button
$btn.Location = New-Object System.Drawing.Point(100, 60)
$btn.Size = New-Object System.Drawing.Size(400, 300)
$btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btn.FlatAppearance.BorderSize = 0

$pathNao = Join-Path $PSScriptRoot "madeira_nao.png"
$pathSim = Join-Path $PSScriptRoot "madeira_sim.png"

function Get-ColorImage($path) {
    if (Test-Path $path) {
        $tempImg = [System.Drawing.Image]::FromFile($path)
        $bmp = New-Object System.Drawing.Bitmap($tempImg.Width, $tempImg.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.DrawImage($tempImg, 0, 0, $tempImg.Width, $tempImg.Height)
        $g.Dispose()
        $tempImg.Dispose()
        return $bmp
    }
    return $null
}

$imgNao = Get-ColorImage $pathNao
$imgSim = Get-ColorImage $pathSim

if ($imgNao) {
    $btn.Image = $imgNao
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500

$timer.Add_Tick({
    $timer.Stop()
    if ($imgNao) {
        $btn.Image = $imgNao
    }
    $btn.Enabled = $true
})

$btn.Add_Click({
    $btn.Enabled = $false
    if ($imgSim) {
        $btn.Image = $imgSim
    }
    $script:count++
    $labelCount.Text = "Quebras: $script:count"
    $script:count | Out-File -FilePath $arquivoTxt -Encoding utf8
    $timer.Start()
})

$form.Controls.Add($btn)
$form.Add_FormClosing({
    if ($imgNao) { $imgNao.Dispose() }
    if ($imgSim) { $imgSim.Dispose() }
})

[System.Windows.Forms.Application]::Run($form)
