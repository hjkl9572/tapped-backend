package games.tapped.play.dto;

import games.tapped.play.entity.ActivityTapState;

import java.time.OffsetDateTime;
import java.util.UUID;

public record TapSummary(
        UUID id,
        ActivityTapState state,
        int sequenceNo,
        OffsetDateTime firstHappenedAt,
        OffsetDateTime finalizedAt,
        OffsetDateTime canceledAt
) {
}
