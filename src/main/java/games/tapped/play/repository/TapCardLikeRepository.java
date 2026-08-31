package games.tapped.play.repository;

import games.tapped.play.entity.TapCardLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TapCardLikeRepository extends JpaRepository<TapCardLike, UUID> {

    Optional<TapCardLike> findByTapCardIdAndUserId(UUID tapCardId, UUID userId);

    void deleteByTapCardIdAndUserId(UUID tapCardId, UUID userId);

    long countByTapCardId(UUID tapCardId);

    @Modifying
    @Query(
            value = """
                    insert into tap_card_likes (id, tap_card_id, user_id, created_at)
                    values (:id, :tapCardId, :userId, :createdAt)
                    on conflict (tap_card_id, user_id) do nothing
                    """,
            nativeQuery = true
    )
    void insertIfAbsent(
            @Param("id") UUID id,
            @Param("tapCardId") UUID tapCardId,
            @Param("userId") UUID userId,
            @Param("createdAt") OffsetDateTime createdAt
    );

    @Query("""
            select like_.tapCardId as tapCardId, count(like_) as likeCount
            from TapCardLike like_
            where like_.tapCardId in :cardIds
            group by like_.tapCardId
            """)
    List<TapCardLikeCountRow> countByCardIds(@Param("cardIds") Collection<UUID> cardIds);

    @Query("""
            select like_.tapCardId
            from TapCardLike like_
            where like_.tapCardId in :cardIds
              and like_.userId = :userId
            """)
    List<UUID> findLikedCardIds(
            @Param("cardIds") Collection<UUID> cardIds,
            @Param("userId") UUID userId
    );
}
