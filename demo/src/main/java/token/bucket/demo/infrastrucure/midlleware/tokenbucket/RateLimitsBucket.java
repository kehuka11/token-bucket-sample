package token.bucket.demo.infrastrucure.midlleware.tokenbucket;

import io.github.bucket4j.Bucket;
import io.github.bucket4j.BucketConfiguration;
import io.github.bucket4j.redis.lettuce.cas.LettuceBasedProxyManager;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;

@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimitsBucket {
    private final LettuceBasedProxyManager<byte[]> pm;
    private final BucketConfiguration lightApiBucketConfiguration;

    public Bucket lightApi(String tenant) {
        String key = "rate:" + tenant + ":/v1/light-api:POST";
        log.debug("[RateLimitsBucket] バケットキー生成: {}", key);

        Bucket bucket = pm.getProxy(key.getBytes(StandardCharsets.UTF_8), () -> lightApiBucketConfiguration);
        log.debug("[RateLimitsBucket] トークンバケット作成完了 - テナント: {}, キー: {}", tenant, key);
        
        return bucket;
    }
}
