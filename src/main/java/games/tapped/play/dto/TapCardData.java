package games.tapped.play.dto;

import java.util.UUID;

public record TapCardData(
        UUID id,
        String note,
        String photoPath
) {
}
