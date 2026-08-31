package games.tapped.play.dto;

import java.util.List;

public record TemplateCatalogResponse(
        List<TemplatePresetResponse> presets
) {
}
