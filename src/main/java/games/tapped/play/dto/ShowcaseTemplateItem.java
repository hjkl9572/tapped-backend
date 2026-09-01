package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ShowcaseTemplateItem(
        UUID id,

        @JsonProperty("origin_id")
        UUID originId,

        String title,

        String rules,

        @JsonProperty("photo_path")
        String photoPath,

        @JsonProperty("creator_display_name")
        String creatorDisplayName,

        @JsonProperty("published_at")
        OffsetDateTime publishedAt
) {
}
