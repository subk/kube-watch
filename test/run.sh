#/bin/bash

KUBE_PROXY_IP=${KUBE_PROXY_IP:-127.0.0.1}
KUBE_PROXY_PORT=${KUBE_PROXY_PORT:-$(shuf -i 50000-60000 -n 1)}
KUBE_PROXY_PREFIX=${KUBE_PROXY_PREFIX:-__test__}

isInstalled () {
  which $1 2>&1 > /dev/null
}

contains () {
  [ -z "${1##*$2*}" ];
}

isProcessRunning () {
  kill -0 $1 2>&1 > /dev/null
}

abort () {
  [ "$1" != "" ] && echo $1
  minikube stop
  exit 1
}

isMinikubeRunning () {
  status=$(minikube status)
  contains "$status" "minikubeVM: Running" \
    && contains "$status" "localkube: Running"
}

isInstalled "minikube" || {
  echo "`minikube` not found."
  echo "See installation details at https://github.com/kubernetes/minikube#installation"
  exit 1
}

isMinikubeRunning "minikube" || {
  minikube start && {
    echo "Waiting for Kubernetes server to be ready..."
    sleep 5
  } || exit 1
}

echo "Waiting for Kubernetes API proxying..."
kubectl proxy \
  --address=$KUBE_PROXY_IP \
  --port=$KUBE_PROXY_PORT \
  --www-prefix=$KUBE_PROXY_PREFIX &
KUBECTL_PID=$!

sleep 2 && isProcessRunning $KUBECTL_PID || {
  abort "Unable to proxy Kubernetes API."
}

export KUBE_API_SERVER="http://$PROXY_IP:$PROXY_PORT/$PROXY_PREFIX"
npm run test:single || abort

minikube stop
