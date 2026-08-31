package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.TemplateLifecycleState;

import java.util.UUID;

public record TemplateMutationResponse(
        boolean ok,

        @JsonProperty("template_id")
        UUID templateId,

        @JsonProperty("photo_path")
        String photoPath,

        @JsonProperty("lifecycle_state")
        TemplateLifecycleState lifecycleState
) {
    public static TemplateMutationResponse saved(
            UUID templateId,
            String photoPath,
            TemplateLifecycleState lifecycleState
    ) {
        return new TemplateMutationResponse(
                true,
                templateId,
                photoPath,
                lifecycleState
        );
    }
}
