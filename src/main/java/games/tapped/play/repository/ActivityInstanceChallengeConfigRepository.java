package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstanceChallengeConfig;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ActivityInstanceChallengeConfigRepository
        extends JpaRepository<ActivityInstanceChallengeConfig, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select config
            from ActivityInstanceChallengeConfig config
            where config.activityInstanceId = :activityInstanceId
            """)
    Optional<ActivityInstanceChallengeConfig> findByActivityInstanceIdForUpdate(
            @Param("activityInstanceId") UUID activityInstanceId
    );
}
