#!/bin/bash

source scripts/helpers.bash

function probe_api
{
	local -r ip=$1
	local -r pod=$2
	local -r good=$3
	local -r method=$4
	local -r path=$5

	printf "$yellow%4s$reset deathstar%s:" "$method" "$path"

	RETURN=$(kubectl exec $pod -- curl -s -o /dev/null -w '%{http_code}' -X$method ${deathstar_name}$path)
	RETURN="${RETURN//$'\n'}"
	if [[ "${RETURN}" == "200" || ${RETURN} == "404" ]]; then
		if [ $good == "good" ]; then
			echo " ✅  $green $RETURN [OK]$reset"
		else
			echo " 🙈  $red 200 [Vulnerable]$reset"
		fi
	else
		echo " 🔒 $green $RETURN [Protected]$reset"
	fi
}

xwing_pod=$(get_xwing_pod)
deathstar_name=deathstar.default.svc.cluster.local

desc "Calling fleet: Attack deathstar!"
run "kubectl exec -ti ${xwing_pod} -- curl -s -XPUT ${deathstar_name}/v1/exhaust-port"

desc "Oh no! It's a trap..."

desc "Scanning deathstar API..."
run "./scan_api.sh"

desc "Luke! We need your help!"
desc "Investigating loaded policy"

run "colordiff -Nru policy/l7_policy.yaml policy/l7_policy.real.yaml"

desc "Using the FORCE to attack the deathstar"
run "kubectl exec -ti ${xwing_pod} -- curl -H 'X-Has-Force: True' -XPUT ${deathstar_name}/v1/exhaust-port"
