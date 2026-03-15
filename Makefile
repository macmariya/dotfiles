# Makefile — dotfiles 管理コマンド集
# 使用方法: make help

SHELL := /bin/zsh
DOTFILES := $(shell pwd)

# GNU Stow で管理するパッケージ一覧
STOW_PACKAGES := zsh git tmux nvim ghostty bin ssh

# stow コマンドの共通オプション
STOW_FLAGS := --restow --target=$(HOME) --dir=$(DOTFILES)

.PHONY: install update stow unstow brew brew-dump macos clean ssh-fix help

# デフォルトターゲット: ヘルプを表示
.DEFAULT_GOAL := help

## install: bootstrap.sh を実行して初期セットアップを行う
install:
	@zsh $(DOTFILES)/bootstrap.sh

## update: Homebrew パッケージを更新し、シンボリックリンクを再作成する
update:
	@echo "\033[1;36m==> Homebrew アップデート\033[0m"
	brew update
	brew bundle --file=$(DOTFILES)/Brewfile
	brew upgrade
	@echo "\033[1;36m==> シンボリックリンク再作成\033[0m"
	$(MAKE) stow
	@echo "\033[0;32m[OK] アップデートが完了しました\033[0m"

## stow: 全パッケージのシンボリックリンクを作成/更新する
stow:
	@echo "\033[1;36m==> GNU Stow: リンク作成\033[0m"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$(DOTFILES)/$$pkg" ]; then \
			echo "  stow: $$pkg"; \
			stow $(STOW_FLAGS) $$pkg; \
		else \
			echo "\033[0;33m[WARN] $$pkg ディレクトリが見つかりません — スキップ\033[0m"; \
		fi \
	done
	@echo "\033[0;32m[OK] stow が完了しました\033[0m"
	@$(MAKE) ssh-fix

## unstow: 全パッケージのシンボリックリンクを削除する
unstow:
	@echo "\033[1;36m==> GNU Stow: リンク削除\033[0m"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$(DOTFILES)/$$pkg" ]; then \
			echo "  unstow: $$pkg"; \
			stow --delete --target=$(HOME) --dir=$(DOTFILES) $$pkg; \
		else \
			echo "\033[0;33m[WARN] $$pkg ディレクトリが見つかりません — スキップ\033[0m"; \
		fi \
	done
	@echo "\033[0;32m[OK] unstow が完了しました\033[0m"

## brew: Brewfile を適用してパッケージをインストールする
brew:
	@echo "\033[1;36m==> Brewfile 適用\033[0m"
	brew bundle --file=$(DOTFILES)/Brewfile
	@echo "\033[0;32m[OK] Brewfile の適用が完了しました\033[0m"

## brew-dump: 現在インストール済みのパッケージを Brewfile に書き出す
brew-dump:
	@echo "\033[1;36m==> Brewfile ダンプ\033[0m"
	brew bundle dump --file=$(DOTFILES)/Brewfile --force
	@echo "\033[0;32m[OK] Brewfile を更新しました: $(DOTFILES)/Brewfile\033[0m"

## macos: macOS のシステム設定を適用する (macos.sh を実行)
macos:
	@echo "\033[1;36m==> macOS システム設定\033[0m"
	@if [ -f "$(DOTFILES)/macos.sh" ]; then \
		zsh $(DOTFILES)/macos.sh; \
		echo "\033[0;32m[OK] macOS 設定が完了しました\033[0m"; \
	else \
		echo "\033[0;31m[ERROR] macos.sh が見つかりません\033[0m"; \
		exit 1; \
	fi

## ssh-fix: SSH ディレクトリとファイルのパーミッションを修正する
ssh-fix:
	@echo "\033[1;36m==> SSH パーミッション修正\033[0m"
	@if [ -d "$(HOME)/.ssh" ]; then \
		chmod 700 $(HOME)/.ssh; \
		chmod 600 $(HOME)/.ssh/config 2>/dev/null || true; \
		chmod 700 $(HOME)/.ssh/config.d 2>/dev/null || true; \
		chmod 600 $(HOME)/.ssh/config.d/* 2>/dev/null || true; \
		chmod 600 $(HOME)/.ssh/id_* 2>/dev/null || true; \
		chmod 644 $(HOME)/.ssh/*.pub 2>/dev/null || true; \
		echo "\033[0;32m[OK] SSH パーミッションを修正しました\033[0m"; \
	else \
		echo "\033[0;33m[WARN] ~/.ssh が見つかりません — スキップ\033[0m"; \
	fi

## clean: 壊れたシンボリックリンクを検出して一覧表示する
clean:
	@echo "\033[1;36m==> 壊れたシンボリックリンクを検索中...\033[0m"
	@broken=$$(find $(HOME) \
		-maxdepth 5 \
		-not \( -path "$(HOME)/Library/*" -prune \) \
		-not \( -path "$(HOME)/.Trash/*" -prune \) \
		-type l ! -e 2>/dev/null); \
	if [ -z "$$broken" ]; then \
		echo "\033[0;32m[OK] 壊れたシンボリックリンクはありません\033[0m"; \
	else \
		echo "\033[0;33m[WARN] 以下のリンクが壊れています:\033[0m"; \
		echo "$$broken"; \
		echo ""; \
		echo "削除する場合: find \$$HOME -maxdepth 5 -type l ! -e -delete"; \
	fi

## help: 利用可能なコマンド一覧を表示する (デフォルト)
help:
	@echo ""
	@echo "\033[1;32mdotfiles Makefile — 利用可能なコマンド\033[0m"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) \
		| sed 's/^## //' \
		| awk -F': ' '{ printf "  \033[1;34mmake %-12s\033[0m %s\n", $$1, $$2 }'
	@echo ""
	@echo "管理パッケージ: $(STOW_PACKAGES)"
	@echo ""
