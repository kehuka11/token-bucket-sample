package token.bucket.demo.service.command;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class ExternalApiResponse {
    private final String status;
    private final String message;
}
