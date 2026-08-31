package games.tapped.play.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record TapCardLeaderboardEntry(
        long rank,
        double score,
        UUID cardId,
        UUID tapId,
        UUID activityInstanceId,
        UUID activityTemplateId,
        UUID ownerUserId,
        String ownerHandle,
        String ownerNickname,
        String ownerAvatarUrl,
        String instanceTitle,
        String templateTitle,
        LeaderboardResult result,
        String note,
        String photoPath,
        long likeCount,
        long replyCount,
        int failCardFeeMinor,
        OffsetDateTime cardCreatedAt,
        OffsetDateTime cardUpdatedAt,
        OffsetDateTime completedAt,
        OffsetDateTime rankSortAt
) {
}
