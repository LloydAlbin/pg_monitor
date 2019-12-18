# Windows Setup

## Getting Ubuntu 18.04

```powershell
# Enable Windows Subsystem Linux v1
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Download Ubuntu 18.04
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing
# Install Ubuntu 18.04
Add-AppxPackage .\Ubuntu.appx

Get-AppxPackage -Name Can*
#Name              : CanonicalGroupLimited.Ubuntu18.04onWindows
#Version           : 1804.2019.522.0
#PackageFullName   : CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2019.522.0_x64__79rhkp1fndgsc
#InstallLocation   : C:\Program Files\WindowsApps\CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2019.522.0_x64__79rhkp1fndgsc
#PackageFamilyName : CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc

InstallLocation   : C:\Program Files\WindowsApps\TonyHenrique.tonyuwpteste_1.1.12.0_x64__h3h3tmhvy8gfc

start shell:C:\Program Files\WindowsApps\CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2019.522.0_x64__79rhkp1fndgsc!App

# Complete Ubuntu Setup
# https://docs.microsoft.com/en-us/windows/wsl/initialize-distro
```

Extra Links

* [Windows Subsystem for Linux Installation Guide for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
* [Manage and configure Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
* [Troubleshooting Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/troubleshooting)
* [Command Reference for Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/reference)

## Ubuntu Setup

Append to ~/.bashrc

```bash
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
#export DOCKER_HOST=tcp://10.0.2.190:2376 DOCKER_TLS_VERIFY=1
#export DOCKER_CERT_PATH=~/.docker/
source <(kubectl completion bash)
export DOCKER_HOST=tcp://localhost:2375
#export DOCKER_HOST=tcp://0.0.0.0:2375

alias k=kubectl
complete -F __start_kubectl k

alias d=docker
```

## Setup Kubernetes on Ununtu

```bash
sudo apt-get update -y && sudo apt-get install -y \
bash-completion \
nmap \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common
```

## Setup Docker on Ununtu

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update -y && sudo apt-get install docker-ce-cli
pip --version || sudo apt-get install python-pip
pip install --user docker-compose
curl https://raw.githubusercontent.com/docker/compose/1.24.0/contrib/completion/bash/docker-compose \
| sudo tee /etc/bash_completion.d/docker-compose > /dev/null
echo "export DOCKER_HOST=tcp://localhost:2375" >> ~/.bashrc && source ~/.bashrc
docker run --rm -ti hello-world
```

## Setup Kubernetes on Ununtu

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
kubectl config set-cluster fake --server=https://5.6.7.8 --insecure-skip-tls-verify
kubectl config set-credentials nobody 
kubectl config set-context fake --cluster=fake --namespace=default --user=nobody
mkdir -p ~/.kube
ln -sf /c/users/<YOUR_USER>/.kube/config ~/.kube/config
kubectl cluster-info
```

