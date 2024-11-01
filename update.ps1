#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

param(
    [string]$Message
)

# Build the Docker image
try {
    docker build -t ricoharsono/huatah-backend:latest . | Out-String
} catch {
    Write-Host "Docker build failed"
    exit 1
}

# Push the Docker image to Docker Hub
try {
    docker push ricoharsono/huatah-backend:latest | Out-String
} catch {
    Write-Host "Docker push failed"
    exit 1
}

# Check Kubernetes context
$checkContext = kubectl config current-context | Select-String -Pattern "do-sgp1-k8s"

if (-not $checkContext) {
    Write-Host "Current context is not correct. Exiting."
    exit 1
} else {
    try {
        kubectl rollout restart deployment huatah-backend-deployment | Out-String
    } catch {
        Write-Host "Kubernetes rollout restart failed"
        exit 1
    }
}

#Send text message
# Define your bot token and chat IDs
$botToken = "902467435:AAGGJ695Sy_EWiFyJszxTkwTJqbxPwiNsG4"
#$chatIds = @("6454159736", "362851348")
$chatIds = @("362851348")

# Send the message to each chat ID
foreach ($chatId in $chatIds) {
    $url = "https://api.telegram.org/bot$botToken/sendMessage"
    $body = @{
        chat_id = $chatId
        text    = $Message
    }

    # Send the POST request
    Invoke-RestMethod -Uri $url -Method Post -Body $body
}
