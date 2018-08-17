
# Cilium Star Wars Demo

Amazing Star Wars themed demo including HTTP policy enforcement

## Requirements

- minikube >= 0.22.3
- bash
- kubectl

## Overview

                                     +-----------------------------------------+
     +---------------------+         | Deathstar 💀 💀 💀 📡 📡 📡 🙈 🙈       |
     | Spaceship 🚀 🚀 🚀  |-------->|    GET /v1/                             |
     +---------------------+    +--->|   POST /v1/request-landing              |
                                |    |    PUT /v1/cargobay                     |
     +---------------------+    |    |    GET /v1/hyper-matter-reactor/status  |
     | X-Wing 🚀 🚀 🚀     |----+    +-----------------------------------------+
     +---------------------+

## Demo Flow

    ./00-intro.sh
    $ #A long time ago, in a container cluster far, far away....
    $ # 
    $ # It is a period of civil war. The Empire has adopted
    $ # microservices and continuous delivery, despite this,
    $ # Rebel spaceships, striking from a hidden cluster, have
    $ # won their first victory against the evil Galactic Empire.
    $ # 
    $ # During the battle, Rebel spies managed to steal the
    $ # swagger API specification to the Empire's ultimate weapon,
    $ # the deathstar.

Deploy the deathstar and some spaceships:

    kubectl create -f 01-deathstar.yaml -f 02-xwing.yaml
    service "deathstar" created
    deployment.extensions "deathstar" created
    deployment.extensions "spaceship" created
    deployment.extensions "xwing" created

Check that pods are deployed

    kubectl get pods
    NAME                         READY     STATUS    RESTARTS   AGE
    deathstar-76995f4687-5v477   1/1       Running   0          23s
    deathstar-76995f4687-b6c2n   1/1       Running   0          23s
    deathstar-76995f4687-qw8tn   1/1       Running   0          23s
    spaceship-5f55cc75c5-77l8w   1/1       Running   0          23s
    spaceship-5f55cc75c5-hglt8   1/1       Running   0          23s
    spaceship-5f55cc75c5-tbkl5   1/1       Running   0          23s
    spaceship-5f55cc75c5-wmz2k   1/1       Running   0          23s
    xwing-bbc56674d-2mf74        1/1       Running   0          23s
    xwing-bbc56674d-8n82f        1/1       Running   0          23s
    xwing-bbc56674d-pgjmf        1/1       Running   0          23s

Pick a random X-Wing pod and generate the service URL (Feel free to do this
manually):

    ./03-pod-cmdline.sh
    kubectl exec -ti xwing-bbc56674d-2mf74 -- curl -XGET deathstar.default.svc.cluster.local/v1/

Scan the deathstar with the X-Wing:

    kubectl exec -ti xwing-bbc56674d-2mf74 -- curl -XGET deathstar.default.svc.cluster.local/v1/
    {
            "name": "Death Star",
            "model": "DS-1 Orbital Battle Station",
            "manufacturer": "Imperial Department of Military Research, Sienar Fleet Systems",
            "cost_in_credits": "1000000000000",
            "length": "120000",
            "crew": "342953",
            "passengers": "843342",
            "cargo_capacity": "1000000000000",
            "hyperdrive_rating": "4.0",
            "starship_class": "Deep Space Mobile Battlestation",
            "api": [
                    "GET   /v1",
                    "GET   /v1/healthz",
                    "POST  /v1/request-landing",
                    "PUT   /v1/cargobay",
                    "GET   /v1/hyper-matter-reactor/status",
                    "PUT   /v1/exhaust-port"
            ]
    }

Load the L3-L7 policy to protect the deathstar:

    kubectl create -f policy/l7_policy.yaml
    ciliumnetworkpolicy.cilium.io "deathstar-api-protection" created

Try and `PUT` something into the exhaust port of the deathstar:

    kubectl exec -ti xwing-bbc56674d-2mf74 -- curl -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
    Access denied

Notice that Cilium has rejected the REST API call as per policy.

Use the `X-Has-Force: true` HTTP header to let the deathstar explode:

    kubectl exec -ti xwing-bbc56674d-2mf74 -- curl -XPUT -H 'X-Has-Force: True' deathstar.default.svc.cluster.local/v1/exhaust-port
    Panic: deathstar exploded

    goroutine 1 [running]:
    main.HandleGarbage(0x2080c3f50, 0x2, 0x4, 0x425c0, 0x5, 0xa)
            /code/src/github.com/empire/deathstar/
            temp/main.go:9 +0x64
    main.main()
            /code/src/github.com/empire/deathstar/
            temp/main.go:5 +0x85

Celebrate with the alliance
