package games.tapped.play.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "activity_templates")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActivityTemplate {

    @Id
    private UUID id;

    @Column(name = "origin_id", nullable = false)
    private UUID originId;

    @Column(name = "parent_id")
    private UUID parentId;

    @Column(nullable = false)
    private String title;

    private String rules;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "lifecycle_state", nullable = false)
    private TemplateLifecycleState lifecycleState;

    @Column(name = "cadence_hint")
    private String cadenceHint;

    @Column(name = "proof_kind", nullable = false)
    private String proofKind;

    @Column(nullable = false)
    private String status;

    @Column(name = "curation_bucket")
    private Short curationBucket;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "play_context", nullable = false)
    private TemplatePlayContext playContext;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "relationship_mode", nullable = false)
    private TemplateRelationshipMode relationshipMode;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "idempotency_key")
    private String idempotencyKey;

    @Column(name = "creator_display_name")
    private String creatorDisplayName;

    @Column(name = "created_at", nullable = false, insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false, insertable = false, updatable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @Column(name = "deleted_by")
    private UUID deletedBy;

    @Column(name = "min_participants")
    private Short minParticipants;

    @Column(name = "max_participants")
    private Short maxParticipants;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "mode_kind", nullable = false)
    private ActivityModeKind modeKind;

    @Column(name = "published_at")
    private OffsetDateTime publishedAt;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false)
    private TemplateVisibility visibility;

    @Column(name = "deleted_photo_path")
    private String deletedPhotoPath;

    @Column(name = "photo_path")
    private String photoPath;

    public static ActivityTemplate createRoot(
            UUID createdBy,
            String title,
            String rules
    ) {
        return createRoot(
                UUID.randomUUID(),
                createdBy,
                title,
                rules,
                TemplateVisibility.PUBLIC,
                TemplateLifecycleState.DRAFT,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );
    }

    public static ActivityTemplate createRoot(
            UUID id,
            UUID createdBy,
            String title,
            String rules,
            TemplateVisibility visibility,
            TemplateLifecycleState lifecycleState,
            String photoPath,
            OffsetDateTime now
    ) {
        ActivityTemplate template = new ActivityTemplate();

        template.id = id;
        template.originId = id;
        template.parentId = null;

        template.title = title;
        template.rules = rules;
        template.photoPath = photoPath;

        template.lifecycleState = lifecycleState;
        template.proofKind = "ANY";
        template.status = "ACTIVE";
        template.playContext = TemplatePlayContext.ONLINE;
        template.relationshipMode = TemplateRelationshipMode.SOLO;
        template.minParticipants = 1;
        template.maxParticipants = 1;
        template.modeKind = ActivityModeKind.CHALLENGE;
        template.visibility = visibility;
        template.publishedAt = lifecycleState == TemplateLifecycleState.PUBLISHED
                ? now
                : null;

        template.createdBy = createdBy;
        template.updatedBy = createdBy;

        return template;
    }

    public void update(String title, String rules, UUID updatedBy) {
        this.title = title;
        this.rules = rules;
        this.updatedBy = updatedBy;
    }

    public void replaceContent(
            String title,
            String rules,
            TemplateVisibility visibility,
            TemplateLifecycleState lifecycleState,
            String photoPath,
            UUID updatedBy,
            OffsetDateTime now
    ) {
        this.title = title;
        this.rules = rules;
        this.visibility = visibility;
        this.lifecycleState = lifecycleState;
        this.photoPath = photoPath;
        this.publishedAt = lifecycleState == TemplateLifecycleState.PUBLISHED
                ? now
                : null;
        this.modeKind = ActivityModeKind.CHALLENGE;
        this.playContext = TemplatePlayContext.ONLINE;
        this.relationshipMode = TemplateRelationshipMode.SOLO;
        this.proofKind = "ANY";
        this.minParticipants = 1;
        this.maxParticipants = 1;
        this.updatedBy = updatedBy;
    }

    public void softDelete(UUID deletedBy, OffsetDateTime now) {
        this.deletedAt = now;
        this.deletedBy = deletedBy;
    }

    public void changeVisibility(TemplateVisibility visibility) {
        this.visibility = visibility;
    }

    public boolean isCatalogVisible() {
        return deletedAt == null
                && visibility == TemplateVisibility.PUBLIC
                && lifecycleState == TemplateLifecycleState.PUBLISHED
                && publishedAt != null;
    }
}
