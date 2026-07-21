$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$renderUrl = "file:///c:/Users/K Rajtilak/Documents/VScode/Nummo/nummo/logo/render.html"

# Array of targets with: OutputPath, Width, Height
$targets = @(
    [PSCustomObject]@{ Path = "logo\nummo.png"; W = 512; H = 512 },
    [PSCustomObject]@{ Path = "web\favicon.png"; W = 512; H = 512 },
    [PSCustomObject]@{ Path = "web\icons\Icon-512.png"; W = 512; H = 512 },
    [PSCustomObject]@{ Path = "web\icons\Icon-maskable-512.png"; W = 512; H = 512 },
    [PSCustomObject]@{ Path = "web\icons\Icon-192.png"; W = 192; H = 192 },
    [PSCustomObject]@{ Path = "web\icons\Icon-maskable-192.png"; W = 192; H = 192 }
)

foreach ($target in $targets) {
    $fullPath = Join-Path (Get-Location) $target.Path
    # Ensure parent directory exists
    $parentDir = Split-Path $fullPath -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    
    Write-Output "Generating $($target.Path) ($($target.W)x$($target.H))..."
    & $edgePath --headless=new --disable-gpu --screenshot="$fullPath" --window-size="$($target.W),$($target.H)" $renderUrl *>&1 | Out-Null
    
    if (Test-Path $fullPath) {
        $size = (Get-Item $fullPath).Length
        Write-Output "Successfully wrote $($target.Path) ($size bytes)"
    } else {
        Write-Error "Failed to generate $($target.Path)"
    }
}
