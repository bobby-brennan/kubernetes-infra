## Stock Screener
```
kns stock-screener
kubectl create secret generic github-token --from-literal=github-token=$GITHUB_TOKEN
kubectl create secret generic polygon-token --from-literal=polygon-token=$POLYGON_TOKEN
```

## GitHub Notifs
```
kns github-notifs
kubectl create secret generic slack-webhook-id --from-literal=slack-webhook-id=$SLACK_WEBHOOK_ID
```

## Post Scheduler
```
kns post-scheduler
kubectl create secret generic github-token --from-literal=github-token=$GITHUB_TOKEN

cd ~/git/scheduled-posts/
kubectl create secret generic google-secret --from-file=google-credentials.json=./google-credentials.json
kubectl create secret generic hacker-news --from-literal=HN_USERNAME=$HN_USERNAME --from-literal=HN_PASSWORD=$HN_PASSWORD
kubectl create secret generic reddit \
  --from-literal=REDDIT_USERNAME=$REDDIT_USERNAME \
  --from-literal=REDDIT_PASSWORD=$REDDIT_PASSWORD \
  --from-literal=REDDIT_CLIENT_ID=$REDDIT_CLIENT_ID \
  --from-literal=REDDIT_CLIENT_SECRET=$REDDIT_CLIENT_SECRET
```
