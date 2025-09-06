#!/bin/bash

# レート制限のテスト用スクリプト
# 使用方法: ./test_rate_limit.sh

BASE_URL="http://localhost:8080/api"
BUCKET_KEY="test_bucket"

echo "=== トークンバケットレート制限テスト ==="
echo ""

# ヘルスチェック
echo "1. ヘルスチェック"
curl -s "$BASE_URL/health"
echo ""
echo ""

# 軽量APIのテスト（1トークン消費）
echo "2. 軽量APIのテスト（1トークン消費）"
for i in {1..15}; do
    echo "リクエスト $i:"
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$BASE_URL/light")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        echo "  ✓ 成功: $body"
    else
        echo "  ✗ 失敗 (HTTP $http_status): $body"
    fi
    
    sleep 0.1
done
echo ""

# 中程度APIのテスト（3トークン消費）
echo "3. 中程度APIのテスト（3トークン消費）"
for i in {1..5}; do
    echo "リクエスト $i:"
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$BASE_URL/medium")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        echo "  ✓ 成功: $body"
    else
        echo "  ✗ 失敗 (HTTP $http_status): $body"
    fi
    
    sleep 0.2
done
echo ""

# 重量APIのテスト（5トークン消費）
echo "4. 重量APIのテスト（5トークン消費）"
for i in {1..3}; do
    echo "リクエスト $i:"
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$BASE_URL/heavy")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        echo "  ✓ 成功: $body"
    else
        echo "  ✗ 失敗 (HTTP $http_status): $body"
    fi
    
    sleep 0.5
done
echo ""

# バケットの状態確認
echo "5. バケットの状態確認"
echo "軽量APIバケット:"
curl -s "$BASE_URL/bucket/external_api_light/status" | jq '.' 2>/dev/null || curl -s "$BASE_URL/bucket/external_api_light/status"
echo ""

echo "中程度APIバケット:"
curl -s "$BASE_URL/bucket/external_api_medium/status" | jq '.' 2>/dev/null || curl -s "$BASE_URL/bucket/external_api_medium/status"
echo ""

echo "重量APIバケット:"
curl -s "$BASE_URL/bucket/external_api_heavy/status" | jq '.' 2>/dev/null || curl -s "$BASE_URL/bucket/external_api_heavy/status"
echo ""

# ユーザー固有APIのテスト
echo "6. ユーザー固有APIのテスト"
for user_id in "user1" "user2" "user1" "user2" "user1"; do
    echo "ユーザー $user_id のリクエスト:"
    response=$(curl -s -w "HTTP_STATUS:%{http_code}" "$BASE_URL/user/$user_id")
    http_status=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
    body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    if [ "$http_status" = "200" ]; then
        echo "  ✓ 成功: $body"
    else
        echo "  ✗ 失敗 (HTTP $http_status): $body"
    fi
    
    sleep 0.1
done
echo ""

echo "=== テスト完了 ===" 