package games.tapped.play.repository;

import java.time.Instant;
import java.util.UUID;

public interface TapCardTrayRow {

    UUID getId();

    UUID getActivityInstanceId();

    UUID getTapId();

    String getNote();

    String getPhotoPath();

    Instant getCreatedAt();

    UUID getTemplateId();

    String getTemplateTitle();

    String getTemplateRules();

    String getTemplatePhotoPath();

    Long getLikeCount();

    Long getReplyCount();
}
