package games.tapped.play.service;

import games.tapped.play.entity.ActivityInstanceChallengeEvent;
import games.tapped.play.entity.ChallengeEventType;
import games.tapped.play.repository.ActivityInstanceChallengeEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Records challenge events that must survive the rollback of the caller's
 * transaction, e.g. a MAIL_FAILED event written after an external mail
 * provider call fails and the rest of the enclosing operation is aborted.
 */
@Component
@RequiredArgsConstructor
public class ChallengeEventRecorder {

    private final ActivityInstanceChallengeEventRepository repository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordIndependently(
            UUID activityInstanceId,
            ChallengeEventType eventType,
            Map<String, Object> payload,
            OffsetDateTime now
    ) {
        repository.save(ActivityInstanceChallengeEvent.create(
                activityInstanceId,
                eventType,
                payload,
                now
        ));
    }
}
