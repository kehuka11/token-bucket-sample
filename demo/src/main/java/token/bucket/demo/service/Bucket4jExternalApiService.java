package token.bucket.demo.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClient;
import token.bucket.demo.service.command.ExternalApiResponse;

import java.net.URI;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class Bucket4jExternalApiService {
    
    private final RestClient restClient;

    public ExternalApiResponse lightApiCall() {
        log.info("[Bucket4j] 外部API呼び出し開始 - Prism Light API");
        
        try {
            log.debug("[Bucket4j] HTTPリクエスト送信: http://prism-light:4010/api/light/status");
            
            ExternalApiResponse result = restClient.get()
                    .uri(URI.create("http://prism-light:4010/api/light/status?force_error=429"))
//                    .header("Prefer", "dynamic=true", "code=429", "example=forced_rate_limit")
                    .exchange(
                            (request, response) -> {
                                log.debug("[Bucket4j] HTTPレスポンス受信 - ステータス: {}", response.getStatusCode());
                                
                                var errorHandler = new DefaultResponseErrorHandler();
                                if (errorHandler.hasError(response)) {
                                    log.warn("[Bucket4j] HTTPエラーレスポンス検出");
                                    errorHandler.hasError(response);
                                }
                                
                                ExternalApiResponse apiResponse = response.bodyTo(ExternalApiResponse.class);
                                log.debug("[Bucket4j] レスポンスボディ解析完了: {}", apiResponse);
                                return apiResponse;
                            });

            log.info("[Bucket4j] 外部API呼び出し成功 - 結果: {}", result);
            return result;

        } catch (HttpStatusCodeException e) {
            log.error("[Bucket4j] HTTPステータスエラー - ステータス: {}, レスポンス: {}",
                     e.getStatusCode(), e.getResponseBodyAsString());
            throw new RuntimeException("http failed", e);
        } catch (Exception e) {
            log.error("[Bucket4j] 外部API呼び出しで予期しないエラー", e);
            throw new RuntimeException("Unexpected error during API call", e);
        }
    }
} 