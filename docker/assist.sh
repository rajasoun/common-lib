#!/usr/bin/env bash

# shellcheck source=/dev/null
source <(curl -s source "https://raw.githubusercontent.com/rajasoun/common-lib/main/docker/wrapper.sh")

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case ${choice} in
    "clean")
      docker_clean_all
    ;;
    "speed-test")
      speed-test
    ;;
    "wrapper")
      echo -e "${GREEN}\nRun${NC}"
      echo -e "${ORANGE}source <(curl -s source "https://raw.githubusercontent.com/rajasoun/common-lib/main/docker/wrapper.sh")${NC}"
    ;;
    *)
    echo "${RED}Usage: $0 < clean | speed-test > ${NC}"
cat <<-EOF
Commands:
---------
  clean       -> Clean all Docker Containers, Volumes and Images
  speed-test  -> Run Speed Test
  docker-run  -> Wrapper for MinTTY Docker
EOF
    ;;
esac
