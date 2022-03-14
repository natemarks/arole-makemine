#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") resource_dir

Ths script will donwload a top-level directory from the S3 deployment-resource
bucket for the current account and region to/tmp/deployment-resource. example:
com.imprivata.371143864265.us-east-1.deployment-resources/[resource_dir]

Available options:

-h, --help      Print this help and exit
EOF
  exit
}



setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ ${#args[@]} -eq 0 ]] && usage && die "Missing script arguments"
  [[ ${#args[@]} -gt 1 ]] && usage && die "Too many script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here
declare -r DEPLOYMENT_RESOURCES="/tmp/deployment-resource"
declare -r AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output=text | awk '{print $1}')
declare -r AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region | sed 's/\"//g')
declare -r BUCKET="com.imprivata.${AWS_ACCOUNT_ID}.${AWS_REGION}.deployment-resources"
declare -r S3_PATH="${BUCKET}/${args[0]}"
msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"

msg "${GREEN}Downloading deployment resources from bucket: ${S3_PATH}${NOFORMAT}"
mkdir -p "${DEPLOYMENT_RESOURCES}/${args[0]}"
aws s3 sync s3://"${S3_PATH}" "${DEPLOYMENT_RESOURCES}/${args[0]}"
