# ビルドステージ
FROM eclipse-temurin:21-jdk-alpine AS build

# 作業ディレクトリを設定
WORKDIR /app

# Gradleラッパーをコピー
COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

# 依存関係をダウンロード
RUN chmod +x ./gradlew && \
    ./gradlew dependencies --no-daemon

# ソースコードをコピー
COPY src src

# アプリケーションをビルド
RUN ./gradlew build -x test --no-daemon

# 実行ステージ
FROM eclipse-temurin:21-jre-alpine

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# 作業ディレクトリを設定
WORKDIR /app

# ビルドされたJARファイルをコピー
COPY --from=build /app/build/libs/*.jar app.jar

# ポート8080を公開
EXPOSE 8080

# ヘルスチェックを追加
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# アプリケーションを起動
ENTRYPOINT ["java", "-jar", "app.jar"] 