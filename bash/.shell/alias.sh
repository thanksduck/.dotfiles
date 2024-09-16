#!/usr/bin/env bash
alias bp='vim ~/.zshrc'
alias sa='source ~/.zshrc;echo "ZSH aliases sourced."'

#color into ls
# alias ls='colorls'
alias ls='ls --color=auto -F'
alias grep='grep --color=auto'
alias efgrep='fgrep --color=auto'
alias grep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -Cp'
alias python='/opt/homebrew/bin/python3'
alias py='/opt/homebrew/bin/python3'


# Create aliases for the functions
alias move-images='move_images'
alias move-videos='move_videos'
alias move-documents='move_documents'
alias compress-dir='compress_directory'
alias count-files='count_files_by_type'

alias remote-connect=ssh-connect

# screen copy alias
alias scrcpy='scrcpy --shortcut-mod=lalt,ralt'

# tailscale alias

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias td='tailscale status && (tailscale status | grep -qE "sora.*offers exit node" && tailscale down) || (tailscale status | grep -qE "sora.*active; exit node" && tailscale set --exit-node= && tailscale down)'


### sourcing from various files always keep it at the end.

# alias from tools folder

# Source the tools.sh script
if [ -f ~/.shell/tools/tools.sh ]; then
  . ~/.shell/tools/tools.sh
fi

# SSH connect
if [ -f ~/.shell/private/.sshconnect.sh ]; then
  . ~/.shell/private/.sshconnect.sh
fi


# npm alias
alias tailwind='tailwind_setup -v'

# shorten_url alias
alias surl='shorten_url'
