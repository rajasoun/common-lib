#!/usr/bin/env bash

BASE_URL="https://raw.githubusercontent.com/rajasoun/common-lib/main/docker/"

# shellcheck source=/dev/null
source <(curl -s source "$BASE_URL/wrapper.sh")

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case ${choice} in
    "clean")
      docker_clean_all
    ;;
    "speed-test")
        speed-test
    ;;
    "docker-run")
        _docker "$@"
    ;;
    *)
    echo "${RED}Usage: automator/ci.sh <build | e2e | taerdown | shell> [-d]${NC}"
cat <<-EOF
Commands:
---------
  clean       -> Clean all Docker Containers, Volumes and Images
  speed-test  -> Run Speed Test
  docker-run  -> Wrapper for MinTTY Docker
EOF
    ;;
esac
