package games.tapped.play.dto;

import java.util.List;

public record TapCardLikeStatsResponse(
        List<TapCardLikeStatsEntry> items
) {
}
