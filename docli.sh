#!/bin/bash

#Gobal variable
#Definition of variables: Version; Name of Script; Directory empty; Command of all containers; All containers; Stack; File temporal

VERSION="0.0.1"
NOMSRC=$(basename "$0")
DIREMPTY=""
CMD=""
ALL=""
STACK=""
FTEMP=""

# Alternative
# INVENTORY="inventory"
: "${INVENTORY="inventory"}"

DIRINVENTORY="$(dirname "${INVENTORY}")/"

#Help Function

function usage() {
	#Error control
	numerr=$1
	cat <<EOF
    Usage: ${NOMSRC} [OPTION] … [COMMAND] .. [ARGUMENT] …
    Manage multiple docker-compose stacks with a single command.

    Options:
     --all                   Apply the command to all groups in the inventory
     --context[=CTX]         Inventory group to apply the command
     --help, -h              Display this help message and exit
     --version, -v           Output version information and exit
		Note: 'CTX'= stack group or directory
    Commands:
     create --context=CTX     Create a new empty directory with the specified context
	 	Note: 'CTX' = empty directory
     up     --context=CTX     Start Docker Compose stack in the specified context
     down   --context=CTX     Stop Docker Compose stack in the specified context
	 	Note: 'CTX' = stack group

     Examples:
     docli create --context=stack_1
     docli up --context=group_2
     docli down --all
EOF
	exit # "${numerr}"
}

# Error message

err_msg() {
	retcod=$?
	echo -e "$*" >&2
	usage $retcod
}


# Execute docker compose

ex_dc() {
	# Local variables arguments line
	local dir=$1
	local cmd=$2
	local arg_docker=""

	# echo "DEBUG ex_dc: $dir $cmd" && read n
	
	# Docker compose control in directory
	if [ -d "${dir}" ]; then
		[[ ${cmd} == "up" ]] && arg_docker="-d"
		if [ -f "${dir}/docker-compose.yaml" ]; then
			#			pushd . &>/dev/null
			#			cd ${dir}
			echo "Execute: docker compose --project-directory ""${dir}"" ""${cmd}"" ${arg_docker} "
			docker compose --project-directory "${dir}" "${cmd}" ${arg_docker} ||
				echo -e "An error occurred while running docker compose on ${dir}" >&2
			#			popd &>/dev/null
			else
			echo -e "WARNING: Does not exist ${dir}/docker-compose.yaml. Does not run, skips" >&2
		fi
	else
		echo -e "WARNING: Does not exist folder ${dir}" >&2
		return 1
	fi
}

# File inventory control
# First arg1 inventory arg2 all/group arg3 file_temporal

proc_inventory() {
	# Definition of local variables: File inventory; Process all; File temporal 
	local finv=$1
	local proc_all=$2
	local ftemp=$3

	# echo "DEBUG: finv=""$1"" proc_all="$2" ftemp=""${ftemp}"""
	# read n

	[[ -f "${ftemp}" ]] || err_msg "There isn't temporary file ${ftemp}"
	

	case ${proc_all} in
	yes)
		# echo "DEBUG: Entrer yes"
		grep -Ev "^$" "${finv}" | grep -Ev "^\[" >"${ftemp}"
		# echo "DEBUG: Press a key"
		# return $?
		;;
	*)
		# Check the group exists
		grep -Eq "^\[$proc_all\]" "${finv}" || {
			# echo -e "The group doesn´t exist ${proc_all}" >&2 
			exit 1
		}
		# Process inventory
		grep -Ev "^$" "${finv}" | sed -rn "/^\[$proc_all\]$/,/^\[/p" | grep -Ev "^\[" >"${ftemp}"
		;;
	esac

}

#
# Main
#
[[ $# -gt 0 ]] || usage

#Variable definition control file inventory

PINVENTORY="${DIRINVENTORY}/${INVENTORY}"
[[ -f "${PINVENTORY}" ]] || err_msg "The file doesn't exist ${PINVENTORY}"

cd "${DIRINVENTORY}" || err_msg "Error switching to: ${DIRINVENTORY}"

# Parssing line command, arguments control
# Parameters numbers

nparm=$#
while [[ $# -gt 0 ]]; do
	#Options control: Help; Version; Create; Up,Down; Rest
	case $(echo "$1" | tr 'A-Z' 'a-z') in
	-h | --help)
		usage
		;;
	-v | --version)
		echo -e "${NOMSRC}:\n\tVersion: ${VERSION}"
		exit 0
		;;
	create)
		shift
		arg1=$(echo "$1" | cut -d '=' -f 1 | tr -d ' ')
		arg2=$(echo "$1" | cut -d '=' -f 2 | tr -d ' ')
		[[ ${arg1} == "--context" ]] || usage
		[[ -n ${arg2} ]] || usage
		DIREMPTY=${arg2}
		break
		;;
	up | down)
		CMD=$1
		shift
		arg1=$(echo "$1" | cut -d '=' -f 1 | tr -d ' ')
		arg2=$(echo "$1" | cut -d '=' -f 2 | tr -d ' ')
		if [[ ${arg1} == "--all" ]]; then
			ALL="yes"
			break
		fi
		[[ ${arg1} == "--context" ]] || usage
		[[ -n ${arg2} ]] || usage
		STACK=${arg2}
		break
		;;

	*)
		echo -e "Invalid option" >&2
		usage
		;;
	esac
	shift
done

# Parameters numbres control

[[ ${nparm} -ne 2 ]] && err_msg "Invalid syntax/Only one operation supported"

# Check for duplicate groups
# Command inventory duplicate groups

cmdinvdup=$(sort "${PINVENTORY}" | grep -E "^\[" | uniq -d)
[[ $(wc -l <<<"${cmdinvdup}") -ne 1 ]] &&
	err_msg "There are duplicate groups in the file \
$(tr -s '/' <<<"${PINVENTORY}").\nDuplicate Groups: ${cmdinvdup}"

# echo -e "DEBUG: DIREMPTY=${DIREMPTY} CMD=${CMD} ALL=${ALL} STACK=${STACK} INVENTORY=${INVENTORY}"

# Process Create directory empty

if [[ -n ${DIREMPTY} ]]; then
	[ -d "${DIRINVENTORY}/${DIREMPTY}" ] &&  echo "${DIRINVENTORY}/${DIREMPTY} folder exist" >&2
	mkdir "${DIRINVENTORY}/${DIREMPTY}" || # msg_err "Can not create ${DIRINVENTORY}/${DIREMPTY}"
	exit 0
fi

# echo -e "DEBUG: DIREMPTY=${DIREMPTY} CMD=${CMD} ALL=${ALL} STACK=${STACK} INVENTORY=${INVENTORY}"

# File temporal control

FTEMP=$(mktemp --suffix=_exdc) || msg_err "Can not create temporal file"
trap 'test -n "${FTEMP}" && test -f "${FTEMP}" && rm -f "${FTEMP}"' 0 SIGHUP SIGQUIT SIGTERM

# echo "DEBUG: FTEMP=${FTEMP} CMD=${CMD} ALL=${ALL}"
# read n

# Process inventory all

if [[ ${ALL} == "yes" ]]; then
	proc_inventory "${PINVENTORY}" ${ALL} "${FTEMP}" || err_msg "An error occurred while processing ${PINVENTORY}"
else
	proc_inventory "${PINVENTORY}" "${STACK}" "${FTEMP}" || err_msg "An error occurred while processing ${PINVENTORY}"
fi

# echo "DEBUG: Press a key" && read n

# Loop execute docker compose in folder and error control

for folder in $(cat "${FTEMP}"); do
	echo -e "Running docker compose ${CMD} in folder ${folder}"
	ex_dc "${folder}" "${CMD}" || echo -e "ERROR: when running docker compose ${CMD} in folder ${folder}" >&2
done
