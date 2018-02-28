# Cilium Star Wars Demo

Amazing Star Wars themed demo including HTTP policy enforcement

## Requirements

- minikube >= 0.22.3
- bash

## Usage

1. Create a minikube cluster: `minikube start --network-plugin=cni --bootstrapper=localkube`
2. Deploy cilium `kubectl create -f 01-cilium.yaml`
3. Run the scripted demo: `./demo.sh
4. Cleanup the state: `./00-cleanup-all.sh`

