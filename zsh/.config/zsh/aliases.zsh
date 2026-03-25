# aliases.zsh - エイリアス定義
# 頻出コマンドの短縮形と便利なエイリアス

# --- dotfiles管理 ---
# ZDOTDIR から dotfiles ルートを逆算（zsh/.config/zsh → 3階層上）
alias dots='cd "${ZDOTDIR:h:h:h}"'
alias reload='exec zsh'

# --- エディタ ---
alias v='nvim'
alias vi='nvim'

# --- ナビゲーション ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -lAh'
alias la='ls -A'
alias l='ls -CF'

# --- Git短縮 ---
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpull='git pull'

# --- リモート開発 ---
# マシン固有の接続先は local.zsh に定義してください
# 例: alias codeT3='code --remote ssh-remote+<host> /path/to/project'

# --- Docker ---
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'
alias dprune='docker system prune -a'

# --- 安全策 ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# --- ユーティリティ ---
alias path='echo $PATH | tr ":" "\n"'
alias brewup='brew update && brew upgrade && brew cleanup'
alias myip='curl -s https://ifconfig.me'
