package games.tapped.play.repository;

import games.tapped.play.entity.PublicActivityTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PublicActivityTemplateRepository
        extends JpaRepository<PublicActivityTemplate, UUID> {

    List<PublicActivityTemplate> findAllByOrderByPublishedAtDescIdDesc();
}
