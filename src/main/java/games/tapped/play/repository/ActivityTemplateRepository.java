package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplate;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ActivityTemplateRepository
        extends JpaRepository<ActivityTemplate, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select template from ActivityTemplate template where template.id = :id")
    Optional<ActivityTemplate> findByIdForUpdate(@Param("id") UUID id);
}
