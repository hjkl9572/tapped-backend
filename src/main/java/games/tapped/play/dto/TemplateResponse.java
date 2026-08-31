package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.ActivityModeKind;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;

import java.time.OffsetDateTime;
import java.util.UUID;

public record TemplateResponse(
        UUID id,
        String title,
        String rules,
        TemplateLifecycleState lifecycleState,
        TemplateVisibility visibility,
        UUID createdBy,

        @JsonProperty("photo_path")
        String photoPath,

        ActivityModeKind modeKind,
        TemplatePlayContext playContext,
        TemplateRelationshipMode relationshipMode,
        OffsetDateTime publishedAt
) {
    public static TemplateResponse from(ActivityTemplate template) {
        return new TemplateResponse(
                template.getId(),
                template.getTitle(),
                template.getRules(),
                template.getLifecycleState(),
                template.getVisibility(),
                template.getCreatedBy(),
                template.getPhotoPath(),
                template.getModeKind(),
                template.getPlayContext(),
                template.getRelationshipMode(),
                template.getPublishedAt()
        );
    }
}
