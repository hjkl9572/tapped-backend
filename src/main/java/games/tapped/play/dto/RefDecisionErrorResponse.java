package games.tapped.play.dto;

import java.util.UUID;

public record RefDecisionErrorResponse(
        boolean ok,
        String code,
        String redirectTo,
        UUID activityInstanceId
) {
}
