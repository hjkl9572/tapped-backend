package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.Valid;

@JsonIgnoreProperties(ignoreUnknown = false)
public record TemplateModesRequest(
        @Valid
        TemplateChallengeModeRequest challenge
) {
}
