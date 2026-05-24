# Check C drive usage
$c = Get-PSDrive C
$usedGB = [math]::Round($c.Used/1GB, 2)
$freeGB = [math]::Round($c.Free/1GB, 2)
$totalGB = [math]::Round(($c.Used + $c.Free)/1GB, 2)
Write-Host "=== C Drive Overview ==="
Write-Host "Total: $totalGB GB | Used: $usedGB GB | Free: $freeGB GB"

Write-Host "`n=== Temp/Cache Directories ==="
$dirs = @(
    @{Name='Windows Temp'; Path='C:\Windows\Temp'},
    @{Name='User Temp'; Path="$env:LOCALAPPDATA\Temp"},
    @{Name='Prefetch'; Path='C:\Windows\Prefetch'},
    @{Name='Windows Update Cache'; Path='C:\Windows\SoftwareDistribution\Download'},
    @{Name='IE Cache'; Path="$env:LOCALAPPDATA\Microsoft\Windows\INetCache"},
    @{Name='npm Cache'; Path="$env:LOCALAPPDATA\npm-cache"},
    @{Name='pip Cache'; Path="$env:LOCALAPPDATA\pip\cache"},
    @{Name='Yarn Cache'; Path="$env:LOCALAPPDATA\Yarn"},
    @{Name='NuGet Cache'; Path="$env:LOCALAPPDATA\NuGet\Cache"},
    @{Name='.cache'; Path="$env:USERPROFILE\.cache"}
)

foreach ($d in $dirs) {
    if (Test-Path $d.Path) {
        $size = (Get-ChildItem $d.Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
        if ($sizeGB -gt 0.01) {
            Write-Host "$('{0:N2}' -f $sizeGB) GB - $($d.Name) : $($d.Path)"
        }
    }
}

Write-Host "`n=== Large User Folders (>1GB) ==="
Get-ChildItem $env:USERPROFILE -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $sizeGB = if ($size) { [math]::Round($size/1GB, 2) } else { 0 }
    if ($sizeGB -gt 1) {
        Write-Host "$('{0:N2}' -f $sizeGB) GB - $($_.Name)"
    }
}

Write-Host "`n=== Done ==="
