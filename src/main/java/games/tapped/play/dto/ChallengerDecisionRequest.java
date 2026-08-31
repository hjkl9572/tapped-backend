package games.tapped.play.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ChallengerDecisionRequest(
        @NotNull
        ChallengerDecisionType decision,

        @Size(max = 80)
        String reasonCode,

        @Size(max = 2000)
        String details
) {
}
