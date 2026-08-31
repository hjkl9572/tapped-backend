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
@Table(name = "activity_instance_challenge_disputes")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityInstanceChallengeDispute {

    @Id
    private UUID id;

    @Column(name = "activity_instance_id", nullable = false)
    private UUID activityInstanceId;

    @Column(name = "submitted_by")
    private UUID submittedBy;

    @Column(name = "submitted_at", nullable = false)
    private OffsetDateTime submittedAt;

    @Column(name = "reason_code", nullable = false)
    private String reasonCode;

    private String details;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "ref_verdict")
    private ActivityRefVerdict refVerdict;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public static ActivityInstanceChallengeDispute create(
            UUID activityInstanceId,
            UUID submittedBy,
            String reasonCode,
            String details,
            ActivityRefVerdict refVerdict,
            OffsetDateTime now
    ) {
        ActivityInstanceChallengeDispute dispute =
                new ActivityInstanceChallengeDispute();

        dispute.id = UUID.randomUUID();
        dispute.activityInstanceId = activityInstanceId;
        dispute.submittedBy = submittedBy;
        dispute.submittedAt = now;
        dispute.reasonCode = reasonCode;
        dispute.details = details;
        dispute.refVerdict = refVerdict;
        dispute.updatedAt = now;

        return dispute;
    }
}
