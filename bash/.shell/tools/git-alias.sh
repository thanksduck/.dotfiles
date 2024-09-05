#!/usr/bin/env bash

function lazyg(){
    git add .
    git commit -a -m "$1"
    git push
}

alias ga="git add"
alias gaa="git add --all"
alias gcm="git commit -m"
