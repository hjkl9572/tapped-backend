package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstance;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ActivityInstanceRepository
        extends JpaRepository<ActivityInstance, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select instance from ActivityInstance instance where instance.id = :id")
    Optional<ActivityInstance> findByIdForUpdate(@Param("id") UUID id);

    Optional<ActivityInstance> findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
            UUID createdBy,
            String idempotencyKey
    );

    @Query("""
            select coalesce(max(instance.sequenceNo), 0)
            from ActivityInstance instance
            where instance.activityTemplateId = :templateId
              and instance.createdBy = :createdBy
              and instance.deletedAt is null
            """)
    int findMaxSequenceNo(
            @Param("templateId") UUID templateId,
            @Param("createdBy") UUID createdBy
    );
}
