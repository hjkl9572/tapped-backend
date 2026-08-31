package games.tapped.play.dto;

import java.util.Map;

public record RefDecisionSessionResponse(
        boolean ok,
        Map<String, Object> projection
) {
}
