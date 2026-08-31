package games.tapped.play.dto;

import games.tapped.play.entity.ActivityTapState;

import java.time.OffsetDateTime;
import java.util.UUID;

public record TapDetail(
        UUID id,
        UUID activityInstanceId,
        int sequenceNo,
        OffsetDateTime firstHappenedAt,
        OffsetDateTime finalizedAt,
        OffsetDateTime canceledAt,
        ActivityTapState state,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
}
