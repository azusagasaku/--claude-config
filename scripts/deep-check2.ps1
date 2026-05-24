$user = $env:USERPROFILE

Write-Host "=== opcode-zh/src-tauri subdirs ==="
Get-ChildItem "$user\opcode-zh\src-tauri" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - src-tauri\$($_.Name)"
}

Write-Host "`n=== AppData/Roaming/uv subdirs ==="
Get-ChildItem "$user\AppData\Roaming\uv" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - uv\$($_.Name)"
}

Write-Host "`n=== AppData/Local/Microsoft subdirs (>100MB) ==="
Get-ChildItem "$user\AppData\Local\Microsoft" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    if ($sizeGB -gt 0.1) {
        Write-Host "$('{0:N2}' -f $sizeGB) GB - Microsoft\$($_.Name)"
    }
}

Write-Host "`n=== AionUi subdirs ==="
Get-ChildItem "$user\AionUi" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - AionUi\$($_.Name)"
}

Write-Host "`n=== Videos subdirs ==="
Get-ChildItem "$user\Videos" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - Videos\$($_.Name)"
}

Write-Host "`n=== Documents subdirs ==="
Get-ChildItem "$user\Documents" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - Documents\$($_.Name)"
}

Write-Host "`n=== Done ==="
