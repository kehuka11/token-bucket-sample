#!/bin/bash

# 両方の実装を比較するテストスクリプト
# 使用方法: ./test_comparison.sh

BASE_URL="http://localhost:8080"
COMPARISON_URL="$BASE_URL/comparison"
API_URL="$BASE_URL/api"

echo "=== トークンバケット実装比較テスト ==="
echo ""

# ヘルスチェック
echo "1. ヘルスチェック"
curl -s "$API_URL/health"
echo ""
echo ""

# 軽量APIの比較
echo "2. 軽量APIの比較（1トークン消費）"
echo "Lua Script vs Bucket4j:"
curl -s "$COMPARISON_URL/light" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/light"
echo ""
echo ""

# 中程度APIの比較
echo "3. 中程度APIの比較（3トークン消費）"
echo "Lua Script vs Bucket4j:"
curl -s "$COMPARISON_URL/medium" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/medium"
echo ""
echo ""

# 重量APIの比較
echo "4. 重量APIの比較（5トークン消費）"
echo "Lua Script vs Bucket4j:"
curl -s "$COMPARISON_URL/heavy" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/heavy"
echo ""
echo ""

# ユーザー固有APIの比較
echo "5. ユーザー固有APIの比較（2トークン消費）"
echo "User1 - Lua Script vs Bucket4j:"
curl -s "$COMPARISON_URL/user/user1" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/user/user1"
echo ""
echo ""

# 非同期APIの比較
echo "6. 非同期APIの比較（1トークン消費）"
echo "Lua Script vs Bucket4j:"
curl -s "$COMPARISON_URL/async" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/async"
echo ""
echo ""

# バケット状態の比較
echo "7. バケット状態の比較"
echo "軽量APIバケット:"
curl -s "$COMPARISON_URL/bucket/external_api_light/status" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/bucket/external_api_light/status"
echo ""
echo ""

# パフォーマンスベンチマーク
echo "8. パフォーマンスベンチマーク"
echo "10回の連続実行による比較:"
curl -s "$COMPARISON_URL/benchmark" | jq '.' 2>/dev/null || curl -s "$COMPARISON_URL/benchmark"
echo ""
echo ""

# 個別の実装テスト
echo "9. 個別実装のテスト"
echo "Lua Script版 - 軽量API:"
curl -s "$API_URL/light"
echo ""
echo ""

echo "Bucket4j版 - 軽量API:"
curl -s "$API_URL/bucket4j/light"
echo ""
echo ""

# レート制限のテスト
echo "10. レート制限のテスト"
echo "Lua Script版 - 連続10回呼び出し:"
for i in {1..10}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/light")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    if [ "$http_status" = "200" ]; then
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status)"
    fi
done
echo ""

echo "Bucket4j版 - 連続10回呼び出し:"
for i in {1..10}; do
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$API_URL/bucket4j/light")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    if [ "$http_status" = "200" ]; then
        echo "  リクエスト $i: ✓ 成功"
    else
        echo "  リクエスト $i: ✗ 失敗 (HTTP $http_status)"
    fi
done
echo ""

echo "=== 比較テスト完了 ==="
echo ""
echo "結果の見方:"
echo "- executionTime: 実行時間（短い方が高速）"
echo "- faster: より高速な実装"
echo "- timeDifference: 実行時間の差"
echo "- winner: ベンチマークの勝者" 