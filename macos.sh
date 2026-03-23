#!/bin/zsh
# =============================================================================
# macOS システム設定スクリプト
# 対象: macOS 26.3.1 Tahoe / Apple Silicon (M5)
# 使い方: chmod +x macos.sh && ./macos.sh
# 注意: 実行後に再ログインまたは再起動を推奨
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# 色付きメッセージ出力関数
# -----------------------------------------------------------------------------
info()    { print -P "%F{blue}[INFO]%f  $*" }
success() { print -P "%F{green}[OK]%f    $*" }
warn()    { print -P "%F{yellow}[WARN]%f  $*" }
error()   { print -P "%F{red}[ERROR]%f $*" >&2 }

# -----------------------------------------------------------------------------
# sudo キープアライブ（スクリプト実行中に sudo が切れないようにする）
# -----------------------------------------------------------------------------
info "sudo 権限を確認しています..."
sudo -v

# バックグラウンドで定期的に sudo を更新（スクリプト終了まで維持）
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done &
SUDO_KEEPALIVE_PID=$!

# スクリプト終了時にバックグラウンドプロセスを停止
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; info "完了しました。再ログインまたは再起動を推奨します。"' EXIT

# -----------------------------------------------------------------------------
# 0. スクリーンショット保存先ディレクトリの作成
# -----------------------------------------------------------------------------
SCREENSHOT_DIR="$HOME/Documents/Screenshots"
if [[ ! -d "$SCREENSHOT_DIR" ]]; then
    mkdir -p "$SCREENSHOT_DIR"
    success "スクリーンショット保存先を作成: $SCREENSHOT_DIR"
fi

# =============================================================================
# 1. 一般設定
# =============================================================================
info "一般設定を適用中..."

# ダークモードを有効化
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# スクロールバーを常に表示（任意）
# defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# アクセント・ハイライトカラー（デフォルトのまま）
# defaults write NSGlobalDomain AppleAccentColor -int 4   # Blue

# 自動的にアップデートを確認（セキュリティ更新のみ自動インストール）
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

success "一般設定を適用しました"

# =============================================================================
# 2. キーボード設定
# =============================================================================
info "キーボード設定を適用中..."

# キーリピート速度（2 = 最速に近い、デフォルト: 6）
defaults write NSGlobalDomain KeyRepeat -int 2

# キーリピート開始までの遅延（15 = 短め、デフォルト: 25）
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Fn キーを標準ファンクションキーとして使用
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false

# スペルの自動修正を無効化（コーディング時の誤変換防止）
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# 自動大文字変換を無効化
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# ピリオドの自動挿入を無効化（スペース2回打ちでピリオドになるのを防ぐ）
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# スマートダッシュを無効化（-- が — になるのを防ぐ）
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# スマートクォートを無効化（" が " " になるのを防ぐ）
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

success "キーボード設定を適用しました"

# =============================================================================
# 3. Finder 設定
# =============================================================================
info "Finder 設定を適用中..."

# 隠しファイル・ドットファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# すべてのファイル拡張子を常に表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# パスバーを表示（ウィンドウ下部に現在のパスを表示）
defaults write com.apple.finder ShowPathbar -bool true

# ステータスバーを表示（ファイル数・空き容量）
defaults write com.apple.finder ShowStatusBar -bool true

# タイトルバーにフルパスを表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# ネットワークドライブに .DS_Store ファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# USB 接続ドライブに .DS_Store ファイルを作成しない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# デフォルトの表示形式をリスト表示に設定
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# 検索時はデフォルトでカレントフォルダを対象にする
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# ゴミ箱を空にする前の警告を無効化（任意）
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# ダウンロードフォルダのデフォルト表示をリスト表示に
defaults write com.apple.finder FXPreferredGroupBy -string "None"

# スプリングロード（ドラッグ時のフォルダ自動展開）を有効化
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0.3

success "Finder 設定を適用しました"

# =============================================================================
# 4. Dock 設定
# =============================================================================
info "Dock 設定を適用中..."

# Dock のアイコンサイズ（px）
defaults write com.apple.dock tilesize -int 48

# Dock を自動的に隠す・表示する
defaults write com.apple.dock autohide -bool true

# Dock 自動非表示の遅延をなくす（即時非表示）
defaults write com.apple.dock autohide-delay -float 0

# Dock の表示アニメーション速度を高速化
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Dock の配置（bottom / left / right）
defaults write com.apple.dock orientation -string "bottom"

# 起動中のアプリにインジケーターを表示
defaults write com.apple.dock show-process-indicators -bool true

# 最近使ったアプリを Dock に表示しない
defaults write com.apple.dock show-recents -bool false

# ウィンドウのしまい方: genie（デフォルト）/ scale
defaults write com.apple.dock mineffect -string "scale"

# アプリ起動時のバウンスアニメーションを有効化
defaults write com.apple.dock launchanim -bool true

# Mission Control のアニメーションを高速化
defaults write com.apple.dock expose-animation-duration -float 0.1

# Dock のマグニフィケーション（マウスオーバーで拡大）は無効
defaults write com.apple.dock magnification -bool false

success "Dock 設定を適用しました"

# =============================================================================
# 5. スクリーンショット設定
# =============================================================================
info "スクリーンショット設定を適用中..."

# 保存先を ~/Documents/Screenshots に変更
defaults write com.apple.screencapture location -string "$SCREENSHOT_DIR"

# ウィンドウの影を除去してスクリーンショット
defaults write com.apple.screencapture disable-shadow -bool true

# ファイル形式を PNG に設定（デフォルト）
defaults write com.apple.screencapture type -string "png"

# スクリーンショット撮影時のサムネイルプレビューを無効化（即座に保存）
defaults write com.apple.screencapture show-thumbnail -bool false

success "スクリーンショット設定を適用しました（保存先: $SCREENSHOT_DIR）"

# =============================================================================
# 6. トラックパッド設定（任意）
# =============================================================================
info "トラックパッド設定を適用中..."

# タップでクリックを有効化
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# トラッキングスピード（0.0 〜 3.0、デフォルト: 1.0）
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.0

# ナチュラルスクロール（コンテンツが指と同方向に動く）は有効のまま
# 無効にする場合:
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# 3本指ドラッグを有効化（アクセシビリティ設定）
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# フルスクリーンアプリケーション間をスワイプ: 4本指で左右にスワイプ（デフォルト: 3本指）
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0

# Mission Control: 4本指で上にスワイプ（デフォルト: 3本指）
# アプリ Exposé: 4本指で下にスワイプ（デフォルト: 無効）
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0

success "トラックパッド設定を適用しました"

# =============================================================================
# 7. デフォルトブラウザ設定
# =============================================================================
info "デフォルトブラウザを設定中..."

if command -v defaultbrowser &>/dev/null; then
  defaultbrowser chrome
  success "デフォルトブラウザを Google Chrome に設定しました"
else
  warn "defaultbrowser コマンドが見つかりません — デフォルトブラウザ設定をスキップします"
fi

# =============================================================================
# 8. サウンド設定
# =============================================================================
info "サウンド設定を適用中..."

# インターフェース操作音を無効化（ゴミ箱を空にするときの音等）
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0

# 起動音を無効化（Apple Silicon 対応）
sudo nvram StartupMute=%01 2>/dev/null || warn "起動音の設定はスキップしました（権限不足の可能性）"

success "サウンド設定を適用しました"

# =============================================================================
# 9. メニューバー設定
# =============================================================================
info "メニューバー設定を適用中..."

# 時計のフォーマット（24時間表示）
defaults write com.apple.menuextra.clock DateFormat -string "EEE M/d H:mm"

# バッテリーの残量をパーセントで表示（macOS Ventura+ 対応）
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

success "メニューバー設定を適用しました"

# =============================================================================
# 10. セキュリティ・プライバシー設定
# =============================================================================
info "セキュリティ設定を適用中..."

# スクリーンセーバー起動後のパスワード要求を即座に有効化
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ファイアウォールを有効化
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || \
    warn "ファイアウォールの設定はスキップしました"

success "セキュリティ設定を適用しました"

# =============================================================================
# 11. 変更を反映（プロセス再起動）
# =============================================================================
info "Finder と Dock を再起動して設定を反映中..."

killall Finder 2>/dev/null && success "Finder を再起動しました" || true
killall Dock   2>/dev/null && success "Dock を再起動しました" || true

# SystemUIServer（メニューバー）も再起動
killall SystemUIServer 2>/dev/null && success "SystemUIServer を再起動しました" || true

# =============================================================================
# 完了メッセージ
# =============================================================================
print ""
print -P "%F{green}============================================%f"
print -P "%F{green}  macOS 設定の適用が完了しました。%f"
print -P "%F{green}============================================%f"
print ""
warn "一部の設定（ダークモード、キーボードなど）は再ログインまたは再起動後に有効になります。"
print ""
