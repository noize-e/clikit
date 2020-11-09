#!/usr/bin/env bash

set -o errexit
set -o errtrace

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DOMAINS="${__DIR}/domains.txt"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

usage(){
  echo -e "${BOLD}Usage${NC}: <list|disable>"
}

ok(){
  echo -e "${GREEN}[OK]${NC} ${1:-}"
}

error(){
  echo -e "${RED}[ERROR]${NC} ${1:-}"
}

iterate(){
  sort ${DOMAINS} | uniq -u | while read line ; do
      path="${line}"
      # get item name without path and extension
      domain="$(basename ${path} .plist)"
      # get item type: agent:user - daemon:system
      type="system"; [[ "${path}" =~ .*LaunchAgents.* ]] && type="user/$(id -u)";

      [[ "$type" == "system" ]] && exec=sudo


      # ---- List service type and status ------------------------------

      if [[ "${1:-}" == "-list" ]] ;
        then
          if ${exec:-} launchctl list | grep -o "$domain" &>/dev/null;
            then
              status=1 ; label="active"
          else
            status=0 ; label="disabled"
          fi

        ls_type=0 ; [[ "${2:-}" == "-active" ]] && ls_type=1

        if (( status == ls_type )) ; then
          echo -e "${BOLD}${domain}${NC}"
          echo -e "* Type: ${BOLD}${type}${NC}"
          echo -e "* Status: ${YELLOW}${label}${NC}"
          echo -e "* Plist: ${BOLD}${path}${NC}"
          # printf "%-10s %s\n" "* Plist: " "${path}"
          # printf "%-10s %s\n" "* Type:" "${YELLOW}${type}${NC}"
          # printf "%-10s %s\n" "* Status:" "${BOLD}${label}${NC}"
          echo ''
        fi
      fi


      # ---- Disable services ------------------------------------------

      if [[ "${1:-}" == "-disable" ]] ; then
        echo -e "${YELLOW}${type}${NC} ${BOLD}${domain}${NC}";

        {
          ${exec:-} launchctl stop ${domain} && \
            ok "${domain} stopped" && \

          ${exec:-} launchctl disable ${type}/${domain} && \
            ok "${domain} disabled" && \

          ${exec:-} launchctl unload ${path} && \
            ok "${domain} unloaded" && \

          continue
        } 2>/dev/null ; error "service couldn't be disabled"
      fi

      # ---- Enable services -------------------------------------------

      if [[ "${1:-}" == "-enable" ]] ; then
        echo -e "${YELLOW}${type}${NC} ${BOLD}${domain}${NC}";

        [[ "$type" == "system" ]] && exec=sudo

        {
          ${exec:-} launchctl load -F ${path} && \
            ok "${domain} loaded" && \

          ${exec:-} launchctl enable ${type}/${domain} && \
            ok "${domain} enabled" && \

          ${exec:-} launchctl start ${domain} && \
            ok "${domain} started" && \

          continue
        } 2>/dev/null ; error "service couldn't be disabled"
      fi
  done
}


echo -e "${BOLD}OS-X Services Firewall${NC}"

case "$1" in
  list)
    iterate -list $2 ;;
  disable)
    iterate -disable ;;
  enable)
    iterate -enable ;;
  help|h|*)
    usage ;;
esac
