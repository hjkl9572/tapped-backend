package games.tapped.play.dto;

import java.util.UUID;

public record TapCardLikeStatsEntry(
        UUID tapCardId,
        long likeCount,
        boolean likedByMe
) {
}
