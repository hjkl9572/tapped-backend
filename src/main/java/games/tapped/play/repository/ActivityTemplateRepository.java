package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ActivityTemplateRepository
        extends JpaRepository<ActivityTemplate, UUID> {
}