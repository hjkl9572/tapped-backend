package games.tapped.play.dto;

import jakarta.validation.Valid;

import java.util.Map;

public record TemplateModesRequest(
        @Valid
        TemplateChallengeModeRequest challenge,

        Map<String, Object> additional
) {
}
