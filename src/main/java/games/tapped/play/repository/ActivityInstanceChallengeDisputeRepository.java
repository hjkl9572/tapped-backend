package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstanceChallengeDispute;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ActivityInstanceChallengeDisputeRepository
        extends JpaRepository<ActivityInstanceChallengeDispute, UUID> {
}
