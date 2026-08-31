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
@Table(name = "activity_instance_challenge_config")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityInstanceChallengeConfig {

    @Id
    @Column(name = "activity_instance_id")
    private UUID activityInstanceId;

    @Column(name = "ref_user_id")
    private UUID refUserId;

    @Column(name = "ref_email", nullable = false)
    private String refEmail;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "ref_state", nullable = false)
    private ActivityRefState refState;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "ref_verdict")
    private ActivityRefVerdict refVerdict;

    @Column(name = "ref_decided_at")
    private OffsetDateTime refDecidedAt;

    @Column(name = "fail_card_fee_minor", nullable = false)
    private int failCardFeeMinor;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "last_ref_resend_at")
    private OffsetDateTime lastRefResendAt;

    @Column(name = "challenger_finalized_at")
    private OffsetDateTime challengerFinalizedAt;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "challenger_final_verdict")
    private ActivityChallengerFinalVerdict challengerFinalVerdict;

    public static ActivityInstanceChallengeConfig create(
            UUID activityInstanceId,
            String refEmail,
            int failCardFeeMinor,
            OffsetDateTime now
    ) {
        ActivityInstanceChallengeConfig config =
                new ActivityInstanceChallengeConfig();

        config.activityInstanceId = activityInstanceId;
        config.refEmail = refEmail;
        config.refState = ActivityRefState.PENDING;
        config.refVerdict = null;
        config.refDecidedAt = null;
        config.failCardFeeMinor = failCardFeeMinor;
        config.createdAt = now;
        config.updatedAt = now;

        return config;
    }

    public void markRefDecision(
            ActivityRefVerdict verdict,
            OffsetDateTime now
    ) {
        this.refState = ActivityRefState.DECIDED;
        this.refVerdict = verdict;
        this.refDecidedAt = now;
        this.updatedAt = now;
    }

    public void markChallengerFinalized(
            ActivityChallengerFinalVerdict verdict,
            OffsetDateTime now
    ) {
        this.challengerFinalizedAt = challengerFinalizedAt == null
                ? now
                : challengerFinalizedAt;
        this.challengerFinalVerdict = verdict;
        this.updatedAt = now;
    }

    public boolean hasTerminalChallengerVerdict() {
        return challengerFinalVerdict != null;
    }

    public void markRefMailSent(OffsetDateTime now) {
        this.lastRefResendAt = now;
        this.updatedAt = now;
    }
}
