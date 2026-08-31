package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplateChallengeConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ActivityTemplateChallengeConfigRepository
        extends JpaRepository<ActivityTemplateChallengeConfig, UUID> {
}
