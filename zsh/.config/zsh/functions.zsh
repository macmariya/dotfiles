# functions.zsh - ユーティリティ関数
# 頻繁に使うシェル操作を関数化

# --- mkcd: ディレクトリ作成して移動 ---
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# --- extract: 各種アーカイブを統一的に展開 ---
extract() {
  if [[ ! -f "$1" ]]; then
    echo "extract: '$1' はファイルではありません" >&2
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1"    ;;
    *.tar.gz)  tar xzf "$1"    ;;
    *.tar.xz)  tar xJf "$1"    ;;
    *.bz2)     bunzip2 "$1"    ;;
    *.rar)     unrar x "$1"    ;;
    *.gz)      gunzip "$1"     ;;
    *.tar)     tar xf "$1"     ;;
    *.tbz2)    tar xjf "$1"    ;;
    *.tgz)     tar xzf "$1"    ;;
    *.zip)     unzip "$1"      ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1"       ;;
    *.zst)     unzstd "$1"     ;;
    *)
      echo "extract: '$1' の形式に対応していません" >&2
      return 1
      ;;
  esac
}

# --- weather: 天気情報を取得 ---
weather() {
  curl -s "wttr.in/${1:-Tokyo}?lang=ja"
}

# --- portcheck: 指定ポートを使用しているプロセスを表示 ---
portcheck() {
  if [[ -z "$1" ]]; then
    echo "使い方: portcheck <ポート番号>" >&2
    return 1
  fi
  lsof -i :"$1"
}

# --- tre: tree の短縮版（深さ制限付き）---
tre() {
  tree -C -L "${1:-3}" --dirsfirst
}

# --- ghclone: GitHubリポジトリをクローンして移動 ---
ghclone() {
  if [[ -z "$1" ]]; then
    echo "使い方: ghclone <owner/repo>" >&2
    return 1
  fi
  git clone "https://github.com/$1.git" && cd "$(basename "$1")"
}
