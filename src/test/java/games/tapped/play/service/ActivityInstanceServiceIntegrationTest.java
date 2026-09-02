package games.tapped.play.service;

import games.tapped.play.dto.CreateInstanceRequest;
import games.tapped.play.dto.TemplateScheduleRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.AppUserService;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.repository.ActivityInstanceChallengeConfigRepository;
import games.tapped.play.repository.ActivityInstanceRepository;
import games.tapped.play.repository.AppUserRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

/**
 * Runs ActivityInstanceService#create against the real database with only the
 * second write (challenge config) mocked to fail, so it can prove the whole
 * @Transactional method rolls back rather than leaving a half-written instance.
 * Deliberately not @Transactional at the test level: create()'s own
 * @Transactional boundary must be the real commit/rollback boundary being
 * verified, and reads afterward must come from a fresh transaction to see
 * actually-committed state rather than this-session uncommitted writes.
 */
@SpringBootTest
class ActivityInstanceServiceIntegrationTest {

    @Autowired
    ActivityInstanceService service;

    @Autowired
    AppUserService appUserService;

    @Autowired
    AppUserRepository appUserRepository;

    @Autowired
    ActivityTemplateRepository templateRepository;

    @Autowired
    ActivityInstanceRepository instanceRepository;

    @MockitoBean
    ActivityInstanceChallengeConfigRepository challengeConfigRepository;

    private UUID ownerId;
    private UUID templateId;
    private UUID idempotencyKey;

    @AfterEach
    void cleanUp() {
        if (idempotencyKey != null) {
            instanceRepository.findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
                    ownerId,
                    idempotencyKey.toString()
            ).ifPresent(instanceRepository::delete);
        }
        if (templateId != null) {
            templateRepository.deleteById(templateId);
        }
        if (ownerId != null) {
            appUserRepository.deleteById(ownerId);
        }
    }

    private UUID newOwner() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    @Test
    void createRollsBackTheInstanceWhenChallengeConfigWriteFails() {
        ownerId = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate template = ActivityTemplate.createRoot(
                UUID.randomUUID(), ownerId, "Run every day", "Rules",
                TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, null, now
        );
        templateRepository.saveAndFlush(template);
        templateId = template.getId();

        given(challengeConfigRepository.save(any()))
                .willThrow(new RuntimeException("simulated config write failure"));

        idempotencyKey = UUID.randomUUID();

        assertThrows(
                RuntimeException.class,
                () -> service.create(
                        ownerId,
                        new CreateInstanceRequest(
                                template.getId(),
                                "ref@example.com",
                                500,
                                TemplatePlayContext.ONLINE,
                                TemplateRelationshipMode.SOLO,
                                idempotencyKey,
                                new TemplateScheduleRequest(null, null)
                        )
                )
        );

        assertTrue(
                instanceRepository.findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
                        ownerId,
                        idempotencyKey.toString()
                ).isEmpty(),
                "the activity_instances row must not survive when the challenge config write fails"
        );
    }
}
