package games.tapped.play.repository;

import java.time.Instant;
import java.util.UUID;

public interface ShowcaseTemplateRow {

    UUID getId();

    UUID getOriginId();

    String getTitle();

    String getRules();

    String getPhotoPath();

    String getCreatorDisplayName();

    Instant getPublishedAt();
}
