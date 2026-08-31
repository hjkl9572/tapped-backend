package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.ActivityTapState;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ToggleTapData(
        String action,

        @JsonProperty("tap_id")
        UUID tapId,

        @JsonProperty("activity_instance_id")
        UUID activityInstanceId,

        @JsonProperty("sequence_no")
        int sequenceNo,

        ActivityTapState state,

        @JsonProperty("finalized_at")
        OffsetDateTime finalizedAt
) {
}
