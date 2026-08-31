package games.tapped.play.dto;

import java.util.UUID;

public record TemplatePresetResponse(
        UUID id,
        UUID templateId,
        String title,
        String rules,
        String period,
        String imageSrc,
        String imageAlt
) {
}
