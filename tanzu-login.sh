#!/bin/bash

if [ -z $TANZU_WCP ]; then
  echo "export TANZU_WCP with your wcp domain."
  echo Ex: export TANZU_WCP="https://10.214.180.99"
  exit 1
fi

if [ -z $TANZU_USER ]; then
  echo "using administrator@vsphere.local as user. export TANZU_USER env var to override"
  TANZU_USER="administrator@vsphere.local"
fi


OIFS=$IFS
IFS="/"
IN=(${@})
if [ ! -z ${IN[0]} ] ; then
  echo Namespace ${IN[0]} 
  ns="--tanzu-kubernetes-cluster-namespace=${IN[0]}"
fi
if [ ! -z ${IN[1]} ] ; then
  echo ${IN[1]} 
  cluster="--tanzu-kubernetes-cluster-name=${IN[1]}"
fi

IFS=$OIFS

cmd="--server $TANZU_WCP --vsphere-username $TANZU_USER --insecure-skip-tls-verify $ns $cluster"
echo $cmd
kubectl vsphere login ${cmd}