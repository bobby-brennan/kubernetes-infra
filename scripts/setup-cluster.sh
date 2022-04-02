#!/bin/bash
set -e

reckoner plot util/course.yaml --run-all

sleep 30

helm upgrade --install cert-issuer -n cert-manager ./charts/cert-issuer --set email=$CERT_ISSUER_EMAIL
echo -e "\n\n"
echo "Your cluster is ready!"
