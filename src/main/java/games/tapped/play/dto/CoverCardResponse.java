package games.tapped.play.dto;

import java.util.UUID;

public record CoverCardResponse(
        boolean ok,
        UUID playInstanceId,
        UUID coverCardId
) {
}
