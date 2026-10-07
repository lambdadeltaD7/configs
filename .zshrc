# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=500000
SAVEHIST=200000
unsetopt beep
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/lambdadelta/.zshrc'

#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
# Delete the entire line with Ctrl + Backspace
bindkey '^H' kill-whole-line
# Jump to the beginning of the line with Ctrl + Shift + Left Arrow
bindkey '^[[1;7D' beginning-of-line
# Jump to the end of the line with Ctrl + Shift + Right Arrow
bindkey '^[[1;7C' end-of-line
alias ls='ls --color=auto'
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'
alias grep='grep --color=auto'
alias vpn='setsid /home/lambdadelta/apps/v2rayN-linux-64/v2rayN >/dev/null 2>&1 &'
# End of lines added by compinstall
eval "$(starship init zsh)"

# Qwen Code PATH block begin
export PATH='/home/lambdadelta/.local/bin':$PATH
# Qwen Code PATH block end

source "${HOME}/fzf_init.sh"

export EDITOR=nvim
export VISUAL=nvim


# just search in youtube
yt (){
	if [[ $# == 0 ]]; then
		echo "Desc: Search in youtube from term"
		echo "    Usage: yt some search query"
		return 0
	fi

	query=$(echo $* | jq -sRr @uri)
	firefox "https://www.youtube.com/results?search_query=$query" >/dev/null 2>&1 &!
}


# use gopota
cg() {
    local prompt query

    if [[ -t 0 ]]; then
        if (( $# == 0 )); then
            echo "Desc: prompt ChatGPT in web"
            echo "    Usage: cg some search query"
            echo "    Usage: cat file | cg"
            return 1
        fi

        prompt="$*"
    else
        prompt=$(cat)

        if (( $# > 0 )); then
            prompt="$*"$'\n\n'"$prompt"
        fi
    fi

    query=$(printf '%s' "$prompt" | jq -sRr @uri)

    firefox "https://chatgpt.com/?q=$query" >/dev/null 2>&1 &!
}

cgt() {
	res=$(cat)
	echo $res

	if [[ $1 == -f ]]; then
		echo
		cat $2
	else
		printf "\n#${1}\n"
	fi
}



fastfetch() {
  local p="#$(grep -oP 'primary\s*=\s*"\K[0-9a-fA-F]+' ~/.config/hypr/scheme/current.lua | head -1)"
  command fastfetch --color "$p" --color-keys "$p" --color-title "$p" \
    --logo-color-1 "$p" --logo-color-2 "$p" --logo-color-3 "$p" \
    --logo-color-4 "$p" --logo-color-5 "$p" --logo-color-6 "$p" \
    --logo-color-7 "$p" --logo-color-8 "$p" --logo-color-9 "$p" "$@"
}
