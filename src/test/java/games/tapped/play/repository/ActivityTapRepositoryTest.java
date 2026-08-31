package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@Transactional
class ActivityTapRepositoryTest {

    @Autowired
    ActivityTapRepository tapRepository;

    @Autowired
    ActivityTemplateRepository templateRepository;

    @Autowired
    ActivityInstanceRepository instanceRepository;

    @Test
    void countsOnlyFinalizedTapsInsideTheWindow() {
        UUID instanceId = createInstance();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        OffsetDateTime windowStart = now.minusDays(7);
        OffsetDateTime windowEnd = now;

        saveFinalizedTap(instanceId, 1, now.minusDays(3));
        saveFinalizedTap(instanceId, 2, now.minusDays(10));
        saveOpenTap(instanceId, 3, now.minusDays(1));
        saveCanceledTap(instanceId, 4, now.minusHours(1));

        long count = tapRepository.countFinalizedBetween(windowStart, windowEnd);

        assertEquals(1, count);
    }

    @Test
    void includesFinalizedTapsAtTheWindowBoundaries() {
        UUID instanceId = createInstance();
        OffsetDateTime windowStart = OffsetDateTime.now(ZoneOffset.UTC).minusDays(7);
        OffsetDateTime windowEnd = OffsetDateTime.now(ZoneOffset.UTC);

        saveFinalizedTap(instanceId, 1, windowStart);
        saveFinalizedTap(instanceId, 2, windowEnd);

        long count = tapRepository.countFinalizedBetween(windowStart, windowEnd);

        assertEquals(2, count);
    }

    @Test
    void returnsZeroWhenNoTapsExist() {
        long count = tapRepository.countFinalizedBetween(
                OffsetDateTime.now(ZoneOffset.UTC).minusDays(7),
                OffsetDateTime.now(ZoneOffset.UTC)
        );

        assertEquals(0, count);
    }

    private UUID createInstance() {
        ActivityTemplate template = ActivityTemplate.createRoot(
                null,
                "Run every day",
                "Run at least 20 minutes"
        );
        templateRepository.saveAndFlush(template);

        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(),
                null,
                TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO,
                UUID.randomUUID().toString(),
                1,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );
        instanceRepository.saveAndFlush(instance);

        return instance.getId();
    }

    private void saveFinalizedTap(UUID instanceId, int sequenceNo, OffsetDateTime finalizedAt) {
        ActivityTap tap = ActivityTap.open(instanceId, null, sequenceNo, finalizedAt);
        tap.finalizeTap(finalizedAt);
        tapRepository.saveAndFlush(tap);
    }

    private void saveOpenTap(UUID instanceId, int sequenceNo, OffsetDateTime now) {
        ActivityTap tap = ActivityTap.open(instanceId, null, sequenceNo, now);
        tapRepository.saveAndFlush(tap);
    }

    private void saveCanceledTap(UUID instanceId, int sequenceNo, OffsetDateTime now) {
        ActivityTap tap = ActivityTap.open(instanceId, null, sequenceNo, now);
        tap.cancel(now);
        tapRepository.saveAndFlush(tap);
    }
}
