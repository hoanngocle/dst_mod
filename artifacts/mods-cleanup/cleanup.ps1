param([switch]$Apply)
$ErrorActionPreference = 'Stop'
$modsRoot = [IO.Path]::GetFullPath('C:/Users/hoanc/company/dst_wiki/mods').TrimEnd('\')
$auditPath = Join-Path $PSScriptRoot 'audit-workspace-candidates.json'
$audit = Get-Content -LiteralPath $auditPath -Raw | ConvertFrom-Json
$results = @()
foreach ($candidate in $audit.Candidates) {
    if ($candidate.Status -notin @('safe', 'after-root-verification')) { continue }
    $target = [IO.Path]::GetFullPath($candidate.Path)
    if (-not $target.StartsWith($modsRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Outside mods: $target" }
    if (-not (Test-Path -LiteralPath $target)) { continue }
    $resolved = (Resolve-Path -LiteralPath $target).Path
    if ($resolved -ne $target) { throw "Unexpected resolved path: $resolved" }
    $ancestor = Split-Path -Parent $target
    while ($ancestor -ne $modsRoot) {
        if ((Get-Item -LiteralPath $ancestor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked ancestor: $ancestor" }
        $ancestor = Split-Path -Parent $ancestor
    }
    if ($candidate.Status -eq 'after-root-verification') {
        foreach ($process in Get-Process -Name '*dontstarve*' -ErrorAction SilentlyContinue) {
            if (-not $process.Path -or $process.Path.StartsWith($target + '\', [StringComparison]::OrdinalIgnoreCase)) {
                throw "DST process may be using this runtime: $target"
            }
        }
    }
    if ($candidate.SHA256) {
        $hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
        $retainedHash = (Get-FileHash -LiteralPath $candidate.RetainedCopy -Algorithm SHA256).Hash
        if ($hash -ne $candidate.SHA256 -or $hash -ne $retainedHash) { throw "Duplicate verification failed: $target" }
    }
    $stack = [Collections.Generic.Stack[string]]::new()
    $stack.Push($target)
    $links = @()
    [long]$bytes = 0
    [long]$files = 0
    while ($stack.Count -gt 0) {
        $entry = Get-Item -LiteralPath $stack.Pop() -Force
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            if ($entry.FullName -notin @($candidate.Links.Path)) { throw "Unlisted reparse point: $($entry.FullName)" }
            $links += $entry.FullName
        } elseif ($entry.PSIsContainer) {
            foreach ($child in Get-ChildItem -LiteralPath $entry.FullName -Force) { $stack.Push($child.FullName) }
        } else { $bytes += $entry.Length; $files++ }
    }
    $results += [pscustomobject]@{Path=$target;Bytes=$bytes;Files=$files;Reason=$candidate.Reason;Links=$links;Removed=[bool]$Apply}
    if ($Apply) {
        # Unlink only the junction itself. Never descend into its Steam data target.
        foreach ($link in $links) { Remove-Item -LiteralPath $link -Force }
        Remove-Item -LiteralPath $target -Recurse -Force
        if (Test-Path -LiteralPath $target) { throw "Target still exists: $target" }
    }
}
$report = [pscustomobject]@{Applied=[bool]$Apply;Bytes=($results | Measure-Object Bytes -Sum).Sum;Files=($results | Measure-Object Files -Sum).Sum;Paths=$results}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot $(if ($Apply) {'deleted.json'} else {'dry-run.json'})) -Encoding utf8
$report | Select-Object Applied,Bytes,Files
