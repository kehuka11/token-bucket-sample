package token.bucket.demo.infrastrucure.midlleware.tokenbucket;

import io.github.bucket4j.Bucket;
import io.netty.util.internal.ThreadLocalRandom;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpRequest;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimitInterceptor implements ClientHttpRequestInterceptor {
    private final RateLimitsBucket buckets;

    private static final long JITTER_CAP_MS = 1000;

    @Override
    public ClientHttpResponse intercept(HttpRequest req, byte[] body, ClientHttpRequestExecution exec) throws IOException {
        log.info("[RateLimit] レート制限チェック開始 - URI: {}, Method: {}", req.getURI(), req.getMethod());
        
        Bucket bucket = buckets.lightApi("m123");
        log.debug("[RateLimit] トークンバケット取得完了 - テナント: m123");
        
        for (int attempt = 0; attempt < 8; attempt++) {
            log.debug("[RateLimit] トークン消費試行 {}回目", attempt + 1);
            
            var probe = bucket.tryConsumeAndReturnRemaining(1);   // 同期でトークン消費
            log.debug("[RateLimit] トークン消費結果 - 消費成功: {}, 残りトークン: {}, 待機時間: {}ms",
                    probe.isConsumed(), probe.getRemainingTokens(),
                     TimeUnit.NANOSECONDS.toMillis(probe.getNanosToWaitForRefill()));

            if (!probe.isConsumed()) {
                long waitMs = TimeUnit.NANOSECONDS.toMillis(probe.getNanosToWaitForRefill());
                sleepFullJitter(waitMs, JITTER_CAP_MS);
                continue;
            }

            log.info("[RateLimit] トークン消費成功 - 外部API呼び出し実行");
            ClientHttpResponse resp = exec.execute(req, body);

            // ③ 相手のレート制限/過負荷なら待って再試行
            HttpStatusCode code = resp.getStatusCode();
            if (code == HttpStatusCode.valueOf(429) || code == HttpStatusCode.valueOf(503) || code == HttpStatusCode.valueOf(408)) {
                long waitMs = pickRetryAfterMillis(resp);
                if (waitMs <= 0) {
                    // `Retry-After` が無ければフルジッター＋指数(静的指数フルジッター)
                    waitMs = (long) Math.min(JITTER_CAP_MS, 100 * Math.pow(2, attempt));
                }
                log.debug("[RateLimit] waitMs: {}", waitMs);

                resp.close(); // 重要：再試行前に接続を返す

                try {
                    Thread.sleep(waitMs);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                continue; // 再試行
            }

            // それ以外はそのまま返す
            return resp;
        }
        
        log.error("[RateLimit] レート制限超過 - 最大試行回数に達しました");
        throw new IOException("rate limited");
    }

    // 動的フルジッター
    // 最短で回復、スループット最大化
    private static void sleepFullJitter(long suggestedMs, long capMs) {
        log.debug("[RateLimit] FullJitter処理");
        long upper = Math.max(1, Math.min(suggestedMs, capMs));
        long sleep = ThreadLocalRandom.current().nextLong(0, upper);
        try { Thread.sleep(sleep); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }

    /** Retry-After: 秒 or HTTP-date(RFC1123) をmsに変換。無ければ0 */
    private static long pickRetryAfterMillis(ClientHttpResponse resp) {
        log.debug("[RateLimit] Retry-Afterに基づく処理");
        var h = resp.getHeaders();
        // Retry-After: 数値
        // Retry-After: Wed, 21 Oct 2015 07:28:00 GMT
        // 両方の形式に対応
        if (h.containsKey("Retry-After")) {
            String v = h.getFirst("Retry-After");
            try {
                // 数値秒
                return Long.parseLong(v) * 1000L;
            } catch (NumberFormatException ignore) {
                try {
                    // HTTP-date
                    var dt = java.time.ZonedDateTime.parse(v, java.time.format.DateTimeFormatter.RFC_1123_DATE_TIME);
                    long delta = java.time.Duration.between(java.time.ZonedDateTime.now(java.time.ZoneOffset.UTC), dt).toMillis();
                    return Math.max(0, delta);
                } catch (Exception ignored) {}
            }
        }
        // 互換ヘッダ（任意）：X-RateLimit-Reset(-After)
        if (h.containsKey("X-RateLimit-Reset-After")) {
            try { return (long)(Double.parseDouble(h.getFirst("X-RateLimit-Reset-After")) * 1000); }
            catch (Exception ignored) {}
        }
        if (h.containsKey("X-RateLimit-Reset")) {
            try {
                long epoch = Long.parseLong(h.getFirst("X-RateLimit-Reset"));
                long now = java.time.Instant.now().getEpochSecond();
                return Math.max(0, (epoch - now) * 1000L);
            } catch (Exception ignored) {}
        }
        return 0;
    }


    @Bean
    RestClient restClient(RestClient.Builder b, RateLimitInterceptor limiter) {
        return b.requestInterceptor(limiter).build();
    }
}
