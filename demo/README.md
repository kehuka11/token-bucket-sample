# トークンバケットレート制限デモ

Redisを使用して外部APIリクエストをトークンバケットでレート制限するSpring Bootアプリケーションです。
**Luaスクリプト**と**Bucket4j**の両方の実装を提供し、パフォーマンスと機能性を比較できます。

## 🚀 機能

- **2つの実装方式**:
  - **Luaスクリプト**: 軽量で高速、Redis特化
  - **Bucket4j**: 成熟したライブラリ、豊富な機能
- **トークンバケットアルゴリズム**: 固定レートでトークンを補充するレート制限方式
- **Redis統合**: 分散環境でのレート制限状態の共有
- **AOPベース**: アノテーションで簡単にレート制限を適用
- **柔軟な設定**: バケットごとに異なる制限を設定可能
- **ユーザー分離**: ユーザーIDごとにバケットを分離
- **パフォーマンス比較**: 両実装の実行時間と機能性を比較

## 🏗️ アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controller    │───▶│  RateLimit      │───▶│  TokenBucket    │
│                 │    │  Aspect         │    │  Service        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   Annotation    │    │      Redis      │
                       │   @RateLimit    │    │                 │
                       └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controller    │───▶│  Bucket4j       │───▶│  ProxyManager   │
│   (Bucket4j)    │    │  Service        │    │  (Redis/Local)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📊 実装比較

| 項目 | Luaスクリプト | Bucket4j |
|------|----------------|-----------|
| **開発速度** | 高速 | 中程度 |
| **実行性能** | 最高 | 高 |
| **保守性** | 中程度 | 最高 |
| **機能性** | 中程度 | 最高 |
| **学習コスト** | 中程度 | 低 |
| **分散対応** | 基本 | 充実 |
| **バックエンド** | Redis特化 | 多様 |

## ⚙️ 設定

### application.yml

```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      timeout: 2000ms

token-bucket:
  capacity: 10          # バケットの容量
  refill-rate: 1        # リフィルレート
  refill-time: 1        # リフィル時間
  refill-time-unit: SECONDS  # リフィル時間の単位
```

## 🎯 使用方法

## 🐳 Dockerでの実行

### 前提条件
- Docker
- Docker Compose
- Make（オプション）

### クイックスタート

```bash
# 全サービスを起動（Redis、モックAPI、アプリケーション）
make up

# または、Docker Composeを直接使用
docker-compose up -d
```

### 利用可能なコマンド

```bash
# ヘルプ表示
make help

# Dockerイメージをビルド
make build

# アプリケーションのみ起動
make up-app

# 全サービス起動
make up

# 全サービス停止
make down

# ログ表示
make logs

# ステータス確認
make status

# ヘルスチェック
make health

# クリーンアップ
make clean
```

### アクセス可能なサービス

- **アプリケーション**: http://localhost:8080
- **Redis Commander**: http://localhost:8081 (admin/admin123)
- **RedisInsight**: http://localhost:8001
- **軽量API**: http://localhost:8082
- **HTTPBin**: http://localhost:8086

### 開発モード

```bash
# ログ付きで起動（開発用）
make dev
```

## 🎯 使用方法

### 1. Luaスクリプト版

```java
@RateLimit(bucketKey = "api_endpoint", tokens = 1)
public String callApi() {
    return "API response";
}
```

### 2. Bucket4j版

```java
// 自動的にレート制限が適用される
public String callApi() {
    if (!rateLimitService.tryConsumeRedis("api_endpoint", 1)) {
        throw new RuntimeException("Rate limit exceeded");
    }
    return "API response";
}
```

## 🌐 API エンドポイント

### Luaスクリプト版

- `GET /api/light` - 軽量API（1トークン消費）
- `GET /api/medium` - 中程度API（3トークン消費）
- `GET /api/heavy` - 重量API（5トークン消費）
- `GET /api/user/{userId}` - ユーザー固有API（2トークン消費）
- `GET /api/async` - 非同期API（1トークン消費）

### Bucket4j版

- `GET /api/bucket4j/light` - 軽量API（1トークン消費）
- `GET /api/bucket4j/medium` - 中程度API（3トークン消費）
- `GET /api/bucket4j/heavy` - 重量API（5トークン消費）
- `GET /api/bucket4j/user/{userId}` - ユーザー固有API（2トークン消費）
- `GET /api/bucket4j/async` - 非同期API（1トークン消費）
- `GET /api/bucket4j/local` - ローカルキャッシュ版（1トークン消費）

### 比較・ベンチマーク

- `GET /comparison/light` - 軽量APIの比較
- `GET /comparison/medium` - 中程度APIの比較
- `GET /comparison/heavy` - 重量APIの比較
- `GET /comparison/user/{userId}` - ユーザー固有APIの比較
- `GET /comparison/async` - 非同期APIの比較
- `GET /comparison/benchmark` - パフォーマンスベンチマーク

### バケット管理

- `GET /api/bucket/{bucketKey}/status` - バケットの状態確認
- `POST /api/bucket/{bucketKey}/reset` - バケットのリセット
- `GET /api/health` - ヘルスチェック

## 🚀 セットアップ

### 前提条件

- Java 21
- Redis 6.0+
- Gradle 8.0+

### 1. Redisの起動

```bash
# Dockerを使用する場合
docker run -d -p 6379:6379 redis:7-alpine

# または、ローカルでRedisを起動
redis-server
```

### 2. アプリケーションの起動

```bash
./gradlew bootRun
```

### 3. テストの実行

```bash
# テストスクリプトに実行権限を付与
chmod +x test_rate_limit.sh
chmod +x test_comparison.sh

# Luaスクリプト版のテスト
./test_rate_limit.sh

# 両方の実装の比較テスト
./test_comparison.sh
```

## 📈 パフォーマンステスト

### 個別テスト

```bash
# Luaスクリプト版
curl http://localhost:8080/api/light

# Bucket4j版
curl http://localhost:8080/api/bucket4j/light
```

### 比較テスト

```bash
# 軽量APIの比較
curl http://localhost:8080/comparison/light

# パフォーマンスベンチマーク
curl http://localhost:8080/comparison/benchmark
```

## 🔧 カスタマイズ

### Luaスクリプト版のカスタマイズ

```java
@RateLimit(bucketKey = "custom_api", tokens = 3, 
           errorMessage = "Custom rate limit exceeded")
public String customApi() {
    return "Custom API response";
}
```

### Bucket4j版のカスタマイズ

```java
@Bean
public BucketConfiguration customBucketConfiguration() {
    return BucketConfiguration.builder()
        .addLimit(Bandwidth.classic(20, Refill.intervally(5, Duration.ofSeconds(1))))
        .build();
}
```

## 📊 監視とログ

- レート制限の適用状況はログに記録
- バケットの状態はAPIで確認可能
- Redisでトークン消費履歴を追跡
- 両実装のパフォーマンス比較

## 🎯 使い分けの指針

### Luaスクリプトを選ぶべき場合

- **シンプルなレート制限のみ必要**
- **Redisのみを使用**
- **軽量な実装を重視**
- **カスタマイズの自由度を重視**
- **学習目的やプロトタイプ**

### Bucket4jを選ぶべき場合

- **本格的なプロダクション環境**
- **複数のバックエンドでの分散運用**
- **豊富な監視・診断機能が必要**
- **チーム開発での保守性重視**
- **Spring Bootエコシステムでの統合**

## 🐛 トラブルシューティング

### よくある問題

1. **Redis接続エラー**: Redisサーバーが起動しているか確認
2. **レート制限が効かない**: AOPが有効になっているか確認
3. **Bucket4jの依存関係エラー**: バージョンの互換性を確認

### ログの確認

```bash
# アプリケーションログの確認
tail -f logs/application.log

# Redisログの確認
tail -f /var/log/redis/redis-server.log
```

## 📚 参考資料

- [Bucket4j公式リポジトリ](https://github.com/bucket4j/bucket4j)
- [Bucket4j公式ドキュメント](https://bucket4j.github.io/)
- [Spring Boot Redis統合](https://spring.io/projects/spring-data-redis)

## �� ライセンス

MIT License 