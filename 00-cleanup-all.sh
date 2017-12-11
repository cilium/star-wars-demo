#!/bin/bash
./00-cleanup-policy.sh
kubectl delete -f 02-deathstar.yaml
kubectl delete -f 03-xwing.yaml
