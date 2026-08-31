package games.tapped.play.dto;

import java.util.UUID;

public record ChallengerDecisionResponse(
        boolean ok,
        boolean finalized,
        UUID playInstanceId
) {
}
