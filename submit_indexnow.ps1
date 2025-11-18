# IndexNow URL Submission Script
# This script submits your blog URLs to search engines via IndexNow protocol

$indexnowKey = "dbcab8852f48435cb472ca5c0913afd2"
$siteHost = "hexiao2001.github.io"
$keyLocation = "https://hexiao2001.github.io/dbcab8852f48435cb472ca5c0913afd2.txt"

# Check if submit_urls.txt exists
$urlFile = "public\submit_urls.txt"
if (-not (Test-Path $urlFile)) {
    Write-Host "✗ $urlFile not found. Please run 'npx hexo g' first." -ForegroundColor Red
    exit 1
}

# Read URLs from submit_urls.txt
$urls = Get-Content $urlFile | Where-Object { $_ -match "^https?://" }

if ($urls.Count -eq 0) {
    Write-Host "✗ No URLs found in submit_urls.txt" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($urls.Count) URLs to submit" -ForegroundColor Cyan
Write-Host "Submitting to Bing IndexNow...`n" -ForegroundColor Cyan

# Load System.Web for URL encoding
Add-Type -AssemblyName System.Web

# Submit to Bing IndexNow (simpler and more reliable than bulk API)
$successCount = 0
$failCount = 0

foreach ($url in $urls) {
    try {
        $encodedUrl = [System.Web.HttpUtility]::UrlEncode($url)
        $response = Invoke-WebRequest -Uri "https://www.bing.com/indexnow?url=$encodedUrl&key=$indexnowKey" -Method Get
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 202) {
            $successCount++
            Write-Host "  ✓ $url" -ForegroundColor Green
        }
    } catch {
        $failCount++
        Write-Host "  ✗ $url - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 100
}

Write-Host "`n✓ Successfully submitted $successCount/$($urls.Count) URLs to Bing IndexNow" -ForegroundColor Green
Write-Host "  Note: URLs submitted via IndexNow are automatically shared with other participating search engines (Yandex, etc.)" -ForegroundColor Gray
if ($failCount -gt 0) {
    Write-Host "✗ Failed to submit $failCount URLs" -ForegroundColor Yellow
}
