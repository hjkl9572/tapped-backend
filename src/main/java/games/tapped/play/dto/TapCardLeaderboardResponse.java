package games.tapped.play.dto;

import java.util.List;

public record TapCardLeaderboardResponse(
        List<TapCardLeaderboardEntry> entries
) {
}
