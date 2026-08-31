package games.tapped.play.dto;

import java.util.UUID;

public record TapCardLikeResponse(
        UUID cardId,
        long likeCount,
        boolean liked
) {
}
