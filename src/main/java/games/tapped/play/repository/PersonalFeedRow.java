package games.tapped.play.repository;

import java.time.Instant;
import java.util.UUID;

public interface PersonalFeedRow {

    UUID getCardId();

    UUID getTapId();

    UUID getActivityInstanceId();

    UUID getActivityTemplateId();

    String getInstanceTitle();

    String getTemplateStatus();

    String getNote();

    String getPhotoPath();

    Integer getFailCardFeeMinor();

    String getChallengerFinalVerdict();

    String getInstanceState();

    String getRefVerdict();

    Long getLikeCount();

    Long getReplyCount();

    Instant getSortUpdatedAt();
}
