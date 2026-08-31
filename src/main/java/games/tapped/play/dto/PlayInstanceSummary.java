package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

public record PlayInstanceSummary(
        UUID id,
        String title,
        String refEmail,
        UUID refUserId,
        int amountMinor,

        @JsonProperty("photo_path")
        String photoPath,

        PlayInstanceTemplateSummary template,
        String currency,
        String rules,
        OffsetDateTime startAt,
        OffsetDateTime endAt,
        OffsetDateTime deadlineAt,
        ChallengeProcessStatus status,
        Map<String, Object> formData,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt,
        TapSummary latestTap,
        String firstTapCardPhotoPath
) {
}
