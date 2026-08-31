package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record CreateTemplateRequest(
        UUID templateId,

        @NotBlank
        @Size(max = 100)
        String title,

        @Size(max = 4000)
        String rules,

        TemplateVisibility visibility,

        @NotNull
        TemplateLifecycleState lifecycleState,

        @Valid
        TemplateModesRequest modes,

        @Valid
        TemplateScheduleRequest schedule,

        @JsonProperty("photo_path")
        @JsonAlias({"photoPath", "photoUrl"})
        String photoPath
) {
    public CreateTemplateRequest(String title, String rules) {
        this(
                null,
                title,
                rules,
                null,
                TemplateLifecycleState.DRAFT,
                null,
                null,
                null
        );
    }
}
