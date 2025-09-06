package token.bucket.demo.config;

import io.github.bucket4j.distributed.ExpirationAfterWriteStrategy;
import io.github.bucket4j.redis.lettuce.Bucket4jLettuce;
import io.github.bucket4j.redis.lettuce.cas.LettuceBasedProxyManager;
import io.lettuce.core.CompositeArgument;
import io.lettuce.core.RedisClient;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.codec.ByteArrayCodec;
import io.lettuce.core.codec.StringCodec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.data.redis.RedisProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import io.lettuce.core.RedisURI;
import lombok.extern.slf4j.Slf4j;

import java.time.Duration;


@Slf4j
@Configuration
@EnableConfigurationProperties(RedisProperties.class)
public class Bucket4jRedisConfig {

    @Value("${rate-limit.endpoints.light-api.ttl-seconds:2}")
    private long TTL_SECONDS;

    /** RedisClient Bean */
    @Bean(destroyMethod = "shutdown")
    public RedisClient redisClient(RedisProperties props) {
        RedisURI uri = RedisURI.Builder.redis(props.getHost(), props.getPort())
                .withSsl(props.getSsl().isEnabled())
                .withPassword(props.getPassword() == null ? null : props.getPassword().toCharArray())
                .withTimeout(Duration.ofSeconds(5))
                .build();
        
        RedisClient client = RedisClient.create(uri);
        client.setDefaultTimeout(Duration.ofSeconds(5));
        
        log.info("Redis client created for host: {}:{}", props.getHost(), props.getPort());
        return client;
    }

    /** Bucket 用：String key / byte[] value の Lettuce 接続（RedisTemplateとは別） */
    @Bean(destroyMethod = "close")
    public StatefulRedisConnection<byte[], byte[]> bucket4jRedisConnection(RedisClient redisClient) {
        StatefulRedisConnection<byte[], byte[]> connection = redisClient.connect(new ByteArrayCodec());
        
        log.info("Redis connection established for Bucket4j");
        return connection;
    }

    /** ProxyManager（Bucket4j が分散状態を Redis に保存するための管理オブジェクト） */
    @Bean
    public LettuceBasedProxyManager<byte[]> proxyManager(StatefulRedisConnection<byte[], byte[]> conn) {
        log.info("🔧 [Bucket4jRedisConfig] ProxyManager作成開始 - TTL: {}秒", TTL_SECONDS);
        
        LettuceBasedProxyManager<byte[]> proxyManager = Bucket4jLettuce
                .casBasedBuilder(conn)
                // バケットキーの TTL（放置されたキーを自然消滅させる）
                .expirationAfterWrite(ExpirationAfterWriteStrategy
                        .basedOnTimeForRefillingBucketUpToMax(Duration.ofSeconds(TTL_SECONDS)))
                .build();
        
        log.info("[Bucket4jRedisConfig] ProxyManager作成完了 - Redis接続");
        
        return proxyManager;
    }
}
