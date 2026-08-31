package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

public record PlayInstanceTemplateSummary(
        UUID id,
        String title,
        String rules,

        @JsonProperty("photo_path")
        String photoPath
) {
}
