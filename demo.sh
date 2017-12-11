#!/bin/bash

source scripts/helpers.bash

desc_rate "A long time ago, in a container cluster far, far away...."
desc_rate ""
desc_rate "It is a period of civil war. The Empire has adopted"
desc_rate "microservices and continuous delivery, despite this,"
desc_rate "Rebel spaceships, striking from a hidden cluster, have"
desc_rate "won their first victory against the evil Galactic Empire."
desc_rate ""
desc_rate "During the battle, Rebel spies managed to steal the"
desc_rate "swagger API specification to the Empire's ultimate weapon,"
desc_rate "the deathstar."

run "kubectl -n kube-system get pods"

desc_rate "The empire starts deploying a deathstar..."
run "cat diagram.txt"
run "kubectl apply -f 02-deathstar.yaml"
run "kubectl create -f policy/l4_policy.yaml"
run "watch -n 1 kubectl get pod,svc,ciliumnetworkpolicies"

desc_rate "Wow, what's that? The alliance sends out some X-Wings to check it out"
run "kubectl apply -f 03-xwing.yaml"

run "watch -n 1 kubectl get pod,svc,ciliumnetworkpolicies"

xwing_pod=$(get_xwing_pod)
deathstar_name=deathstar.default.svc.cluster.local

desc_rate "To all X-Wings: Execute REST API call to main API endpoint"
run "kubectl exec -ti ${xwing_pod} -- curl -XGET ${deathstar_name}/v1"

desc_rate "Starting API scanner"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/"
probe_api $deathstar_name $xwing_pod "good" "POST" "/v1/request-landing"
probe_api $deathstar_name $xwing_pod "bad" "PUT" "/v1/cargobay"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/hyper-matter-reactor/status"
probe_api2 $deathstar_name $xwing_pod "bad" "PUT" "/v1/exhaust-port" "200"

desc_rate "Weakness detected"
desc_rate "We all know what is coming...."
run ""
desc_rate "--------------------------------------------"
desc_rate "In the meantime, the empire Ops are deploying Cilium"
desc_rate "and roll out an L7 policy"
cat policy/l7_policy.yaml.orig

desc_rate "Importing policy..."
run "kubectl create -f policy/l7_policy.yaml"

desc_rate "----------------------------------------"
desc_rate "The alliance returns..."
run ""

desc_rate "Calling alliance fleet: Attack deathstar!"
run "kubectl exec -ti ${xwing_pod} -- curl -s -XPUT ${deathstar_name}/v1/exhaust-port"

desc_rate "Oh no! It's a trap..."

desc_rate "Scanning deathstar API..."

probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/"
probe_api $deathstar_name $xwing_pod "good" "POST" "/v1/request-landing"
probe_api $deathstar_name $xwing_pod "bad" "PUT" "/v1/cargobay"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/hyper-matter-reactor/status"
probe_api2 $deathstar_name $xwing_pod "bad" "PUT" "/v1/exhaust-port" "403"

desc_rate "Luke! We need your help!"
run ""
desc_rate "Investigating loaded policy"

run "colordiff -Nru policy/l7_policy.yaml.orig policy/l7_policy.yaml"

desc_rate "Using the force to attack the deathstar"
run "kubectl exec -ti ${xwing_pod} -- curl -H 'X-Has-Force: True' -XPUT ${deathstar_name}/v1/exhaust-port"
