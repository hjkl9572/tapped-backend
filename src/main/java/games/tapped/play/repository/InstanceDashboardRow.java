package games.tapped.play.repository;

import java.time.Instant;
import java.util.UUID;

public interface InstanceDashboardRow {

    UUID getId();

    String getModeKind();

    String getTitle();

    String getRules();

    String getPhotoPath();

    String getPlayContext();

    String getRelationshipMode();

    String getProofKind();

    Instant getStartedAt();

    Instant getUpdatedAt();

    UUID getLatestTapId();

    String getLatestTapState();

    Integer getLatestTapSequenceNo();

    Instant getLatestTapFirstHappenedAt();

    Instant getLatestTapFinalizedAt();

    Instant getLatestTapCanceledAt();
}
