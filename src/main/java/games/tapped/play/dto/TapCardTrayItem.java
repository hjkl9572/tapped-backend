package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.OffsetDateTime;
import java.util.UUID;

public record TapCardTrayItem(
        UUID id,
        UUID activityInstanceId,
        UUID tapId,
        String note,

        @JsonProperty("photo_path")
        String photoPath,

        OffsetDateTime createdAt,
        PlayInstanceTemplateSummary template,
        long likeCount,
        long replyCount
) {
}
