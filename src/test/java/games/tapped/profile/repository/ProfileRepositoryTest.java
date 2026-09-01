package games.tapped.profile.repository;

import games.tapped.play.entity.AppUserService;
import games.tapped.profile.entity.Profile;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@Transactional
class ProfileRepositoryTest {

    @Autowired
    AppUserService appUserService;

    @Autowired
    ProfileRepository profileRepository;

    @PersistenceContext
    EntityManager entityManager;

    private UUID newOwner() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    private void insertProfile(UUID userId, String handle, String nickname) {
        entityManager.createNativeQuery(
                        "insert into profiles (id, user_id, handle, nickname) values (?1, ?2, ?3, ?4)"
                )
                .setParameter(1, UUID.randomUUID())
                .setParameter(2, userId)
                .setParameter(3, handle)
                .setParameter(4, nickname)
                .executeUpdate();
        entityManager.flush();
        entityManager.clear();
    }

    @Test
    void findByUserIdReturnsProfile() {
        UUID userId = newOwner();
        insertProfile(userId, "handle-" + userId, "nick-" + userId);

        Optional<Profile> found = profileRepository.findByUserId(userId);

        assertTrue(found.isPresent());
        assertEquals(userId, found.get().getUserId());
    }

    @Test
    void findByHandleIgnoreCaseMatchesRegardlessOfCase() {
        UUID userId = newOwner();
        String handle = "handle" + userId.toString().replace("-", "");
        insertProfile(userId, handle, "nick-" + userId);

        Optional<Profile> found = profileRepository.findByHandleIgnoreCase(handle.toUpperCase());

        assertTrue(found.isPresent());
    }

    @Test
    void existsByNicknameIgnoreCaseMatchesRegardlessOfCase() {
        UUID userId = newOwner();
        String nickname = "Nick" + userId.toString().replace("-", "").substring(0, 8);
        insertProfile(userId, "handle-" + userId, nickname);

        assertTrue(profileRepository.existsByNicknameIgnoreCase(nickname.toLowerCase()));
        assertFalse(profileRepository.existsByNicknameIgnoreCase("definitely-not-used-" + userId));
    }

    @Test
    void duplicateNicknameCaseInsensitiveViolatesUniqueConstraint() {
        UUID first = newOwner();
        UUID second = newOwner();
        String base = "shared" + first.toString().replace("-", "").substring(0, 8);
        insertProfile(first, "handle-" + first, base);
        insertProfile(second, "handle-" + second, null);

        Profile secondProfile = profileRepository.findByUserId(second).orElseThrow();
        secondProfile.changeNickname(base.toUpperCase());

        assertThrows(DataIntegrityViolationException.class, () -> {
            profileRepository.saveAndFlush(secondProfile);
        });
    }

    @Test
    void findByUserIdForUpdateLocksAndReturnsProfile() {
        UUID userId = newOwner();
        insertProfile(userId, "handle-" + userId, "nick-" + userId);

        Optional<Profile> found = profileRepository.findByUserIdForUpdate(userId);

        assertTrue(found.isPresent());
    }
}
