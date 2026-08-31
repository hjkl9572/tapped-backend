package games.tapped.play.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "activity_instance_challenge_mail_tokens")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityInstanceChallengeMailToken {

    public static final String REF_ACCESS_ACTION = "ref_access";

    @Id
    private UUID id;

    @Column(name = "activity_instance_id", nullable = false)
    private UUID activityInstanceId;

    @Column(nullable = false)
    private String token;

    @Column(nullable = false)
    private String action;

    @Column(name = "used_at")
    private OffsetDateTime usedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "expires_at")
    private OffsetDateTime expiresAt;

    @Column(name = "invalidated_at")
    private OffsetDateTime invalidatedAt;

    public static ActivityInstanceChallengeMailToken createRefAccess(
            UUID activityInstanceId,
            String token,
            OffsetDateTime expiresAt,
            OffsetDateTime now
    ) {
        ActivityInstanceChallengeMailToken mailToken =
                new ActivityInstanceChallengeMailToken();

        mailToken.id = UUID.randomUUID();
        mailToken.activityInstanceId = activityInstanceId;
        mailToken.token = token;
        mailToken.action = REF_ACCESS_ACTION;
        mailToken.createdAt = now;
        mailToken.expiresAt = expiresAt;

        return mailToken;
    }

    public boolean isValidRefAccess(OffsetDateTime now) {
        return REF_ACCESS_ACTION.equals(action)
                && usedAt == null
                && invalidatedAt == null
                && (expiresAt == null || expiresAt.isAfter(now));
    }

    public boolean isExpired(OffsetDateTime now) {
        return expiresAt != null && !expiresAt.isAfter(now);
    }

    public void markUsed(OffsetDateTime now) {
        usedAt = now;
    }

    public void invalidate(OffsetDateTime now) {
        invalidatedAt = now;
    }
}
