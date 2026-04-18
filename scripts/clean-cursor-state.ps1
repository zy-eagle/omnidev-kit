# Cursor globalStorage state.vscdb cleanup script
# This will delete all AI conversation history across ALL projects.

$globalStorage = "$env:APPDATA\Cursor\User\globalStorage"

$cursorProcs = Get-Process -Name "Cursor" -ErrorAction SilentlyContinue
if ($cursorProcs) {
    Write-Host "!! Cursor is still running ($($cursorProcs.Count) processes). Close ALL Cursor windows first." -ForegroundColor Red
    Write-Host "Press Enter to exit..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

Write-Host "=== Cursor globalStorage cleanup ===" -ForegroundColor Cyan

$files = @(
    "state.vscdb",
    "state.vscdb-wal",
    "state.vscdb-shm",
    "state.vscdb.backup",
    "state.vscdb.bak"
)

$totalFreed = 0
foreach ($f in $files) {
    $path = Join-Path $globalStorage $f
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Remove-Item $path -Force
        $totalFreed += $size
        Write-Host "  Deleted: $f ($([math]::Round($size/1MB,2)) MB)" -ForegroundColor Green
    }
}

Write-Host "`nFreed: $([math]::Round($totalFreed/1MB,2)) MB ($([math]::Round($totalFreed/1GB,2)) GB)" -ForegroundColor Cyan
Write-Host "Done. Reopen Cursor now - a fresh database will be created automatically." -ForegroundColor Cyan
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
