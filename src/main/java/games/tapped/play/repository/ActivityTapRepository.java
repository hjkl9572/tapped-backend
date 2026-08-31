package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTap;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ActivityTapRepository
        extends JpaRepository<ActivityTap, UUID> {

    Optional<ActivityTap> findFirstByActivityInstanceIdOrderBySequenceNoDesc(
            UUID activityInstanceId
    );

    @Query(
            value = """
                    select *
                    from activity_taps
                    where activity_instance_id = :activityInstanceId
                    order by sequence_no desc
                    limit 1
                    for update
                    """,
            nativeQuery = true
    )
    Optional<ActivityTap> findLatestByActivityInstanceIdForUpdate(
            @Param("activityInstanceId") UUID activityInstanceId
    );

    java.util.List<ActivityTap> findAllByActivityInstanceIdOrderBySequenceNoAsc(
            UUID activityInstanceId
    );

    Optional<ActivityTap> findByIdAndActivityInstanceId(
            UUID id,
            UUID activityInstanceId
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select tap from ActivityTap tap where tap.id = :id")
    Optional<ActivityTap> findByIdForUpdate(@Param("id") UUID id);
}
