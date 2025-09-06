package token.bucket.demo.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import token.bucket.demo.controller.dto.LightApiResponse;
import token.bucket.demo.service.Bucket4jExternalApiService;
import token.bucket.demo.service.command.ExternalApiResponse;

import java.util.concurrent.CompletableFuture;

@Slf4j
@RestController
@RequestMapping("/api/bucket4j")
@RequiredArgsConstructor
public class Bucket4jApiController {
    private final Bucket4jExternalApiService bucket4jExternalApiService;

    @GetMapping("/light/status")
    public ResponseEntity<LightApiResponse> call() {
        log.info("[Bucket4j] 軽量API呼び出し開始 - エントリーポイント");
        
        try {
            ExternalApiResponse result = bucket4jExternalApiService.lightApiCall();
            
            log.info("[Bucket4j] 軽量API呼び出し成功 - レスポンス: {}", result);
            
            LightApiResponse response = LightApiResponse.builder()
                    .message(result.getMessage())
                    .status(result.getStatus())
                    .build();
            
            log.info("[Bucket4j] レスポンス返却完了");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("[Bucket4j] 軽量API呼び出し失敗", e);
            throw e;
        }
    }
} 