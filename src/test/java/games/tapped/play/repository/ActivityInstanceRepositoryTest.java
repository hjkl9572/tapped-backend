package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.ActivityInstanceChallengeConfig;
import games.tapped.play.entity.ActivityInstanceChallengeEvent;
import games.tapped.play.entity.ActivityRefVerdict;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.AppUserService;
import games.tapped.play.entity.ChallengeEventType;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@Transactional
class ActivityInstanceRepositoryTest {

    @Autowired
    AppUserService appUserService;

    @Autowired
    ActivityTemplateRepository templateRepository;

    @Autowired
    ActivityInstanceRepository instanceRepository;

    @Autowired
    ActivityInstanceChallengeConfigRepository configRepository;

    @Autowired
    ActivityTapRepository tapRepository;

    @Autowired
    ActivityInstanceChallengeEventRepository eventRepository;

    private UUID newOwner() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    private UUID createActiveDashboardInstance(UUID owner, OffsetDateTime now) {
        ActivityTemplate template = ActivityTemplate.createRoot(
                UUID.randomUUID(), owner, "Run every day", "Rules",
                TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, null, now
        );
        templateRepository.saveAndFlush(template);

        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(), owner, TemplatePlayContext.ONLINE, TemplateRelationshipMode.SOLO,
                UUID.randomUUID().toString(), 1, null, now
        );
        instanceRepository.saveAndFlush(instance);

        configRepository.saveAndFlush(ActivityInstanceChallengeConfig.create(
                instance.getId(), "ref@example.com", 0, now
        ));

        return instance.getId();
    }

    @Test
    void dashboardReturnsOnlyOwnersActiveInstances() {
        UUID owner = newOwner();
        UUID other = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID mine = createActiveDashboardInstance(owner, now);
        UUID theirs = createActiveDashboardInstance(other, now);

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.stream().anyMatch(r -> r.getId().equals(mine)));
        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(theirs)));
    }

    @Test
    void dashboardExcludesCompletedInstances() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID id = createActiveDashboardInstance(owner, now);
        ActivityInstance instance = instanceRepository.findById(id).orElseThrow();
        instance.complete(null, owner, now);
        instanceRepository.saveAndFlush(instance);

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(id)));
    }

    @Test
    void dashboardExcludesInstancesWithDecidedRefState() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID id = createActiveDashboardInstance(owner, now);
        ActivityInstanceChallengeConfig config = configRepository.findById(id).orElseThrow();
        config.markRefDecision(ActivityRefVerdict.SUCCESS, now);
        configRepository.saveAndFlush(config);

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(id)));
    }

    @Test
    void dashboardExcludesInstancesWithTerminalChallengeEvent() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID id = createActiveDashboardInstance(owner, now);
        eventRepository.save(ActivityInstanceChallengeEvent.create(
                id, ChallengeEventType.CHALLENGER_FINALIZED_SUCCESS, Map.of(), now
        ));

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(id)));
    }

    @Test
    void dashboardExcludesInstanceWhenTemplateNotOwnedByCurrentUser() {
        UUID owner = newOwner();
        UUID templateOwner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate template = ActivityTemplate.createRoot(
                UUID.randomUUID(), templateOwner, "Someone else's template", "Rules",
                TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, null, now
        );
        templateRepository.saveAndFlush(template);
        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(), owner, TemplatePlayContext.ONLINE, TemplateRelationshipMode.SOLO,
                UUID.randomUUID().toString(), 1, null, now
        );
        instanceRepository.saveAndFlush(instance);
        configRepository.saveAndFlush(ActivityInstanceChallengeConfig.create(
                instance.getId(), "ref@example.com", 0, now
        ));

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(instance.getId())));
    }

    @Test
    void dashboardIncludesLatestTapWhenPresent() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID id = createActiveDashboardInstance(owner, now);
        ActivityTap tap = ActivityTap.open(id, owner, 1, now);
        tapRepository.saveAndFlush(tap);

        InstanceDashboardRow row = instanceRepository.findDashboardInstances(owner).stream()
                .filter(r -> r.getId().equals(id))
                .findFirst()
                .orElseThrow();

        assertEquals(tap.getId(), row.getLatestTapId());
        assertEquals("OPENED", row.getLatestTapState());
    }

    @Test
    void dashboardHasNullLatestTapWhenNoTapExists() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID id = createActiveDashboardInstance(owner, now);

        InstanceDashboardRow row = instanceRepository.findDashboardInstances(owner).stream()
                .filter(r -> r.getId().equals(id))
                .findFirst()
                .orElseThrow();

        assertNull(row.getLatestTapId());
    }

    @Test
    void dashboardOrdersByUpdatedAtDescending() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID older = createActiveDashboardInstance(owner, now.minusDays(1));
        UUID newer = createActiveDashboardInstance(owner, now);

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        int newerIndex = indexOf(rows, newer);
        int olderIndex = indexOf(rows, older);
        assertTrue(newerIndex < olderIndex, "more recently updated instance should sort first");
    }

    @Test
    void dashboardReturnsEmptyWhenNoEligibleInstances() {
        UUID owner = newOwner();

        List<InstanceDashboardRow> rows = instanceRepository.findDashboardInstances(owner);

        assertTrue(rows.isEmpty());
    }

    private int indexOf(List<InstanceDashboardRow> rows, UUID id) {
        for (int i = 0; i < rows.size(); i++) {
            if (rows.get(i).getId().equals(id)) {
                return i;
            }
        }
        throw new AssertionError("instance not found in dashboard rows: " + id);
    }
}
