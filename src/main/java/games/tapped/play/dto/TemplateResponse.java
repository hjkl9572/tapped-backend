package games.tapped.play.dto;

import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;

import java.util.UUID;

public record TemplateResponse(
        UUID id,
        String title,
        String rules,
        TemplateLifecycleState lifecycleState,
        TemplateVisibility visibility,
        UUID createdBy
) {
    public static TemplateResponse from(ActivityTemplate template) {
        return new TemplateResponse(
                template.getId(),
                template.getTitle(),
                template.getRules(),
                template.getLifecycleState(),
                template.getVisibility(),
                template.getCreatedBy()
        );
    }
}