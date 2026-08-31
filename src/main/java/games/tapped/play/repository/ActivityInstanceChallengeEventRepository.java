package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstanceChallengeEvent;
import games.tapped.play.entity.ChallengeEventType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

public interface ActivityInstanceChallengeEventRepository
        extends JpaRepository<ActivityInstanceChallengeEvent, UUID> {

    boolean existsByActivityInstanceIdAndEventTypeIn(
            UUID activityInstanceId,
            Collection<ChallengeEventType> eventTypes
    );

    Optional<ActivityInstanceChallengeEvent> findFirstByActivityInstanceIdOrderByCreatedAtDescIdDesc(
            UUID activityInstanceId
    );
}
