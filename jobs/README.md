```
kubectl create secret generic github-token --from-literal=github-token=$GITHUB_TOKEN
kubectl create secret generic slack-webhook-id --from-literal=slack-webhook-id=$SLACK_WEBHOOK_ID
kubectl create secret generic polygon-token --from-literal=polygon-token=$POLYGON_TOKEN
```

