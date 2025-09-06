package token.bucket.demo.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Data
@Component
@ConfigurationProperties(prefix = "rate-limit")
public class RateLimitConfig {
    
    private DelayedRefillConfig delayedRefill = new DelayedRefillConfig();
    private Map<String, EndpointConfig> endpoints = new HashMap<>();
    
    @Data
    public static class DelayedRefillConfig {
        private boolean enabled = true;
        private int checkInterval = 100; // ミリ秒
        private int maxBatchSize = 100;
        private boolean backgroundProcessing = true;
    }
    
    @Data
    public static class EndpointConfig {
        private String bucketKey;
        private int capacity;
        private int refillRate;
        private int refillInterval;
        private String refillTimeUnit = "SECONDS";
        private boolean delayedRefill = true;
        private int maxConcurrentRequests = 10;
        private int timeout = 30; // 秒
    }
} 