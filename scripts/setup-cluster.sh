#!/bin/bash
set -e

reckoner plot util/course.yaml

sleep 30

echo -e "\n\n"
echo "Your cluster is ready!"
echo -e "To finish, you should run:\nhelm upgrade --install cert-issuer ./charts/cert-issuer --set email=you@example.com"
