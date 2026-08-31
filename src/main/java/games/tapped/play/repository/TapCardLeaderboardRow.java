package games.tapped.play.repository;

import java.time.Instant;
import java.util.UUID;

public interface TapCardLeaderboardRow {

    Long getRank();

    Double getScore();

    UUID getCardId();

    UUID getTapId();

    UUID getActivityInstanceId();

    UUID getActivityTemplateId();

    UUID getOwnerUserId();

    String getOwnerHandle();

    String getOwnerNickname();

    String getOwnerAvatarUrl();

    String getInstanceTitle();

    String getTemplateTitle();

    String getResult();

    String getNote();

    String getPhotoPath();

    Long getLikeCount();

    Long getReplyCount();

    Integer getFailCardFeeMinor();

    Instant getCardCreatedAt();

    Instant getCardUpdatedAt();

    Instant getCompletedAt();

    Instant getRankSortAt();
}
