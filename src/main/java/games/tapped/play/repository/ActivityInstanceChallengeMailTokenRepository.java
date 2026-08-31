package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstanceChallengeMailToken;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ActivityInstanceChallengeMailTokenRepository
        extends JpaRepository<ActivityInstanceChallengeMailToken, UUID> {

    Optional<ActivityInstanceChallengeMailToken> findFirstByToken(String token);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<ActivityInstanceChallengeMailToken> findByToken(String token);

    @Query("""
            select token
            from ActivityInstanceChallengeMailToken token
            where token.activityInstanceId = :activityInstanceId
              and token.id <> :exceptTokenId
              and token.usedAt is null
              and token.invalidatedAt is null
            """)
    List<ActivityInstanceChallengeMailToken> findActiveSiblingTokens(
            @Param("activityInstanceId") UUID activityInstanceId,
            @Param("exceptTokenId") UUID exceptTokenId
    );
}
