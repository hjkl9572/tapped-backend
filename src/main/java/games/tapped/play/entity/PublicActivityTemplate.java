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
@Table(name = "public_activity_templates")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PublicActivityTemplate {

    @Id
    private UUID id;

    @Column(name = "origin_id", nullable = false)
    private UUID originId;

    @Column(name = "parent_id")
    private UUID parentId;

    @Column(nullable = false)
    private String title;

    private String rules;

    @Column(name = "cadence_hint")
    private String cadenceHint;

    @Column(name = "proof_kind", nullable = false)
    private String proofKind;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "play_context", nullable = false)
    private TemplatePlayContext playContext;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "relationship_mode", nullable = false)
    private TemplateRelationshipMode relationshipMode;

    @Column(name = "creator_display_name")
    private String creatorDisplayName;

    @Column(name = "published_at", nullable = false)
    private OffsetDateTime publishedAt;

    @Column(name = "min_participants")
    private Short minParticipants;

    @Column(name = "max_participants")
    private Short maxParticipants;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "mode_kind", nullable = false)
    private ActivityModeKind modeKind;

    @Column(name = "photo_path")
    private String photoPath;

    public static PublicActivityTemplate from(ActivityTemplate template) {
        PublicActivityTemplate publicTemplate = new PublicActivityTemplate();

        publicTemplate.id = template.getId();
        publicTemplate.originId = template.getOriginId();
        publicTemplate.parentId = template.getParentId();
        publicTemplate.title = template.getTitle();
        publicTemplate.rules = template.getRules();
        publicTemplate.cadenceHint = template.getCadenceHint();
        publicTemplate.proofKind = template.getProofKind();
        publicTemplate.playContext = template.getPlayContext();
        publicTemplate.relationshipMode = template.getRelationshipMode();
        publicTemplate.creatorDisplayName = template.getCreatorDisplayName();
        publicTemplate.publishedAt = template.getPublishedAt();
        publicTemplate.minParticipants = template.getMinParticipants();
        publicTemplate.maxParticipants = template.getMaxParticipants();
        publicTemplate.modeKind = template.getModeKind();
        publicTemplate.photoPath = template.getPhotoPath();

        return publicTemplate;
    }

    public void syncFrom(ActivityTemplate template) {
        this.originId = template.getOriginId();
        this.parentId = template.getParentId();
        this.title = template.getTitle();
        this.rules = template.getRules();
        this.cadenceHint = template.getCadenceHint();
        this.proofKind = template.getProofKind();
        this.playContext = template.getPlayContext();
        this.relationshipMode = template.getRelationshipMode();
        this.creatorDisplayName = template.getCreatorDisplayName();
        this.publishedAt = template.getPublishedAt();
        this.minParticipants = template.getMinParticipants();
        this.maxParticipants = template.getMaxParticipants();
        this.modeKind = template.getModeKind();
        this.photoPath = template.getPhotoPath();
    }
}
