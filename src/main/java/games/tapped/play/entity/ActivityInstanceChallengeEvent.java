package games.tapped.play.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "activity_instance_challenge_events")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityInstanceChallengeEvent {

    @Id
    private UUID id;

    @Column(name = "activity_instance_id", nullable = false)
    private UUID activityInstanceId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false)
    private Map<String, Object> payload;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "event_type", nullable = false)
    private ChallengeEventType eventType;

    public static ActivityInstanceChallengeEvent create(
            UUID activityInstanceId,
            ChallengeEventType eventType,
            Map<String, Object> payload,
            OffsetDateTime now
    ) {
        ActivityInstanceChallengeEvent event =
                new ActivityInstanceChallengeEvent();

        event.id = UUID.randomUUID();
        event.activityInstanceId = activityInstanceId;
        event.eventType = eventType;
        event.payload = payload == null ? Map.of() : payload;
        event.createdAt = now;

        return event;
    }
}
