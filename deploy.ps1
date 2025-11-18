<#
.SYNOPSIS
    Hexo Blog Deployment Script

.DESCRIPTION
    Automated workflow:
    1. Switch to main branch (source code)
    2. Commit all changes to main branch
    3. Push main branch to GitHub (backup source)
    4. Clean and generate static site
    5. Deploy to master branch (GitHub Pages)
    6. Optional: Submit URLs to IndexNow

.NOTES
    Usage: .\deploy.ps1
    Or: powershell.exe -ExecutionPolicy Bypass -File .\deploy.ps1
    
    Branch Structure:
    - main branch: Store blog source (posts, config, themes)
    - master branch: Store generated static site (managed by hexo deploy)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==================== Configuration ====================
$MainBranch = "main"
$DeployBranch = "master"
$CommitMessage = "Update blog: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# ==================== Functions ====================
function Write-Step {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Red
}

# ==================== Main Process ====================
try {
    Write-Host @"

========================================================
        Hexo Blog Deployment Script
        GitHub Pages Dual-Branch Deploy
========================================================

"@ -ForegroundColor Cyan

    # Step 1: Check Environment
    Write-Step "Step 1/6: Environment Check"
    
    if (-not (Test-Path ".git")) {
        throw "Not a Git repository! Please run in blog root directory."
    }
    Write-Success "Git repository found"

    if (-not (Test-Path "_config.yml")) {
        throw "_config.yml not found! Please run in Hexo blog root."
    }
    Write-Success "Hexo config found"

    # Step 2: Switch to main branch
    Write-Step "Step 2/6: Switch to Source Branch ($MainBranch)"
    
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if ($currentBranch -ne $MainBranch) {
        Write-Info "Current branch: $currentBranch, switching to $MainBranch"
        git checkout $MainBranch
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to switch to $MainBranch branch"
        }
    }
    Write-Success "On $MainBranch branch"

    # Step 3: Commit and push source
    Write-Step "Step 3/6: Commit and Push Source to GitHub"
    
    $status = git status --porcelain
    if ($status) {
        Write-Info "Changes detected, committing..."
        git add .
        git commit -m $CommitMessage
        Write-Success "Local commit done"
    } else {
        Write-Success "No changes to commit"
    }

    Write-Info "Pushing to remote $MainBranch..."
    git push origin $MainBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Push failed, continuing anyway"
    } else {
        Write-Success "Source pushed to GitHub"
    }

    # Step 4: Clean cache
    Write-Step "Step 4/6: Clean Hexo Cache"
    
    npx hexo clean
    if ($LASTEXITCODE -ne 0) {
        throw "Hexo clean failed"
    }
    Write-Success "Cache cleaned"

    # Step 5: Generate static files
    Write-Step "Step 5/6: Generate Static Site"
    
    npx hexo generate
    if ($LASTEXITCODE -ne 0) {
        throw "Hexo generate failed"
    }
    Write-Success "Static site generated"

    # Step 6: Deploy to master
    Write-Step "Step 6/6: Deploy to GitHub Pages ($DeployBranch)"
    
    npx hexo deploy
    if ($LASTEXITCODE -ne 0) {
        throw "Hexo deploy failed"
    }
    Write-Success "Deployed to $DeployBranch branch"

    # Done
    Write-Host @"

========================================================
            Deployment Successful!
========================================================

"@ -ForegroundColor Green

    Write-Host "Source Branch: " -NoNewline
    Write-Host "$MainBranch" -ForegroundColor Cyan
    Write-Host "Deploy Branch: " -NoNewline
    Write-Host "$DeployBranch" -ForegroundColor Cyan
    Write-Host "Site URL: " -NoNewline
    Write-Host "https://hexiao2001.github.io/" -ForegroundColor Yellow
    Write-Host "`nNote: GitHub Pages may take a few minutes to update" -ForegroundColor Gray

    # Optional: Submit IndexNow
    if (Test-Path "submit_indexnow.ps1") {
        Write-Host "`nSubmit URLs to search engines? (Y/N) " -NoNewline -ForegroundColor Cyan
        $response = Read-Host
        if ($response -eq "Y" -or $response -eq "y") {
            Write-Info "Running submit_indexnow.ps1..."
            & .\submit_indexnow.ps1
        }
    }

} catch {
    Write-Host "`n"
    Write-Err "Deployment failed: $($_.Exception.Message)"
    Write-Host "`nError Stack:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}

exit 0