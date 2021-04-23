#!/bin/bash 
set -xe
SERVICE_ACCOUNT_NAME=deploy-service-account
CONTEXT=$(kubectl config current-context)
NAMESPACE=keel
NEW_CONTEXT=deploy
KUBECONFIG_FILE="kubeconfig-sa"
SECRET_NAME=$(kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.secrets[0].name}')
TOKEN_DATA=$(kubectl get secret ${SECRET_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.data.token}') 2> /dev/null
TOKEN=$(echo ${TOKEN_DATA} | base64 -d)


kubectl config view --raw > ${KUBECONFIG_FILE}.full.tmp
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp config use-context ${CONTEXT}
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp \
  config view --flatten --minify > ${KUBECONFIG_FILE}.tmp
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  rename-context ${CONTEXT} ${NEW_CONTEXT}
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-credentials ${CONTEXT}-${NAMESPACE}-token-user \
  --token ${TOKEN}
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --user ${CONTEXT}-${NAMESPACE}-token-user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --namespace ${NAMESPACE}
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  view --flatten --minify > spinnaker-config/overlays/keel/secrets/kubeconfig-deploy
rm kubeconfig*.tmp 