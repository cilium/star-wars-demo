#!/bin/bash

readonly  reset=$(tput sgr0)
readonly  green=$(tput bold; tput setaf 2)
readonly yellow=$(tput bold; tput setaf 3)
readonly   blue=$(tput bold; tput setaf 6)
readonly timeout=$(if [ "$(uname)" == "Darwin" ]; then echo "1"; else echo "0.1"; fi)

function desc() {
    maybe_first_prompt
    echo "$blue# $@$reset"
    prompt
}

function desc_rate() {
    maybe_first_prompt
    rate=50
    if [ -n "$DEMO_RUN_FAST" ]; then
      rate=1000
    fi
    echo "$blue# $@$reset" | pv -qL $rate
    prompt
}

function prompt() {
    echo -n "$yellow\$ $reset"
}

function run2() {
    echo "$green$@$reset" | pv -qL $rate
    $@
    prompt
    if [ -z "$DEMO_AUTO_RUN" ]; then
      read -s
    fi
}

function run3() {
    echo "$green$@$reset" | pv -qL $rate
    prompt
    if [ -z "$DEMO_AUTO_RUN" ]; then
      read -s
    fi
}

started=""
function maybe_first_prompt() {
    if [ -z "$started" ]; then
        prompt
        started=true
    fi
}
 
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
