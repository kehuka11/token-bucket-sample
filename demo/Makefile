# 変数定義
IMAGE_NAME = local/tokenbucket
CONTAINER_NAME = tokenbucket-app
COMPOSE_FILE = docker-compose.yml

# デフォルトターゲット
.DEFAULT_GOAL := help

# ヘルプ表示
.PHONY: help
help: ## 利用可能なコマンドを表示
	@echo "利用可能なコマンド:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Dockerイメージのビルド
.PHONY: build
build: ## Dockerイメージをビルド
	@echo "Dockerイメージをビルド中..."
	docker build -t $(IMAGE_NAME) .
	@echo "ビルド完了: $(IMAGE_NAME)"

# アプリケーションのみ起動
.PHONY: up-app
up-app: build ## アプリケーションのみを起動
	@echo "アプリケーションを起動中..."
	docker-compose -f $(COMPOSE_FILE) up -d app
	@echo "アプリケーションが起動しました (http://localhost:8080)"

# 全サービス起動
.PHONY: up
up: build ## 全サービスを起動
	@echo "全サービスを起動中..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "全サービスが起動しました"
	@echo "アプリケーション: http://localhost:8080"
	@echo "Redis Commander: http://localhost:8081 (admin/admin123)"
	@echo "RedisInsight: http://localhost:8001"
	@echo "軽量API: http://localhost:8082"
	@echo "HTTPBin: http://localhost:8086"

# 全サービス停止
.PHONY: down
down: ## 全サービスを停止
	@echo "全サービスを停止中..."
	docker-compose -f $(COMPOSE_FILE) down
	@echo "全サービスが停止しました"

# 全サービス停止（ボリュームも削除）
.PHONY: down-v
down-v: ## 全サービスを停止し、ボリュームも削除
	@echo "全サービスを停止し、ボリュームも削除中..."
	docker-compose -f $(COMPOSE_FILE) down -v
	@echo "全サービスとボリュームが削除されました"

# ログ表示
.PHONY: logs
logs: ## アプリケーションのログを表示
	docker-compose -f $(COMPOSE_FILE) logs -f app

# 全サービスのログ表示
.PHONY: logs-all
logs-all: ## 全サービスのログを表示
	docker-compose -f $(COMPOSE_FILE) logs -f

# ステータス表示
.PHONY: status
status: ## 全サービスのステータスを表示
	docker-compose -f $(COMPOSE_FILE) ps

# アプリケーションのヘルスチェック
.PHONY: health
health: ## アプリケーションのヘルスチェック
	@echo "アプリケーションのヘルスチェック中..."
	@curl -f http://localhost:8080/actuator/health || echo "アプリケーションが起動していません"

# クリーンアップ
.PHONY: clean
clean: down-v ## 全サービスとボリュームを削除し、イメージも削除
	@echo "Dockerイメージを削除中..."
	docker rmi $(IMAGE_NAME) || true
	@echo "クリーンアップ完了"

# 開発用（ログ付きで起動）
.PHONY: dev
dev: build ## 開発用にログ付きで起動
	@echo "開発モードで起動中..."
	docker-compose -f $(COMPOSE_FILE) up

# 再起動
.PHONY: restart
restart: down up ## 全サービスを再起動

# アプリケーションのみ再起動
.PHONY: restart-app
restart-app: ## アプリケーションのみを再起動
	@echo "アプリケーションを再起動中..."
	docker-compose -f $(COMPOSE_FILE) restart app
	@echo "アプリケーションが再起動しました"

# 依存関係の確認
.PHONY: deps
deps: ## 依存関係を確認
	@echo "Gradle依存関係を確認中..."
	./gradlew dependencies

# テスト実行
.PHONY: test
test: ## テストを実行
	@echo "テストを実行中..."
	./gradlew test

# ビルド（テストなし）
.PHONY: build-no-test
build-no-test: ## テストなしでビルド
	@echo "テストなしでビルド中..."
	./gradlew build -x test

# プロジェクト情報表示
.PHONY: info
info: ## プロジェクト情報を表示
	@echo "プロジェクト情報:"
	@echo "  イメージ名: $(IMAGE_NAME)"
	@echo "  コンテナ名: $(CONTAINER_NAME)"
	@echo "  ポート: 8080"
	@echo "  Java バージョン: 21"
	@echo "  Spring Boot バージョン: 3.5.5" 