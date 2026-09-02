package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;

public record PatchTemplateRequest(
        @Size(max = 100)
        String title,

        @Size(max = 4000)
        String rules,

        TemplateVisibility visibility,

        TemplateLifecycleState lifecycleState,

        @Valid
        TemplateModesRequest modes,

        @JsonProperty("photo_path")
        @JsonAlias({"photoPath", "photoUrl"})
        String photoPath
) {
}
