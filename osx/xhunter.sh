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

# Domains to be verified
# /System/Library/LaunchAgents/com.apple.AirPlayUIAgent.plist
# /System/Library/LaunchAgents/com.apple.accountsd.plist
# /System/Library/LaunchAgents/com.apple.akd.plist
# /System/Library/LaunchAgents/com.apple.aos.migrate.plist
# /System/Library/LaunchAgents/com.apple.appleseed.seedusaged.plist
# /System/Library/LaunchAgents/com.apple.appstoreupdateagent.plist
# /System/Library/LaunchAgents/com.apple.apsctl.plist
# /System/Library/LaunchAgents/com.apple.cmfsyncagent.plist
# /System/Library/LaunchAgents/com.apple.coreservices.appleid.authentication.plist
# /System/Library/LaunchAgents/com.apple.diagnostics_agent.plist
# /System/Library/LaunchAgents/com.apple.mdmclient.agent.plist
# /System/Library/LaunchAgents/com.apple.metadata.SpotlightNetHelper.plist
# /System/Library/LaunchAgents/com.apple.photolibraryd.plist
# /System/Library/LaunchAgents/com.apple.quicklook.config.plist
# /System/Library/LaunchAgents/com.apple.security.idskeychainsyncingproxy.plist
# /System/Library/LaunchAgents/com.apple.security.keychain-circle-notification.plist
# /System/Library/LaunchAgents/com.apple.soagent.plist
# /System/Library/LaunchAgents/com.apple.storeinappd.plist
# /System/Library/LaunchAgents/com.apple.storelegacy.plist
# /System/Library/LaunchAgents/com.apple.swcd.plist
# /System/Library/LaunchDaemons/com.apple.CrashReporterSupportHelper.plist
# /System/Library/LaunchDaemons/com.apple.FileSyncAgent.sshd.plist
# /System/Library/LaunchDaemons/com.apple.GameController.gamecontrollerd.plist
# /System/Library/LaunchDaemons/com.apple.SubmitDiagInfo.plist
# /System/Library/LaunchDaemons/com.apple.akd.plist
# /System/Library/LaunchDaemons/com.apple.appleseed.fbahelperd.plist
# /System/Library/LaunchDaemons/com.apple.awdd.plist
# /System/Library/LaunchDaemons/com.apple.coreservices.appleid.passwordcheck.plist
# /System/Library/LaunchDaemons/com.apple.diagnosticd.plist
# /System/Library/LaunchDaemons/com.apple.eapolcfg_auth.plist
# /System/Library/LaunchDaemons/com.apple.mdmclient.daemon.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.echosvc.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.lsarpc.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.mdssvc.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.netlogon.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.srvsvc.plist
# /System/Library/LaunchDaemons/com.apple.msrpc.wkssvc.plist
# /System/Library/LaunchDaemons/com.apple.nehelper.plist
# /System/Library/LaunchDaemons/com.apple.nfsd.plist
# /System/Library/LaunchDaemons/com.apple.preferences.timezone.admintool.plist
# /System/Library/LaunchDaemons/com.apple.preferences.timezone.auto.plist
# /System/Library/LaunchDaemons/com.apple.storeagent.daemon.plist
# /System/Library/LaunchDaemons/com.apple.symptomsd.plist
