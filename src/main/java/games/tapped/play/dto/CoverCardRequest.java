package games.tapped.play.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CoverCardRequest(
        @NotNull
        UUID coverCardId
) {
}
