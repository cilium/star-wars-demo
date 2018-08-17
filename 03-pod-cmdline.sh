#!/bin/bash

source scripts/helpers.bash

xwing_pod=$(get_xwing_pod)
deathstar_name=deathstar.default.svc.cluster.local
echo "kubectl exec -ti ${xwing_pod} -- curl -XGET ${deathstar_name}/v1/"
