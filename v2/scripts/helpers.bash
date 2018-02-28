function spaceship_pod
{
	kubectl get pods -l class=spaceship,org=empire | grep ^spaceship- | awk '{print $1}' | head -1
}

function deathstar_ip
{
	kubectl get pods -l class=deathstar,org=empire -o wide | grep ^deathstar | head -1 | awk '{print $6}'
}

function get_xwing_pod
{
	kubectl get pods -l class=spaceship,org=alliance | grep ^xwing- | awk '{print $1}' | head -1
}

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

function probe_api2
{
	local -r ip=$1
	local -r pod=$2
	local -r good=$3
	local -r method=$4
	local -r path=$5
	local -r RETURN=$6

	printf "$yellow%4s$reset deathstar%s:" "$method" "$path"

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

readonly  reset=$(tput sgr0)
readonly    red=$(tput bold; tput setaf 1)
readonly  green=$(tput bold; tput setaf 2)
readonly  yellow=$(tput bold; tput setaf 3)


readonly   blue=$(tput bold; tput setaf 6)
readonly timeout=$(if [ "$(uname)" == "Darwin" ]; then echo "1"; else echo "0.1"; fi)
readonly ipv6regex='(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'

function desc() {
    maybe_first_prompt
    echo "$blue# $@$reset"
    prompt
}

function desc_rate() {
    maybe_first_prompt
    rate=30
    if [ -n "$DEMO_RUN_FAST" ]; then
      rate=1000
    fi
    echo "$blue# $@$reset" | pv -q -L 30
    prompt
}

function prompt() {
    echo -n "$yellow\$ $reset"
}

function run() {
    echo "$green$@$reset" | pv -q -L 30
    eval "$@"
    prompt
    if [ -z "$DEMO_AUTO_RUN" ]; then
      stty -echo
      read
      stty echo
    fi
}

function run_prompt() {
    echo "$green$@$reset" | pv -qL 30
    prompt
    if [ -z "$DEMO_AUTO_RUN" ]; then
      read
    fi
}

started=""
function maybe_first_prompt() {
    if [ -z "$started" ]; then
        prompt
        started=true
    fi
}

# After a `run` this variable will hold the stdout of the command that was run.
# If the command was interactive, this will likely be garbage.
DEMO_RUN_STDOUT=""

function relative() {
    for arg; do
        echo "$(realpath $(dirname $(which $0)))/$arg" | sed "s|$(realpath $(pwd))|.|"
    done
}

trap "echo" EXIT
