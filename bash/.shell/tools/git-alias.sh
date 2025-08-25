#!/usr/bin/env zsh?

function lazyg() {
  # Ensure GPG agent is running
  if ! gpg-agent &>/dev/null; then
    echo "Restarting gpg-agent..."
    killall gpg-agent &>/dev/null
    gpg-agent --daemon &>/dev/null
  fi
  git add .
  git commit -S -a -m "$1"
  git push
}

alias ga="git add"
alias gaa="git add --all"
alias gcm="git commit -m"
