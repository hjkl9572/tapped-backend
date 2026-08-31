package games.tapped.play.dto;

import java.util.UUID;

public record RefDecisionSuccessResponse(
        boolean ok,
        UUID activityInstanceId,
        String nextStatus,
        String redirectTo
) {
}
