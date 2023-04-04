#!/bin/bash

set -eo pipefail

print_help() {
    printf '%s\n' \
        ''\
        'tanzu-login - Log in against the supervidor or tkc cluster' \
        ''\
        'Usage:' \
        ''\
        '- Login to a TKC cluster ' \
        '  ./tanzu-login -s|--server (cpl|oak) -n|--namespace <supervisor-cluster-ns> -k|--tkc <tkc-cluster-name>' \
        ''\
        '- Login to a Supervisor cluster'\
        '  ./tanzu-login -s|--server <datacenter-id> -n|--namespace <supervisor-cluster-ns>(optional)' \
        ''\
        'Global vars:'\
        '- TANZU_USER - optional (eg. administrator@vsphere.local)'\
        '- KUBECTL_VSPHERE_PASSWORD - AD Password' \
        ''\
        'example: tanzu-login -s clp -n clp-lm-uat -k tkc-lm-uat'
}

#######################################
# Description: Log in against the supervidor or tkc cluster
# Globals: 
# - $TANZU_USER - AD User (eg. vpupim@vmware.com)
# - KUBECTL_VSPHERE_PASSWORD - AD Passwrod
# Arguments:
# - $1 : DC - Supervisor Cluster IP (eg. 10.24.227.66)
# - $2 : NS - Supervisor Cluster Namespace (eg. clp-lm-uat)
# - $3 : TKC - Kubernetes cluster name (eg. tkc-lm-uat)
# Outputs: writes to $HOME/.kube/config
# Returns:
#######################################
tanzu_login() {
  local -r ip="${TANZU_WCP:?"tanzu_login is missing Tanzu Supervisor host parameter. Set TANZU_WCP env var with ip or hostname"}"
  local -r ns="${2-}"
  local -r tkc="${3:-}"

  local flagsBuilder="--server https://$ip --insecure-skip-tls-verify"  
  local context=$ip

  if [[ ! -z "$ns" ]]; then
     flagsBuilder="$flagsBuilder --tanzu-kubernetes-cluster-namespace $ns"
     context=$ns
  fi
  if [[ ! -z "$tkc" ]]; then
    flagsBuilder="$flagsBuilder --tanzu-kubernetes-cluster-name $tkc"
    context=$tkc
  fi
  if [[ ! -z "$TANZU_USER" ]]; then
    echo "TANZU_USER env var is set. Login in as $TANZU_USER" ; echo
    flagsBuilder="$flagsBuilder --vsphere-username ${TANZU_USER}"
  fi

  echo "kubectl vsphere login $flagsBuilder" ; echo
    if  kubectl vsphere login $flagsBuilder ; then
    echo ; echo "kubectl config use-context $context" ; echo
    kubectl config use-context $context
  fi
}


for ((i=1; i<=$#; i=i+2)); do
    case "${!i}" in
        -s|--server)
            val=$((i+1)) ; server=${!val} ;
            case "${server}" in 
                clp)
                    server_ip=10.24.227.66 ;;
                oak)
                    server_ip=10.53.227.66 ;;
                h2o)
                    server_ip=$TANZU_WCP;;
                *) 
                    echo "${server} is not a valid server id. Valid servers: oak | clp" ; print_help ; exit 1 ;;
            esac ;;
        -n|--namespace)
            val=$((i+1)) ; ns=${!val} ;;
        -k|--tkc)
            val=$((i+1)) ; tkc=${!val} ;;
        -h|--help)
            print_help ; exit 0 ;;
        *) 
            echo "invalid flag: ${!i}" ; print_help ; exit 1 ;;    
    esac
done

tanzu_login $server_ip $ns $tkc
