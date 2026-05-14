# reset-kafka.ps1 - Run this entire script

Write-Host "Step 1: Force delete all KafkaTopics" -ForegroundColor Yellow
kubectl get kafkatopics --all-namespaces 2>$null | ForEach-Object {
    if ($_ -match "kafka") {
        $topic = ($_ -split '\s+')[0]
        if ($topic -and $topic -ne "NAME") {
            kubectl patch kafkatopic $topic -n kafka --type='json' -p='[{"op": "remove", "path": "/metadata/finalizers"}]' --force --grace-period=0 2>$null
            kubectl delete kafkatopic $topic -n kafka --force --grace-period=0 2>$null
        }
    }
}

Write-Host "Step 2: Remove finalizers from namespace" -ForegroundColor Yellow
kubectl get namespace kafka -o json | ForEach-Object {
    $_ -replace '"finalizers": \[[^\]]*\]', '"finalizers": []'
} | kubectl replace --raw "/api/v1/namespaces/kafka/finalize" -f -

Write-Host "Step 3: Force delete namespace" -ForegroundColor Yellow
kubectl delete namespace kafka --force --grace-period=0 2>$null

Write-Host "Step 4: Wait for cleanup" -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "Step 5: Verify namespace is gone" -ForegroundColor Yellow
kubectl get namespace kafka 2>&1 | Select-String "NotFound"

Write-Host "Step 6: Create fresh namespace" -ForegroundColor Yellow
kubectl create namespace kafka

Write-Host "Done! Namespace is ready for fresh installation." -ForegroundColor Green