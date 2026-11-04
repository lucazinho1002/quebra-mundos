Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:count = 0
$script:tipoMaterial = "madeira"
$script:podeClicar = $true
$arquivoJson = Join-Path $PSScriptRoot "quebras.json"

if (Test-Path $arquivoJson) {
    try {
        $conteudo = Get-Content $arquivoJson -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        if ($null -ne $conteudo.pontos) {
            $script:count = [int]$conteudo.pontos
        }
        if ($null -ne $conteudo.tipo) {
            $script:tipoMaterial = [string]$conteudo.tipo
        }
    } catch {}
} else {
    if ($script:count -ge 30) { $script:tipoMaterial = "pedra" } else { $script:tipoMaterial = "madeira" }
    @{ pontos = $script:count; tipo = $script:tipoMaterial } | ConvertTo-Json | Out-File -FilePath $arquivoJson -Encoding utf8
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
$labelVersion.Text = "v0.2"
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

function Atualizar-Imagens {
    if ($imgNao) { $imgNao.Dispose() }
    if ($imgSim) { $imgSim.Dispose() }

    if ($script:count -ge 30) {
        $script:tipoMaterial = "pedra"
        $script:pathNao = Join-Path $PSScriptRoot "pedra_nao.png"
        $script:pathSim = Join-Path $PSScriptRoot "pedra_sim.png"
    } else {
        $script:tipoMaterial = "madeira"
        $script:pathNao = Join-Path $PSScriptRoot "madeira_nao.png"
        $script:pathSim = Join-Path $PSScriptRoot "madeira_sim.png"
    }

    $script:imgNao = Get-ColorImage $script:pathNao
    $script:imgSim = Get-ColorImage $script:pathSim

    if ($script:imgNao) {
        $btn.Image = $script:imgNao
    }
}

Atualizar-Imagens

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500

$timer.Add_Tick({
    $timer.Stop()
    if ($script:imgNao) {
        $btn.Image = $script:imgNao
    }
    $script:podeClicar = $true
})

$btn.Add_Click({
    if (-not $script:podeClicar) {
        return
    }

    $script:podeClicar = $false
    
    $eraMenorQue30 = ($script:count -lt 30)

    if ($script:count -ge 30) {
        $script:count += 2
    } else {
        $script:count += 1
    }

    if ($eraMenorQue30 -and $script:count -ge 30) {
        Atualizar-Imagens
    }

    if ($script:imgSim) {
        $btn.Image = $script:imgSim
    }

    $labelCount.Text = "Quebras: $script:count"
    
    @{ pontos = $script:count; tipo = $script:tipoMaterial } | ConvertTo-Json | Out-File -FilePath $arquivoJson -Encoding utf8
    
    $timer.Start()
})

$form.Controls.Add($btn)
$form.Add_FormClosing({
    if ($script:imgNao) { $script:imgNao.Dispose() }
    if ($script:imgSim) { $script:imgSim.Dispose() }
})

[System.Windows.Forms.Application]::Run($form)