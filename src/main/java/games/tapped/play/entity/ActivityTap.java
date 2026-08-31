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
import java.util.UUID;

@Entity
@Table(name = "activity_taps")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityTap {

    @Id
    private UUID id;

    @Column(name = "activity_instance_id", nullable = false)
    private UUID activityInstanceId;

    @Column(name = "tapped_by")
    private UUID tappedBy;

    @Column(name = "sequence_no", nullable = false)
    private int sequenceNo;

    @Column(name = "first_happened_at", nullable = false)
    private OffsetDateTime firstHappenedAt;

    @Column(name = "finalized_at")
    private OffsetDateTime finalizedAt;

    @Column(name = "canceled_at")
    private OffsetDateTime canceledAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false)
    private ActivityTapState state;

    public static ActivityTap open(
            UUID activityInstanceId,
            UUID tappedBy,
            int sequenceNo,
            OffsetDateTime now
    ) {
        ActivityTap tap = new ActivityTap();

        tap.id = UUID.randomUUID();
        tap.activityInstanceId = activityInstanceId;
        tap.tappedBy = tappedBy;
        tap.sequenceNo = sequenceNo;
        tap.firstHappenedAt = now;
        tap.finalizedAt = null;
        tap.canceledAt = null;
        tap.createdAt = now;
        tap.updatedAt = now;
        tap.state = ActivityTapState.OPENED;

        return tap;
    }

    public void cancel(OffsetDateTime now) {
        state = ActivityTapState.CANCELED;
        canceledAt = now;
        updatedAt = now;
    }

    public void reopen(OffsetDateTime now) {
        state = ActivityTapState.OPENED;
        canceledAt = null;
        updatedAt = now;
    }

    public void finalizeTap(OffsetDateTime now) {
        if (finalizedAt == null) {
            finalizedAt = now;
        }
        updatedAt = now;
    }
}
