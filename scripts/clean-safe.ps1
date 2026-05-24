$ErrorActionPreference = 'Continue'
$user = $env:USERPROFILE
$freed = 0

function Clean-Path($Path, $Label) {
    if (Test-Path $Path) {
        try {
            $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
            Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
            $remaining = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue 2>$null | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $remainingGB = if ($remaining) { [math]::Round($remaining/1GB, 2) } else { 0 }
            $freedGB = $sizeGB - $remainingGB
            $script:freed += $freedGB
            Write-Host "[OK] $Label : freed $('{0:N2}' -f $freedGB) GB"
        } catch {
            Write-Host "[WARN] $Label : could not fully remove"
        }
    } else {
        Write-Host "[SKIP] $Label : not found"
    }
}

function Clean-Contents($Path, $Label) {
    if (Test-Path $Path) {
        try {
            $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
            Get-ChildItem $Path -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $remaining = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue 2>$null | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $remainingGB = if ($remaining) { [math]::Round($remaining/1GB, 2) } else { 0 }
            $freedGB = $sizeGB - $remainingGB
            $script:freed += $freedGB
            Write-Host "[OK] $Label : freed $('{0:N2}' -f $freedGB) GB"
        } catch {
            Write-Host "[WARN] $Label : could not fully clean"
        }
    } else {
        Write-Host "[SKIP] $Label : not found"
    }
}

Write-Host "=== C Drive Safe Cleanup ==="
Write-Host ""

# 1. Windows Temp (contents only)
Clean-Contents 'C:\Windows\Temp' 'Windows Temp'

# 2. User Temp (contents only)
Clean-Contents "$env:LOCALAPPDATA\Temp" 'User Temp'

# 3. Prefetch
Clean-Contents 'C:\Windows\Prefetch' 'Prefetch'

# 4. ModelScope cache
Clean-Path "$user\.cache\modelscope" 'ModelScope cache'

# 5. Rust build artifacts
Clean-Path "$user\opcode-zh\src-tauri\target" 'Rust target'

# 6. Python uv cache
Clean-Path "$user\AppData\Roaming\uv" 'Python uv cache'

# 7. OCR temp files
Clean-Path "$user\tmp\ocr-images" 'OCR images temp'
Clean-Path "$user\tmp\ocr-safepngs" 'OCR safepngs temp'
Clean-Path "$user\tmp\ocr-tool" 'OCR tool temp'
Clean-Path "$user\tmp\pngs" 'PNGs temp'

# 8. Windows Update cache
Clean-Contents 'C:\Windows\SoftwareDistribution\Download' 'Windows Update cache'

# 9. NuGet cache
Clean-Path "$env:LOCALAPPDATA\NuGet\Cache" 'NuGet cache'

# 10. IE cache
Clean-Contents "$env:LOCALAPPDATA\Microsoft\Windows\INetCache" 'IE cache'

Write-Host ""
Write-Host "=== Total freed: $('{0:N2}' -f $freed) GB ==="
