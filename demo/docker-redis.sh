#!/bin/bash

# Docker Redis 操作スクリプト
# 使用方法: ./docker-redis.sh [start|stop|restart|status|logs|clean|dev]

COMPOSE_FILE="docker-compose.yml"
DEV_COMPOSE_FILE="docker-compose.dev.yml"

# 色付きの出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    echo -e "${BLUE}Docker Redis 操作スクリプト${NC}"
    echo ""
    echo "使用方法: $0 [コマンド]"
    echo ""
    echo "コマンド:"
    echo "  start     - Redis環境を起動（本格版）"
    echo "  dev       - Redis環境を起動（開発版）"
    echo "  stop      - Redis環境を停止"
    echo "  restart   - Redis環境を再起動"
    echo "  status    - コンテナの状態を表示"
    echo "  logs      - Redisのログを表示"
    echo "  clean     - コンテナとボリュームを削除"
    echo "  cli       - Redis CLIに接続"
    echo "  monitor   - Redisのモニタリングモード"
    echo "  info      - Redisの情報を表示"
    echo "  keys      - キーの一覧を表示"
    echo "  help      - このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 start    # 本格版Redis環境を起動"
    echo "  $0 dev      # 開発版Redis環境を起動"
    echo "  $0 cli      # Redis CLIに接続"
}

# 本格版Redis環境を起動
start_production() {
    echo -e "${GREEN}本格版Redis環境を起動中...${NC}"
    docker-compose -f $COMPOSE_FILE up -d
    echo -e "${GREEN}起動完了！${NC}"
    echo ""
    echo -e "${BLUE}アクセス可能なサービス:${NC}"
    echo -e "  ${CYAN}Redis:${NC} localhost:6379"
    echo -e "  ${CYAN}Redis Commander:${NC} http://localhost:8081 (admin/admin123)"
    echo -e "  ${CYAN}RedisInsight:${NC} http://localhost:8001"
    echo -e "  ${CYAN}Redis Exporter:${NC} http://localhost:9121/metrics"
    echo ""
    echo -e "${PURPLE}モックAPIサービス:${NC}"
    echo -e "  ${CYAN}軽量API (Prism):${NC} http://localhost:8082"
    echo -e "  ${CYAN}中程度API (Prism):${NC} http://localhost:8083"
    echo -e "  ${CYAN}重量API (Prism):${NC} http://localhost:8084"
    echo -e "  ${CYAN}ユーザーAPI (Prism):${NC} http://localhost:8085"
    echo -e "  ${CYAN}HTTPBin:${NC} http://localhost:8086"
    echo -e "  ${CYAN}JSONPlaceholder:${NC} http://localhost:8087"
    echo ""
    echo -e "${YELLOW}モックAPIのテスト例:${NC}"
    echo -e "  curl http://localhost:8082/api/light"
    echo -e "  curl http://localhost:8083/api/medium"
    echo -e "  curl http://localhost:8084/api/heavy"
    echo -e "  curl http://localhost:8085/api/user/user123"
    echo -e "  curl http://localhost:8086/get"
    echo -e "  curl http://localhost:8087/posts"
}

# 開発版Redis環境を起動
start_dev() {
    echo -e "${GREEN}開発版Redis環境を起動中...${NC}"
    docker-compose -f $DEV_COMPOSE_FILE up -d
    echo -e "${GREEN}起動完了！${NC}"
    echo ""
    echo -e "${BLUE}アクセス可能なサービス:${NC}"
    echo -e "  ${CYAN}Redis:${NC} localhost:6379"
    echo -e "  ${CYAN}Redis Commander:${NC} http://localhost:8081"
}

# Redis環境を停止
stop_redis() {
    echo -e "${YELLOW}Redis環境を停止中...${NC}"
    docker-compose -f $COMPOSE_FILE down
    docker-compose -f $DEV_COMPOSE_FILE down
    echo -e "${GREEN}停止完了！${NC}"
}

# Redis環境を再起動
restart_redis() {
    echo -e "${YELLOW}Redis環境を再起動中...${NC}"
    stop_redis
    sleep 2
    start_production
}

# コンテナの状態を表示
show_status() {
    echo -e "${BLUE}コンテナの状態:${NC}"
    echo ""
    docker-compose -f $COMPOSE_FILE ps
    echo ""
    echo -e "${BLUE}開発版コンテナの状態:${NC}"
    echo ""
    docker-compose -f $DEV_COMPOSE_FILE ps
}

# Redisのログを表示
show_logs() {
    echo -e "${BLUE}Redisのログを表示中...${NC}"
    echo -e "${YELLOW}Ctrl+C で終了${NC}"
    echo ""
    docker-compose -f $COMPOSE_FILE logs -f redis
}

# コンテナとボリュームを削除
clean_all() {
    echo -e "${RED}警告: すべてのデータが削除されます！${NC}"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}コンテナとボリュームを削除中...${NC}"
        docker-compose -f $COMPOSE_FILE down -v
        docker-compose -f $DEV_COMPOSE_FILE down -v
        docker volume prune -f
        echo -e "${GREEN}クリーンアップ完了！${NC}"
    else
        echo -e "${BLUE}キャンセルされました${NC}"
    fi
}

# Redis CLIに接続
connect_cli() {
    echo -e "${GREEN}Redis CLIに接続中...${NC}"
    docker exec -it tokenbucket-redis redis-cli
}

# Redisのモニタリングモード
monitor_redis() {
    echo -e "${GREEN}Redisのモニタリングモードを開始...${NC}"
    echo -e "${YELLOW}Ctrl+C で終了${NC}"
    echo ""
    docker exec -it tokenbucket-redis redis-cli monitor
}

# Redisの情報を表示
show_info() {
    echo -e "${BLUE}Redisの情報:${NC}"
    echo ""
    docker exec -it tokenbucket-redis redis-cli info
}

# キーの一覧を表示
show_keys() {
    echo -e "${BLUE}Redisのキー一覧:${NC}"
    echo ""
    docker exec -it tokenbucket-redis redis-cli keys "*"
}

# モックAPIのテスト
test_mock_apis() {
    echo -e "${PURPLE}モックAPIのテストを実行中...${NC}"
    echo ""
    
    echo -e "${CYAN}軽量API (Prism):${NC}"
    curl -s "http://localhost:8082/api/light" | jq '.' 2>/dev/null || curl -s "http://localhost:8082/api/light"
    echo ""
    
    echo -e "${CYAN}中程度API (Prism):${NC}"
    curl -s "http://localhost:8083/api/medium" | jq '.' 2>/dev/null || curl -s "http://localhost:8083/api/medium"
    echo ""
    
    echo -e "${CYAN}重量API (Prism):${NC}"
    curl -s "http://localhost:8084/api/heavy" | jq '.' 2>/dev/null || curl -s "http://localhost:8084/api/heavy"
    echo ""
    
    echo -e "${CYAN}ユーザーAPI (Prism):${NC}"
    curl -s "http://localhost:8085/api/user/user123" | jq '.' 2>/dev/null || curl -s "http://localhost:8085/api/user/user123"
    echo ""
    
    echo -e "${CYAN}HTTPBin:${NC}"
    curl -s "http://localhost:8086/get" | jq '.' 2>/dev/null || curl -s "http://localhost:8086/get"
    echo ""
    
    echo -e "${CYAN}JSONPlaceholder:${NC}"
    curl -s "http://localhost:8087/posts" | jq '.' 2>/dev/null || curl -s "http://localhost:8087/posts"
    echo ""
}

# メイン処理
case "${1:-help}" in
    start)
        start_production
        ;;
    dev)
        start_dev
        ;;
    stop)
        stop_redis
        ;;
    restart)
        restart_redis
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    cli)
        connect_cli
        ;;
    monitor)
        monitor_redis
        ;;
    info)
        show_info
        ;;
    keys)
        show_keys
        ;;
    test)
        test_mock_apis
        ;;
    help|*)
        show_help
        ;;
esac 