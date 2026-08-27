package games.tapped.play.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateTemplateRequest(
        @NotBlank
        @Size(max = 100)
        String title,

        @Size(max = 2000)
        String rules
) {
}