#!/usr/bin/env bash

set -o pipefail

# install curl 
if ! curl -V; then
	apt-get update
	apt-get install curl 
fi

# install kubectl
if ! kubectl help; then
	pushd /tmp
	{
		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
		echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
		sudo install -m 0755 kubectl /usr/local/bin/kubectl
	}
	popd
fi

#install bash completion
if ! type _init_completion; then
	apt-get install bash-completion 
fi

# Set the kubectl completion script source for your shell sessions
echo 'source <(kubectl completion bash)'>>$HOME/.bashrc
echo 'source /etc/bash_completion' >>$HOME/.bashrc

# setup alias
echo 'alias k=kubectl' >>$HOME/.bashrc

#Enable the alias for auto-completion.
echo 'complete -o default -F __start_kubectl k' >>$HOME/.bashrc

if ! kubectl krew ; then
	set -x; cd "$(mktemp -d)" &&
	OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
	ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
	KREW="krew-${OS}_${ARCH}" &&
	curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
	tar zxvf "${KREW}.tar.gz" &&
	./${KREW} install krew		
	set +x
fi

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >>$HOME/.bashrc
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if ! kubectl krew ; then
	echo krew not installed
	exit 1
fi

# install kubectx and kubens
kubectl krew install ctx
kubectl krew install ns
# setup alias
echo 'alias kctx="kubectl ctx"' >> $HOME/.bashrc
echo 'alias kns="kubectl ns"' >> $HOME/.bashrc


# install kube-ps1
mkdir $HOME/git ; cd $HOME/git
git clone https://github.com/jonmosco/kube-ps1.git
source $HOME/git/kube-ps1/kube-ps1.sh
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(kube_ps1) λ '

echo 'source $HOME/git/kube-ps1/kube-ps1.sh' >>$HOME/.bashrc
echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(kube_ps1) λ "' >> $HOME/.bashrc

sudo apt install make


wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin


wget -O $HOME/git/tanzu-login.sh https://gist.githubusercontent.com/pupimvictor/52ae06d56d4a22e0551e414bb93b78d5/raw/c8049ea42d2592f616e68dad6864746256f9c1c9/Tanzu-login.sh
sudo chmod +x tanzu-login.sh
source $HOME/git/tanzu-login.sh

source $HOME/.bashrc

echo ----------------------
echo ---restart session----
echo ----------------------