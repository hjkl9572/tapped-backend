package games.tapped.play.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RefDecisionRequest(
        @NotBlank
        String token,

        @NotNull
        RefDecisionVerdict verdict
) {
}
