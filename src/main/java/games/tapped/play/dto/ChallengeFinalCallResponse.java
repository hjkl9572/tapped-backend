package games.tapped.play.dto;

import java.util.Map;
import java.util.UUID;

public record ChallengeFinalCallResponse(
        boolean ok,
        Map<String, Object> data,
        UUID coverCardId,
        ChallengerDecisionType terminalAction
) {
}
