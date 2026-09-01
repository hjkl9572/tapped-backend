package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.ActivityModeKind;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;

import java.time.OffsetDateTime;
import java.util.UUID;

public record InstanceDashboardItem(
        UUID id,
        ActivityModeKind modeKind,
        String title,
        String rules,

        @JsonProperty("photo_path")
        String photoPath,

        TemplatePlayContext playContext,
        TemplateRelationshipMode relationshipMode,
        String proofKind,
        OffsetDateTime startedAt,
        OffsetDateTime updatedAt,
        TapSummary latestTap
) {
}
