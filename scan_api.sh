#!/bin/bash

source scripts/helpers.bash

xwing_pod=$(get_xwing_pod)
deathstar_name=deathstar.default.svc.cluster.local

probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/"
probe_api $deathstar_name $xwing_pod "good" "POST" "/v1/request-landing"
probe_api $deathstar_name $xwing_pod "bad" "PUT" "/v1/cargobay"
probe_api $deathstar_name $xwing_pod "bad" "GET" "/v1/hyper-matter-reactor/status"
