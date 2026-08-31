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
@Table(name = "activity_instances")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityInstance {

    @Id
    private UUID id;

    @Column(name = "activity_template_id", nullable = false)
    private UUID activityTemplateId;

    @Column(name = "created_by")
    private UUID createdBy;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false)
    private ActivityInstanceState state;

    @Column(name = "started_at", nullable = false)
    private OffsetDateTime startedAt;

    @Column(name = "completed_at")
    private OffsetDateTime completedAt;

    @Column(name = "terminated_at")
    private OffsetDateTime terminatedAt;

    @Column(name = "first_tap_at")
    private OffsetDateTime firstTapAt;

    @Column(name = "last_tap_at")
    private OffsetDateTime lastTapAt;

    @Column(name = "tap_count", nullable = false)
    private int tapCount;

    @Column(name = "requirements_met")
    private Boolean requirementsMet;

    @Column(name = "termination_reason")
    private String terminationReason;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "play_context", nullable = false)
    private TemplatePlayContext playContext;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "relationship_mode", nullable = false)
    private TemplateRelationshipMode relationshipMode;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @Column(name = "deleted_by")
    private UUID deletedBy;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "mode_kind", nullable = false)
    private ActivityModeKind modeKind;

    @Column(name = "idempotency_key")
    private String idempotencyKey;

    @Column(name = "sequence_no", nullable = false)
    private int sequenceNo;

    @Column(name = "cover_card_id")
    private UUID coverCardId;

    @Column(name = "end_at")
    private OffsetDateTime endAt;

    public static ActivityInstance createChallenge(
            UUID activityTemplateId,
            UUID createdBy,
            TemplatePlayContext playContext,
            TemplateRelationshipMode relationshipMode,
            String idempotencyKey,
            int sequenceNo,
            OffsetDateTime endAt,
            OffsetDateTime now
    ) {
        ActivityInstance instance = new ActivityInstance();

        instance.id = UUID.randomUUID();
        instance.activityTemplateId = activityTemplateId;
        instance.createdBy = createdBy;
        instance.state = ActivityInstanceState.ACTIVE;
        instance.startedAt = now;
        instance.completedAt = null;
        instance.terminatedAt = null;
        instance.firstTapAt = null;
        instance.lastTapAt = null;
        instance.tapCount = 0;
        instance.playContext = playContext;
        instance.relationshipMode = relationshipMode;
        instance.createdAt = now;
        instance.updatedAt = now;
        instance.updatedBy = createdBy;
        instance.deletedAt = null;
        instance.deletedBy = null;
        instance.modeKind = ActivityModeKind.CHALLENGE;
        instance.idempotencyKey = idempotencyKey;
        instance.sequenceNo = sequenceNo;
        instance.coverCardId = null;
        instance.endAt = endAt;

        return instance;
    }

    public boolean isActive() {
        return state == ActivityInstanceState.ACTIVE
                && completedAt == null
                && terminatedAt == null
                && deletedAt == null;
    }

    public void recordTap(OffsetDateTime happenedAt, UUID updatedBy) {
        if (firstTapAt == null) {
            firstTapAt = happenedAt;
        }
        lastTapAt = happenedAt;
        tapCount = tapCount + 1;
        touch(updatedBy, happenedAt);
    }

    public void complete(UUID coverCardId, UUID updatedBy, OffsetDateTime now) {
        state = ActivityInstanceState.COMPLETED;
        completedAt = completedAt == null ? now : completedAt;
        terminatedAt = null;
        if (this.coverCardId == null) {
            this.coverCardId = coverCardId;
        }
        touch(updatedBy, now);
    }

    public void setCoverCard(UUID coverCardId, UUID updatedBy, OffsetDateTime now) {
        this.coverCardId = coverCardId;
        touch(updatedBy, now);
    }

    public void softDelete(UUID deletedBy, OffsetDateTime now) {
        this.deletedAt = now;
        this.deletedBy = deletedBy;
        touch(deletedBy, now);
    }

    private void touch(UUID updatedBy, OffsetDateTime now) {
        this.updatedBy = updatedBy;
        this.updatedAt = now;
    }
}
