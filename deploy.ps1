<#
deploy.ps1
作用：
- 备份本地 `.git`（`.git.bak`）
- 将当前源码放到本地并推送到 `main` 分支（`git push -u origin main`）
- 校验 `_config.yml` 中 `deploy` 配置是否为推送 `master`
- 运行 `npx hexo clean/generate` 并 `npx hexo deploy` 将 `public/` 部署到远程 `master`

使用：在项目根用 PowerShell 运行：
  powershell.exe -ExecutionPolicy Bypass -File .\deploy.ps1

注意：脚本会停止并打印错误信息（不会自动修改 GitHub 仓库的默认分支）。
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Function Run-Command {
    param($exe, [string[]]$args)
    Write-Host "Running: $exe $($args -join ' ')" -ForegroundColor Cyan
    & $exe @args
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $exe $($args -join ' ') (ExitCode $LASTEXITCODE)"
    }
}

try {
    Write-Host "1) Backup .git if it exists..." -ForegroundColor Green
    if (Test-Path -LiteralPath ".git") {
        if (-not (Test-Path -LiteralPath ".git.bak")) {
            Write-Host "Copying .git -> .git.bak ..." -ForegroundColor Yellow
            Copy-Item -Recurse -Force .git .git.bak
            Write-Host ".git backed up to .git.bak" -ForegroundColor Green
        } else {
            Write-Host ".git.bak already exists, skipping backup" -ForegroundColor Yellow
        }
    } else {
        Write-Host ".git not found, continuing" -ForegroundColor Yellow
    }

    Write-Host "`n2) Check git availability..." -ForegroundColor Green
    try {
        & git --version
    } catch {
        Write-Warning "git not found or returned an error. Please ensure git is installed and available in PATH."
        throw "git not available"
    }

    Write-Host "`n3) Switch or create local branch 'main' and push to origin/main" -ForegroundColor Green
    # Check if local main exists
    $exists = $false
    $ErrorActionPreference = 'SilentlyContinue'
    $mainCheck = git rev-parse --verify main 2>&1
    $ErrorActionPreference = 'Stop'
    if ($LASTEXITCODE -eq 0) { $exists = $true }

    # Check if repository has any commits (HEAD exists)
    $ErrorActionPreference = 'SilentlyContinue'
    $headCheck = git rev-parse --verify HEAD 2>&1
    $ErrorActionPreference = 'Stop'
    $hasHead = ($LASTEXITCODE -eq 0)

    if ($exists) {
        Write-Host "Local branch 'main' exists, checking out..." -ForegroundColor Yellow
        Run-Command git checkout main
        # Try to update from origin if present
        & git ls-remote --exit-code origin main > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Run-Command git pull --ff-only origin main
        } else {
            Write-Host "origin/main not found or empty, skipping pull" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Creating local 'main' branch from current HEAD" -ForegroundColor Yellow
        if (-not $hasHead) {
            Write-Host "Repository has no commits. Creating an initial commit..." -ForegroundColor Yellow
            $porcelain = (& git status --porcelain)
            if ($porcelain) {
                Run-Command git add -A
                $msgInit = "Initial commit for deployment $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                Run-Command git commit -m $msgInit
            } else {
                Run-Command git commit --allow-empty -m "Initial empty commit for deployment $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            }
        }
        Run-Command git checkout -B main
    }

    # Commit any uncommitted changes
    $status = (& git status --porcelain)
    if ($status) {
        Write-Host "Uncommitted changes found, adding and committing..." -ForegroundColor Yellow
        Run-Command git add -A
        $msg = "Backup source to main $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Run-Command git commit -m $msg
    } else {
        Write-Host "No uncommitted changes, skipping commit" -ForegroundColor Yellow
    }

    Write-Host "Pushing local main to origin/main..." -ForegroundColor Green
    try {
        Run-Command git push -u origin main
    } catch {
        Write-Warning "Push to origin/main failed: $($_.Exception.Message)"
        Write-Warning "Please check remote 'origin' or run 'git push -u origin main' manually. Script will continue to attempt site deploy."
    }

    Write-Host "`n4) Validate _config.yml deploy settings (expect repository git@github.com:HeXiao2001/HeXiao2001.github.io.git and branch master)" -ForegroundColor Green
    if (-not (Test-Path -LiteralPath "_config.yml")) {
        throw "_config.yml not found, aborting."
    }
    $cfg = Get-Content -Raw "_config.yml"
    if ($cfg -notmatch 'repository:\s*git@github.com:HeXiao2001/HeXiao2001.github.io.git') {
        Write-Warning "_config.yml repository does not match expected value. Please set deploy.repository to git@github.com:HeXiao2001/HeXiao2001.github.io.git"
        throw "deploy.repository mismatch, aborting."
    }
    if ($cfg -notmatch 'branch:\s*master') {
        Write-Warning "_config.yml deploy.branch is not 'master'. Please set branch: master"
        throw "deploy.branch mismatch, aborting."
    }

    Write-Host "Validation passed, generating and deploying site..." -ForegroundColor Green

    Write-Host "`n5) Clean and generate: npx hexo clean && npx hexo generate" -ForegroundColor Green
    Run-Command npx --yes hexo clean
    Run-Command npx --yes hexo generate

    Write-Host "`n6) Deploy site: npx hexo deploy (this will push public/ to remote master via hexo-deployer-git)" -ForegroundColor Green
    Run-Command npx --yes hexo deploy

    Write-Host "`n7) Print deploy repo remotes for verification:" -ForegroundColor Green
    if (Test-Path -LiteralPath ".deploy_git") {
        Run-Command git -C .deploy_git remote -v
    } elseif (Test-Path -LiteralPath "public/.git") {
        Run-Command git -C public remote -v
    } else {
        Write-Host "No .deploy_git or public/.git found. hexo-deployer-git may have used a temporary repo or cleaned up. Check remote master on GitHub to verify deployment." -ForegroundColor Yellow
    }

    Write-Host "`nAll done. Please verify on GitHub:" -ForegroundColor Cyan
    Write-Host "- Default branch (Settings -> Branches) is set to 'main' if desired" -ForegroundColor Cyan
    Write-Host "- Pages source is 'master' (Settings -> Pages) to publish the site" -ForegroundColor Cyan

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}

exit 0
