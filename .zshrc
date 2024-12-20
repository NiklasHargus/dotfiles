eval "$(starship init zsh)"

alias ls='exa --icons --sort=type --group-directories-first --no-permissions --no-filesize --no-user'
alias ll='exa -all --icons --sort=type --no-user'
alias clc=clear
# alias ls='ls --color=auto'
# alias ll='ls -al'

alias grep='grep --color=auto'
alias vim='nvim'
alias open='xdg-open'
alias top='btop'

alias lg='lazygit'
alias gits='git status -s'
alias git status='git status -s'


alias cat='bat --theme=Catppuccin-mocha'

alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | rg -S percentage'
alias wlan='nmcli device wifi connect'

alias screenshot='slurp | grim -g - - | wl-copy'
alias screenshot_save='slurp | grim -g -'

autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
# export QT_STYLE_OVERRIDE=adwaita-dark

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/niklas/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/niklas/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/niklas/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/niklas/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/niklas/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/home/niklas/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

fpath+=/home/niklas/repos/conda-zsh-completion
compinit conda

eval $(thefuck --alias)
MOZ_ENABLE_WAYLAND=1
unsetopt BEEP

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/niklas/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<


eval "$(fzf --zsh)"
