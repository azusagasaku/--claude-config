$user = $env:USERPROFILE

Write-Host "=== .cache subdirs ==="
Get-ChildItem "$user\.cache" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    if ($sizeGB -gt 0.01) {
        Write-Host "$('{0:N2}' -f $sizeGB) GB - .cache\$($_.Name)"
    }
}

Write-Host "`n=== AppData subdirs ==="
Get-ChildItem "$user\AppData" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - AppData\$($_.Name)"
}

Write-Host "`n=== AppData/Local subdirs (>500MB) ==="
Get-ChildItem "$user\AppData\Local" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    if ($sizeGB -gt 0.5) {
        Write-Host "$('{0:N2}' -f $sizeGB) GB - AppData\Local\$($_.Name)"
    }
}

Write-Host "`n=== AppData/Roaming subdirs (>500MB) ==="
Get-ChildItem "$user\AppData\Roaming" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    if ($sizeGB -gt 0.5) {
        Write-Host "$('{0:N2}' -f $sizeGB) GB - AppData\Roaming\$($_.Name)"
    }
}

Write-Host "`n=== tmp subdirs ==="
Get-ChildItem "$user\tmp" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - tmp\$($_.Name)"
}

Write-Host "`n=== opcode-zh subdirs ==="
Get-ChildItem "$user\opcode-zh" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - opcode-zh\$($_.Name)"
}

Write-Host "`n=== remotion subdirs ==="
Get-ChildItem "$user\remotion" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    Write-Host "$('{0:N2}' -f $sizeGB) GB - remotion\$($_.Name)"
}

Write-Host "`n=== Done ==="
