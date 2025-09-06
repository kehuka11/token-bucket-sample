#!/bin/bash

# 遅延リフィル方式のテストスクリプト
# 使用方法: ./test_delayed_refill.sh

BASE_URL="http://localhost:8080"
API_URL="$BASE_URL/api"
DELAYED_REFILL_URL="$BASE_URL/api/delayed-refill"

echo "=== 遅延リフィル方式テスト ==="
echo ""

# ヘルスチェック
echo "1. ヘルスチェック"
curl -s "$API_URL/health"
echo ""
echo ""

# 遅延リフィルの設定確認
echo "2. 遅延リフィルの設定確認"
curl -s "$DELAYED_REFILL_URL/config" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/config"
echo ""
echo ""

# 軽量APIの連続呼び出しテスト（バースト制御確認）
echo "3. 軽量APIの連続呼び出しテスト（バースト制御確認）"
echo "100回の連続呼び出し（1秒間に1トークン補充）:"
success_count=0
for i in {1..100}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/light")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        success_count=$((success_count + 1))
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status): $body"
        break
    fi
    
    # 100ミリ秒間隔
    sleep 0.1
done
echo "成功したリクエスト数: $success_count/100"
echo ""

# 中程度APIの連続呼び出しテスト
echo "4. 中程度APIの連続呼び出しテスト（2秒間に1トークン補充）"
echo "30回の連続呼び出し:"
success_count=0
for i in {1..30}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/medium")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        success_count=$((success_count + 1))
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status): $body"
        break
    fi
    
    sleep 0.1
done
echo "成功したリクエスト数: $success_count/30"
echo ""

# 重量APIの連続呼び出しテスト
echo "5. 重量APIの連続呼び出しテスト（6秒間に1トークン補充）"
echo "10回の連続呼び出し:"
success_count=0
for i in {1..10}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/heavy")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        success_count=$((success_count + 1))
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status): $body"
        break
    fi
    
    sleep 0.1
done
echo "成功したリクエスト数: $success_count/10"
echo ""

# 遅延リフィルの状態確認
echo "6. 遅延リフィルの状態確認"
curl -s "$DELAYED_REFILL_URL/status" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/status"
echo ""
echo ""

# 各エンドポイントのバケット状態確認
echo "7. 各エンドポイントのバケット状態確認"
echo "軽量API:"
curl -s "$DELAYED_REFILL_URL/bucket/light-api/status" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/bucket/light-api/status"
echo ""

echo "中程度API:"
curl -s "$DELAYED_REFILL_URL/bucket/medium-api/status" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/bucket/medium-api/status"
echo ""

echo "重量API:"
curl -s "$DELAYED_REFILL_URL/bucket/heavy-api/status" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/bucket/heavy-api/status"
echo ""

# 手動で遅延リフィルを処理
echo "8. 手動で遅延リフィルを処理"
curl -s -X POST "$DELAYED_REFILL_URL/process" | jq '.' 2>/dev/null || curl -s -X POST "$DELAYED_REFILL_URL/process"
echo ""
echo ""

# 処理後の状態確認
echo "9. 処理後の状態確認"
sleep 2
curl -s "$DELAYED_REFILL_URL/status" | jq '.' 2>/dev/null || curl -s "$DELAYED_REFILL_URL/status"
echo ""
echo ""

# バースト制御の検証（1秒後に再試行）
echo "10. バースト制御の検証（1秒後に再試行）"
echo "1秒待機中..."
sleep 1

echo "軽量APIの再試行（5回）:"
success_count=0
for i in {1..5}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/light")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        success_count=$((success_count + 1))
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status): $body"
    fi
    
    sleep 0.1
done
echo "成功したリクエスト数: $success_count/5"
echo ""

echo "=== 遅延リフィルテスト完了 ==="
echo ""
echo "テスト結果の見方:"
echo "- バースト制御: 初期トークン数以上の連続リクエストが制限される"
echo "- 遅延リフィル: 設定された間隔でトークンが補充される"
echo "- 滑らかな制御: 急激な増減がない" 