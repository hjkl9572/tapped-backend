package games.tapped.profile.repository;

import games.tapped.profile.entity.Profile;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {

    Optional<Profile> findByUserId(UUID userId);

    Optional<Profile> findByHandleIgnoreCase(String handle);

    boolean existsByNicknameIgnoreCase(String nickname);

    boolean existsByHandleIgnoreCase(String handle);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select profile from Profile profile where profile.userId = :userId")
    Optional<Profile> findByUserIdForUpdate(@Param("userId") UUID userId);
}
