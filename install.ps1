# NeNe Bolt installer for PowerShell (Windows): installs nene-bolt inside WSL and adds a `nene-bolt` command for PowerShell and cmd.
#
#   irm https://raw.githubusercontent.com/hideyukiMORI/nene-bolt/main/install.ps1 | iex
#
# nene-bolt is a Linux program, so it lives in WSL. This script runs install.sh inside your WSL distribution (which verifies the
# download against SHA256SUMS and installs ~/.local/bin/nene-bolt there), then writes %LOCALAPPDATA%\nene-bolt\bin\nene-bolt.cmd,
# which starts it through wsl.exe, and adds that folder to your user PATH.
#
# Options (environment variables): NENE_BOLT_DISTRO picks a WSL distribution (default: your default one),
# NENE_BOLT_VERSION picks a release (default: the latest).
# To uninstall: delete %LOCALAPPDATA%\nene-bolt, remove it from your user PATH, and run: wsl rm ~/.local/bin/nene-bolt
#
# Kept to ASCII on purpose: Windows PowerShell 5.1 reads scripts without a BOM in the local code page.

function Install-NeNeBolt {
    $ErrorActionPreference = 'Stop'
    $repo = 'https://raw.githubusercontent.com/hideyukiMORI/nene-bolt/main'

    # Under `irm | iex`, `exit` would close the window; every failure returns from this function instead.
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host 'nene-bolt install: WSL is not installed. Run "wsl --install", restart, and run this again.' -ForegroundColor Red
        return
    }
    $distroArgs = @()
    $distroOption = ''
    if ($env:NENE_BOLT_DISTRO) {
        $distroArgs = @('-d', $env:NENE_BOLT_DISTRO)
        $distroOption = " -d $env:NENE_BOLT_DISTRO"
    }
    # wsl.exe -l prints UTF-16; strip the NUL bytes before looking at it
    $distros = @((& wsl.exe -l -q) -replace "`0", '' | Where-Object { $_.Trim() })
    if ($distros.Count -eq 0) {
        Write-Host 'nene-bolt install: no WSL distribution yet. Run "wsl --install -d Ubuntu", then run this again.' -ForegroundColor Red
        return
    }

    $version = ''
    if ($env:NENE_BOLT_VERSION) {
        $version = "NENE_BOLT_VERSION=$env:NENE_BOLT_VERSION "
    }
    & wsl.exe @distroArgs -e sh -c "curl -fsSL $repo/install.sh | ${version}bash"
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'nene-bolt install: the installer inside WSL failed (see above). Nothing was added on the Windows side.' -ForegroundColor Red
        return
    }

    $bin = Join-Path $env:LOCALAPPDATA 'nene-bolt\bin'
    New-Item -ItemType Directory -Force -Path $bin | Out-Null
    $launcher = Join-Path $bin 'nene-bolt.cmd'
    # --cd ~ starts in the WSL home, so the path needs no shell to expand it
    Set-Content -Path $launcher -Encoding ASCII -Value @(
        '@echo off',
        "wsl.exe$distroOption --cd ~ -e .local/bin/nene-bolt %*"
    )

    # NENE_BOLT_PATH_SCOPE exists only so the installer can be tested without touching the user PATH ('Process').
    $scope = 'User'
    if ($env:NENE_BOLT_PATH_SCOPE) {
        $scope = $env:NENE_BOLT_PATH_SCOPE
    }
    $path = [Environment]::GetEnvironmentVariable('Path', $scope)
    if ($null -eq $path) {
        $path = ''
    }
    if (-not (($path -split ';') -contains $bin)) {
        [Environment]::SetEnvironmentVariable('Path', (($path.TrimEnd(';') + ';' + $bin).TrimStart(';')), $scope)
        Write-Host "nene-bolt install: added $bin to your $scope PATH"
    }
    if (-not (($env:Path -split ';') -contains $bin)) {
        $env:Path = $env:Path.TrimEnd(';') + ';' + $bin
    }

    Write-Host "nene-bolt install: installed $launcher"
    Write-Host 'nene-bolt install: run nene-bolt here or in a new window (arrows, Z and X take over the controls; q quits, t changes the theme, d changes the difficulty).'
}

Install-NeNeBolt
