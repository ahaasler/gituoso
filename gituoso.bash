#!/bin/bash

# Enable __git_ps1
source ~/.gituoso/git-components/git-prompt.sh
# Enable completion
source ~/.gituoso/git-components/git-completion.bash

# Configuration
export GITUOSO_USEARROWS=false
export GITUOSO_RESETPROMPT=false

# Color constants
GIT_BLACK="\e[00;30m"
GIT_BLACK_BOLD="\e[01;30m"
GIT_RED="\e[00;31m"
GIT_RED_BOLD="\e[01;31m"
GIT_GREEN="\e[00;32m"
GIT_GREEN_BOLD="\e[01;32m"
GIT_YELLOW="\e[00;33m"
GIT_YELLOW_BOLD="\e[01;33m"
GIT_BLUE="\e[00;34m"
GIT_BLUE_BOLD="\e[01;34m"
GIT_PURPLE="\e[00;35m"
GIT_PURPLE_BOLD="\e[1;35m"
GIT_CYAN="\e[00;36m"
GIT_CYAN_BOLD="\e[01;36m"
GIT_WHITE="\e[00;37m"
GIT_WHITE_BOLD="\e[01;37m"

CLEAR="\[\e[0m\]"

# Git status codes (ordered by importance)
GIT_STATUS_CODES=( "U " "M " "D " "R " "C " "A " "?? " )

# Human readable git status codes
declare -A GIT_STATUS_MESSAGES=(
    ["U "]="unmerged"
    ["M "]="modified"
    ["D "]="deleted"
    ["R "]="renamed"
    ["C "]="copied"
    ["A "]="added"
    ["?? "]="untracked"
)

# Colors for status codes
declare -A GIT_STATUS_COLORS=(
    ["U "]=$GIT_RED_BOLD
    ["M "]=$GIT_YELLOW_BOLD
    ["D "]=$GIT_YELLOW_BOLD
    ["R "]=$GIT_YELLOW_BOLD
    ["C "]=$GIT_BLUE_BOLD
    ["A "]=$GIT_BLUE_BOLD
    ["?? "]=$GIT_PURPLE_BOLD
)


function git_work_tree {
    git rev-parse &> /dev/null
}

function git_dir {
    git rev-parse --is-inside-git-dir
}

function git_upstream_defined {
    git rev-list @{u}..HEAD &> /dev/null
}

function git_branch {
    if git_work_tree ; then
        __git_ps1 "${1:-%s }"
    fi
}

function git_project_name {
    if git_work_tree ; then
        # Inside work tree
        if  [[ $(git_dir) == "true" ]] ; then
            # Inside .git directory
            if [[ $(git rev-parse --git-dir) != "." ]] ; then
                # Not base git directory
                printf "[$(basename $(dirname `git rev-parse --git-dir`))] "
            else
                # Base git directory
                printf "[$(basename $(dirname `pwd`))] "
            fi
        elif [[ $(git rev-parse --show-toplevel) != $(pwd) ]] ; then
            # Not in git project base directory
            printf "[$(basename `git rev-parse --show-toplevel`)] "
        fi
    fi
}

function git_status_color {
    if git_work_tree ; then
        if [[ $(git_dir) == false ]] ; then
            local status=$(git status --porcelain)
            for i in "${GIT_STATUS_CODES[@]}" ; do
                if [ "${status/$i}" != "$status" ] ; then
                    printf ${GIT_STATUS_COLORS[$i]}
                    # Use worst status code's color
                    return 0
                fi
            done
            # Working directory clean
            printf $GIT_GREEN_BOLD
        else
            # Status not available
            printf $GIT_WHITE_BOLD
        fi
    fi
}

function git_branch_summary {
    if git_work_tree ; then
        if [[ $(git_dir) == false ]] ; then
            if git_upstream_defined ; then
                local up="^"
                local down="v"
                if $GITUOSO_USEARROWS ; then
                    # Unicode chars cause anomalies in reverse search
                    up="↑"
                    down="↓"
                fi
                printf "| $up$(git rev-list @{u}..HEAD | wc -l) $down$(git rev-list HEAD..@{u} | wc -l)"
            else
                printf "| No upstream"
            fi
        fi
    fi
}

function git_status_summary {
    if git_work_tree ; then
        if [[ $(git_dir) == false ]] ; then
            printf " |"
            local status=$(git status --porcelain -u)
            local empty=true
            for i in "${GIT_STATUS_CODES[@]}" ; do
                count=$(echo "$status" | grep -o "$i" | wc -l)
                if [[ "$count" != "0" ]] ; then
                    if ! ( $empty ) ; then
                        printf ","
                    fi
                    printf " $count ${GIT_STATUS_MESSAGES[$i]}"
                    empty=false
                fi
            done
            if ( $empty ) ; then
                printf " Working directory clean"
            fi
        fi
    fi
}

# Add git info to prompt
if $GITUOSO_RESETPROMPT ; then
    export PS1="\[\e[00;37m\]\u@\h:\w\\$ \[\e[0m\]"
fi
export PS1="${PS1}\[\$(git_status_color)\]\$(git_branch)$CLEAR";

# Add git info to title bar
if [ "$TERM" != "linux" ] ; then
    # Not console
    export PS1="\[\e]0;\W \$(git_project_name)\$(git_branch)\$(git_branch_summary)\$(git_status_summary)\a\]${PS1}"
fi

