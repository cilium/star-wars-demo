#!/bin/bash

source scripts/helpers.bash

desc "Loading the following L7 policy"
run "cat policy/l7_policy.yaml"

desc "Importing policy..."

function load_policy
{
	currentRevison=( )
	local i
	local pod
	local namespace="kube-system"
	local pods=$(kubectl -n $namespace get pods -l k8s-app=cilium | grep cilium- | awk '{print $1}')

	for pod in $pods; do
		local rev=$(kubectl -n $namespace exec $pod -- cilium policy get | grep Revision: | awk '{print $2}')
		currentRevison[$pod]=$rev
	done

	kubectl create -f $1

	for pod in $pods; do
		local nextRev=$(expr ${currentRevison[$pod]} + 1)
		kubectl -n $namespace exec $pod -- cilium policy wait $nextRev
	done
}

load_policy policy/l7_policy.real.yaml
