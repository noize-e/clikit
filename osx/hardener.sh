#!/usr/bin/env bash

set -o errexit
set -o errtrace

read -p "Input a Computer's Name: " name && sudo scutil --set ComputerName ${name}

if read -p "Input a Hostname[dev-x2]: " name &>/dev/null ; then
	sudo scutil --set LocalHostName ${name} 2>/dev/null
	sudo scutil --set HostName ${name} 2>/dev/null
	echo "kern.hostname=$name" | sudo tee -a /etc/sysctl.conf
fi

sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist 2>/dev/null

# spotlight
defaults delete com.apple.Spotlight orderedItems 2>/dev/null
sudo mdutil -a -i off 2>/dev/null
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes" 2>/dev/null

# safari    
defaults write com.apple.Safari UniversalSearchEnabled -bool NO; \
defaults write com.apple.Safari SuppressSearchSuggestions -bool YES 2>/dev/null
defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool NO

defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 2>/dev/null
defaults write com.apple.Safari IncludeInternalDebugMenu -bool YES 2>/dev/null
defaults write com.apple.Safari ShowSidebarInTopSites -bool NO 2>/dev/null
defaults write com.apple.Safari WebKitOmitPDFSupport -bool YES 2>/dev/null
defaults write com.apple.Safari WebKitJavaScriptEnabled -bool NO 2>/dev/null
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptEnabled -bool NO  2>/dev/null

# Disable Remote Manager
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop 2>/dev/null
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off 2>/dev/null

# Disable (Default) Remote Apple Events
sudo systemsetup -setremoteappleevents on 2>/dev/null

# Itunes
defaults delete com.apple.iTunes recentSearches 2>/dev/null
defaults delete com.apple.iTunes StoreUserInfo 2>/dev/null
defaults delete com.apple.iTunes WirelessBuddyID 2>/dev/null

~/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/ksinstall --nuke 2 2>/dev/null
# Disable Notification Center Service
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2  2>/dev/null

sudo chflags schg ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2  2>/dev/null

defaults write com.apple.captive.control Active -bool NO  2>/dev/null

sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES  2>/dev/null

defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES  2>/dev/null

defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool NO  2>/dev/null

chflags nohidden /  2>/dev/null
chflags nohidden ~/Library 2>/dev/null
defaults write com.apple.finder AppleShowAllFiles -bool YES 2>/dev/null
defaults write NSGlobalDomain AppleShowAllExtensions -bool YES 2>/dev/null
defaults write NSGlobalDomain AppleInterfaceStyle Dark 2>/dev/null
defaults write com.apple.menuextra.battery ShowPercent -string YES 2>/dev/null
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool YES 2>/dev/null
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool YES 2>/dev/null
defaults write com.apple.dock dashboard-in-overlay -bool YES 2>/dev/null
defaults write com.apple.dock expose-animation-duration -float 0.1 2>/dev/null
defaults write com.apple.dock orientation -string 'left' 2>/dev/null
defaults write com.apple.dock launchanim -bool NO 2>/dev/null
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES 2>/dev/null
defaults write com.apple.finder ShowMountedServersOnDesktop -bool YES 2>/dev/null
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool YES 2>/dev/null
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool YES 2>/dev/null
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool YES 2>/dev/null
defaults write com.apple.finder ShowStatusBar -bool YES 2>/dev/null
defaults write com.apple.finder QLEnableTextSelection -bool YES 2>/dev/null
defaults write com.apple.DiskUtility advanced-image-options -bool YES 2>/dev/null
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool YES 2>/dev/null
defaults write com.apple.mail-shared DisableURLLoading -bool YES 2>/dev/null
defaults write com.apple.appstore ShowDebugMenu -bool YES 2>/dev/null
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 2>/dev/null
defaults write com.apple.TextEdit RichText -int 0 2>/dev/null
defaults write com.apple.TextEdit PlainTextEncoding -int 4 2>/dev/null
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 2>/dev/null
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -int 0 2>/dev/null
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool NO 2>/dev/null
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 2>/dev/null
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 2>/dev/null
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool NO 2>/dev/null
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool YES
# ----
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool YES
defaults write NSGlobalDomain AppleICUForce12HourTime -bool NO
defaults write NSGlobalDomain AppleShowScrollBars -string 'WhenScrolling'
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool YES
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Purge memory cache
sudo purge

# ----
sudo pkill Dock Finder SystemUIServer
sudo killall -9 NotificationCenter  2>/dev/null
sudo killall mds 
