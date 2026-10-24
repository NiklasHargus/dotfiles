eval "$(starship init zsh)"

bindkey -v
export KEYTIMEOUT=1
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
bindkey -M viins '\t' menu-select "$terminfo[kcbt]" menu-select

alias ls='exa --icons --sort=type --group-directories-first --no-permissions --no-filesize --no-user'
alias ll='exa -all --icons --sort=type --no-user'
alias clc=clear

alias grep='grep --color=auto'
alias vim='nvim'
alias open='xdg-open'
alias battery_mode='sudo tlp power-saver'
alias balanced_mode='sudo tlp balanced'
alias performance_mode='sudo tlp performance'

alias cat='bat --theme="Catppuccin Mocha"'

function search {
      local query="$*"
      local encoded=""
      local i

      for (( i=0; i<${#query}; i++ )); do
          local c="${query:$i:1}"
          case "$c" in
              [a-zA-Z0-9.~_-]) encoded+="$c" ;;
              ' ') encoded+='+' ;;
              *) encoded+=$(printf '%%%02X' "'$c") ;;
          esac
      done

      w3m -o meta_refresh=1 "https://duckduckgo.com/?q=$encoded" # avoids manual refresh
}


alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | rg -S percentage'
alias wlan='nmcli device wifi connect'

export PATH="$HOME/.local/bin:$PATH"

alias screenshot='slurp | grim -g - - | wl-copy'
alias screenshot_save='slurp | grim -g -'

# Only run the slow compaudit security check once a day; otherwise reuse the cached dump.
# autoload -Uz compinit
# if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#   compinit
# else
#   compinit -C
# fi

# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' menu select

set -o vi
EDITOR=nvim
export MANPAGER='nvim +Man!'
export NVIM_APPNAME='nvim12'
export LD_LIBRARY_PATH='/usr/local/lib/:'

export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_QT_STYLE_OVERRIDE=Adwaita-Dark
export QT_STYLE_OVERRIDE=adwaita-dark
export MAKEFLAGS="-j8"

MOZ_ENABLE_WAYLAND=1
unsetopt BEEP

eval "$(fzf --zsh)"
export VCPKG_ROOT=/home/niklas/repos/vcpkg
export PATH=$VCPKG_ROOT:$PATH

#eval "$(zoxide init zsh)"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
##[[ -f /home/niklas/.dart-cli-completion/zsh-config.zsh ]] && . /home/niklas/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]



# Added by Antigravity CLI installer
export PATH="/home/niklas/.local/bin:$PATH"
