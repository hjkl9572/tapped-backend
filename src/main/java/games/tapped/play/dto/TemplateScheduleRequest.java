package games.tapped.play.dto;

import java.time.OffsetDateTime;

public record TemplateScheduleRequest(
        OffsetDateTime startAt,
        OffsetDateTime endAt
) {
}
