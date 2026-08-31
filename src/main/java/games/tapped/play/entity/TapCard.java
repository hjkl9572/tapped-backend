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
@Table(name = "tap_cards")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TapCard {

    @Id
    private UUID id;

    @Column(name = "activity_instance_id", nullable = false)
    private UUID activityInstanceId;

    @Column(name = "tap_id", nullable = false)
    private UUID tapId;

    @Column(name = "created_by", nullable = false)
    private UUID createdBy;

    @Column(name = "sequence_no", nullable = false)
    private int sequenceNo;

    private String note;

    @Column(name = "link_url")
    private String linkUrl;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @Column(name = "tap_sequence_no", nullable = false)
    private int tapSequenceNo;

    @Column(name = "deleted_photo_path")
    private String deletedPhotoPath;

    @Column(name = "photo_path")
    private String photoPath;

    public static TapCard create(
            UUID activityInstanceId,
            UUID tapId,
            UUID createdBy,
            int sequenceNo,
            int tapSequenceNo,
            String note,
            String photoPath,
            OffsetDateTime now
    ) {
        TapCard card = new TapCard();

        card.id = UUID.randomUUID();
        card.activityInstanceId = activityInstanceId;
        card.tapId = tapId;
        card.createdBy = createdBy;
        card.sequenceNo = sequenceNo;
        card.tapSequenceNo = tapSequenceNo;
        card.note = note;
        card.photoPath = photoPath;
        card.createdAt = now;
        card.updatedAt = now;

        return card;
    }
}
