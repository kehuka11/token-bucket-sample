package token.bucket.demo.config;

import io.github.bucket4j.Bucket;
import io.github.bucket4j.BucketConfiguration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


import java.time.Duration;

@Configuration
public class Bucket4jConfig {
    @Value("${rate-limit.endpoints.light-api.capacity}")
    private long LIGHT_API_CAPACITY;
    @Value("${rate-limit.endpoints.light-api.refill-rate}")
    private long LIGHT_API_REFILL_RATE;
    @Value("${rate-limit.endpoints.light-api.refill-interval}")
    private long LIGHT_API_REFILL_INTERVAL;
    
    /**
     * 基本的なトークンバケット設定
     */
    @Bean
    public BucketConfiguration lightApiBucketConfiguration() {
        return BucketConfiguration.builder()
                .addLimit(limit ->
                limit.capacity(LIGHT_API_CAPACITY)
                        .refillGreedy(LIGHT_API_REFILL_RATE, Duration.ofSeconds(LIGHT_API_REFILL_INTERVAL))
                )
                .build();

    }
} 