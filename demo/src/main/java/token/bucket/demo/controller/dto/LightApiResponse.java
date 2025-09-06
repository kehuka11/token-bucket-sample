package token.bucket.demo.controller.dto;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class LightApiResponse {
    private final String status;
    private final String message;
}
