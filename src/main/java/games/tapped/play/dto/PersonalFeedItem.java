package games.tapped.play.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record PersonalFeedItem(
        UUID cardId,
        UUID activityInstanceId,
        UUID activityTemplateId,
        String instanceTitle,
        String note,
        String photoPath,
        int amountMinor,
        String currency,
        ChallengeProcessStatus status,
        String result,
        long likeCount,
        long replyCount,
        OffsetDateTime updatedAt
) {
}
