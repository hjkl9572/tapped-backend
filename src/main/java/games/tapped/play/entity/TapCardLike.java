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
@Table(name = "tap_card_likes")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TapCardLike {

    @Id
    private UUID id;

    @Column(name = "tap_card_id", nullable = false)
    private UUID tapCardId;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    public static TapCardLike create(
            UUID tapCardId,
            UUID userId,
            OffsetDateTime now
    ) {
        TapCardLike like = new TapCardLike();

        like.id = UUID.randomUUID();
        like.tapCardId = tapCardId;
        like.userId = userId;
        like.createdAt = now;

        return like;
    }
}
