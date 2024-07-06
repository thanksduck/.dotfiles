#color into ls
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias efgrep='fgrep --color=auto'
alias grep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias python='python3'
alias py='python3'

# alias from tools folder

# Source the tools.sh script
if [ -f ~/.shell/tools/tools.sh ]; then
  . ~/.shell/tools/tools.sh
fi

# Create aliases for the functions
alias move-images='move_images'
alias move-videos='move_videos'
