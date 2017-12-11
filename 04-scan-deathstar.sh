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

desc "Executing REST API call..."
run "kubectl exec -ti ${xwing_pod} -- curl -XGET ${deathstar_name}/v1"

echo "$green Scanning for deathstar API...$reset"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/"
probe_api $deathstar_name $xwing_pod "bad" "POST" "/v1/request-landing"
probe_api $deathstar_name $xwing_pod "bad" "PUT" "/v1/cargobay"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/hyper-matter-reactor/status"
probe_api $deathstar_name $xwing_pod "bad" "PUT" "/v1/exhaust-port"
