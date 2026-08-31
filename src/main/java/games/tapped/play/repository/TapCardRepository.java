package games.tapped.play.repository;

import games.tapped.play.entity.TapCard;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TapCardRepository
        extends JpaRepository<TapCard, UUID> {

    Optional<TapCard> findByIdAndDeletedAtIsNull(UUID id);

    Optional<TapCard> findFirstByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
            UUID activityInstanceId
    );

    Optional<TapCard> findFirstByActivityInstanceIdAndDeletedAtIsNullOrderBySequenceNoDescCreatedAtDescIdDesc(
            UUID activityInstanceId
    );

    List<TapCard> findAllByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
            UUID activityInstanceId
    );

    @Query("""
            select coalesce(max(card.sequenceNo), 0)
            from TapCard card
            where card.tapId = :tapId
              and card.deletedAt is null
            """)
    int findMaxSequenceNoForTap(@Param("tapId") UUID tapId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select card from TapCard card where card.id = :id")
    Optional<TapCard> findByIdForUpdate(@Param("id") UUID id);
}
