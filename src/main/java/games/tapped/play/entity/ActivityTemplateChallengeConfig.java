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
@Table(name = "activity_template_challenge_config")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityTemplateChallengeConfig {

    @Id
    @Column(name = "activity_template_id")
    private UUID activityTemplateId;

    @Column(name = "ref_required", nullable = false)
    private boolean refRequired;

    @Column(name = "fail_card_fee_minor")
    private Integer failCardFeeMinor;

    private String currency;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public static ActivityTemplateChallengeConfig create(
            UUID activityTemplateId,
            String currency,
            Integer failCardFeeMinor,
            boolean refRequired,
            OffsetDateTime now
    ) {
        ActivityTemplateChallengeConfig config =
                new ActivityTemplateChallengeConfig();

        config.activityTemplateId = activityTemplateId;
        config.currency = currency;
        config.failCardFeeMinor = failCardFeeMinor;
        config.refRequired = refRequired;
        config.createdAt = now;
        config.updatedAt = now;

        return config;
    }

    public void update(
            String currency,
            Integer failCardFeeMinor,
            boolean refRequired,
            OffsetDateTime now
    ) {
        this.currency = currency;
        this.failCardFeeMinor = failCardFeeMinor;
        this.refRequired = refRequired;
        this.updatedAt = now;
    }
}
