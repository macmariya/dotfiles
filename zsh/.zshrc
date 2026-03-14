# .zshrc - zshエントリポイント
# モジュール化された設定ファイルを読み込む薄いローダー

# --- Oh My Zsh 設定 ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source "$ZSH/oh-my-zsh.sh"

# --- モジュール読み込み ---
# $ZDOTDIR または $HOME/.config/zsh からモジュールファイルを順序付きでsource
_zsh_config_dir="${ZDOTDIR:-$HOME/.config/zsh}"

_zsh_modules=(
  exports.zsh     # 環境変数
  path.zsh        # PATH構成・ツール初期化
  aliases.zsh     # エイリアス定義
  completion.zsh  # 補完設定
  functions.zsh   # ユーティリティ関数
)

for _mod in "${_zsh_modules[@]}"; do
  [[ -f "$_zsh_config_dir/$_mod" ]] && source "$_zsh_config_dir/$_mod"
done

# マシン固有設定（gitignore対象）
[[ -f "$_zsh_config_dir/local.zsh" ]] && source "$_zsh_config_dir/local.zsh"

unset _zsh_config_dir _zsh_modules _mod
