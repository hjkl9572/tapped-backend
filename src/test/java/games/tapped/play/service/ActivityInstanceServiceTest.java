package games.tapped.play.service;

import games.tapped.play.dto.CreateInstanceRequest;
import games.tapped.play.dto.CreateInstanceResponse;
import games.tapped.play.dto.InstanceDashboardResponse;
import games.tapped.play.dto.TemplateScheduleRequest;
import games.tapped.play.dto.ToggleTapResponse;
import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.ActivityInstanceChallengeConfig;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTapState;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.repository.ActivityInstanceChallengeConfigRepository;
import games.tapped.play.repository.ActivityInstanceChallengeDisputeRepository;
import games.tapped.play.repository.ActivityInstanceChallengeEventRepository;
import games.tapped.play.repository.ActivityInstanceChallengeMailTokenRepository;
import games.tapped.play.repository.ActivityInstanceRepository;
import games.tapped.play.repository.ActivityTapRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import games.tapped.play.repository.InstanceDashboardRow;
import games.tapped.play.repository.TapCardRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ActivityInstanceServiceTest {

    @Mock
    ActivityInstanceRepository instanceRepository;

    @Mock
    ActivityTemplateRepository templateRepository;

    @Mock
    ActivityInstanceChallengeConfigRepository challengeConfigRepository;

    @Mock
    ActivityTapRepository tapRepository;

    @Mock
    TapCardRepository tapCardRepository;

    @Mock
    ActivityInstanceChallengeEventRepository challengeEventRepository;

    @Mock
    ActivityInstanceChallengeDisputeRepository disputeRepository;

    @Mock
    ActivityInstanceChallengeMailTokenRepository mailTokenRepository;

    @InjectMocks
    ActivityInstanceService service;

    @Test
    void createsChallengeInstanceFromPlayableTemplate() {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();
        UUID idempotencyKey = UUID.randomUUID();
        ActivityTemplate template = publishedTemplate(templateId, userId);

        given(templateRepository.findById(templateId))
                .willReturn(Optional.of(template));
        given(instanceRepository.findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
                userId,
                idempotencyKey.toString()
        )).willReturn(Optional.empty());
        given(instanceRepository.findMaxSequenceNo(templateId, userId))
                .willReturn(2);

        CreateInstanceResponse response = service.create(
                userId,
                new CreateInstanceRequest(
                        templateId,
                        "Ref@Example.com",
                        500,
                        TemplatePlayContext.ONLINE,
                        TemplateRelationshipMode.SOLO,
                        idempotencyKey,
                        new TemplateScheduleRequest(null, null)
                )
        );

        assertEquals(3, response.sequenceNo());
        assertEquals(templateId, response.templateId());

        ArgumentCaptor<ActivityInstanceChallengeConfig> configCaptor =
                ArgumentCaptor.forClass(ActivityInstanceChallengeConfig.class);
        verify(challengeConfigRepository).save(configCaptor.capture());
        assertEquals("ref@example.com", configCaptor.getValue().getRefEmail());
        assertEquals(500, configCaptor.getValue().getFailCardFeeMinor());
    }

    @Test
    void createReturnsExistingInstanceForSameIdempotencyKey() {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();
        UUID idempotencyKey = UUID.randomUUID();
        ActivityTemplate template = publishedTemplate(templateId, userId);
        ActivityInstance existing = ActivityInstance.createChallenge(
                templateId,
                userId,
                TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO,
                idempotencyKey.toString(),
                4,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );

        given(templateRepository.findById(templateId))
                .willReturn(Optional.of(template));
        given(instanceRepository.findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
                userId,
                idempotencyKey.toString()
        )).willReturn(Optional.of(existing));

        CreateInstanceResponse response = service.create(
                userId,
                new CreateInstanceRequest(
                        templateId,
                        "ref@example.com",
                        500,
                        null,
                        null,
                        idempotencyKey,
                        null
                )
        );

        assertEquals(existing.getId(), response.playInstanceId());
        assertEquals(4, response.sequenceNo());
    }

    @Test
    void nonOwnerCannotReadInstance() {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();
        ActivityInstance instance = ActivityInstance.createChallenge(
                templateId,
                ownerId,
                TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO,
                UUID.randomUUID().toString(),
                1,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );

        given(instanceRepository.findById(instance.getId()))
                .willReturn(Optional.of(instance));

        assertThrows(
                AccessDeniedException.class,
                () -> service.get(otherUserId, instance.getId())
        );
    }

    @Test
    void toggleTapCreatesFirstTap() {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();
        ActivityInstance instance = ActivityInstance.createChallenge(
                templateId,
                userId,
                TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO,
                UUID.randomUUID().toString(),
                1,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );
        ActivityInstanceChallengeConfig config =
                ActivityInstanceChallengeConfig.create(
                        instance.getId(),
                        "ref@example.com",
                        500,
                        OffsetDateTime.now(ZoneOffset.UTC)
                );

        given(instanceRepository.findByIdForUpdate(instance.getId()))
                .willReturn(Optional.of(instance));
        given(challengeConfigRepository.findByActivityInstanceIdForUpdate(instance.getId()))
                .willReturn(Optional.of(config));
        given(tapRepository.findLatestByActivityInstanceIdForUpdate(instance.getId()))
                .willReturn(Optional.empty());

        ToggleTapResponse response = service.toggleTap(userId, instance.getId());

        assertTrue(response.ok());
        assertEquals("OPENED", response.data().action());
        assertEquals(1, response.data().sequenceNo());
        assertEquals(ActivityTapState.OPENED, response.data().state());

        ArgumentCaptor<ActivityTap> tapCaptor =
                ArgumentCaptor.forClass(ActivityTap.class);
        verify(tapRepository).save(tapCaptor.capture());
        assertEquals(userId, tapCaptor.getValue().getTappedBy());
        assertEquals(instance.getId(), tapCaptor.getValue().getActivityInstanceId());
    }

    @Test
    void dashboardDelegatesToRepositoryForCurrentUser() {
        UUID userId = UUID.randomUUID();
        given(instanceRepository.findDashboardInstances(userId)).willReturn(List.of());

        service.getDashboard(userId);

        verify(instanceRepository).findDashboardInstances(userId);
    }

    @Test
    void dashboardReturnsEmptyItemsWhenNothingEligible() {
        UUID userId = UUID.randomUUID();
        given(instanceRepository.findDashboardInstances(userId)).willReturn(List.of());

        InstanceDashboardResponse response = service.getDashboard(userId);

        assertTrue(response.items().isEmpty());
    }

    @Test
    void dashboardMapsRowWithLatestTap() {
        UUID userId = UUID.randomUUID();
        UUID instanceId = UUID.randomUUID();
        UUID tapId = UUID.randomUUID();
        InstanceDashboardRow row = mock(InstanceDashboardRow.class);
        given(row.getId()).willReturn(instanceId);
        given(row.getModeKind()).willReturn("CHALLENGE");
        given(row.getTitle()).willReturn("Run every day");
        given(row.getRules()).willReturn("Run at least 20 minutes");
        given(row.getPhotoPath()).willReturn(null);
        given(row.getPlayContext()).willReturn("ONLINE");
        given(row.getRelationshipMode()).willReturn("SOLO");
        given(row.getProofKind()).willReturn("ANY");
        given(row.getStartedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getUpdatedAt()).willReturn(Instant.parse("2026-01-01T01:00:00Z"));
        given(row.getLatestTapId()).willReturn(tapId);
        given(row.getLatestTapState()).willReturn("OPENED");
        given(row.getLatestTapSequenceNo()).willReturn(1);
        given(row.getLatestTapFirstHappenedAt()).willReturn(Instant.parse("2026-01-01T01:00:00Z"));
        given(row.getLatestTapFinalizedAt()).willReturn(null);
        given(row.getLatestTapCanceledAt()).willReturn(null);
        given(instanceRepository.findDashboardInstances(userId)).willReturn(List.of(row));

        InstanceDashboardResponse response = service.getDashboard(userId);

        assertEquals(1, response.items().size());
        assertEquals(instanceId, response.items().get(0).id());
        assertEquals("Run every day", response.items().get(0).title());
        assertEquals(tapId, response.items().get(0).latestTap().id());
        assertEquals(ActivityTapState.OPENED, response.items().get(0).latestTap().state());
    }

    @Test
    void dashboardMapsRowWithNoTapToNullLatestTap() {
        UUID userId = UUID.randomUUID();
        InstanceDashboardRow row = mock(InstanceDashboardRow.class);
        given(row.getId()).willReturn(UUID.randomUUID());
        given(row.getModeKind()).willReturn("CHALLENGE");
        given(row.getTitle()).willReturn("Run every day");
        given(row.getRules()).willReturn("Rules");
        given(row.getPhotoPath()).willReturn(null);
        given(row.getPlayContext()).willReturn("ONLINE");
        given(row.getRelationshipMode()).willReturn("SOLO");
        given(row.getProofKind()).willReturn("ANY");
        given(row.getStartedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getUpdatedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getLatestTapId()).willReturn(null);
        given(instanceRepository.findDashboardInstances(userId)).willReturn(List.of(row));

        InstanceDashboardResponse response = service.getDashboard(userId);

        assertNull(response.items().get(0).latestTap());
    }

    private ActivityTemplate publishedTemplate(UUID templateId, UUID userId) {
        return ActivityTemplate.createRoot(
                templateId,
                userId,
                "Public template",
                "Rules",
                TemplateVisibility.PUBLIC,
                TemplateLifecycleState.PUBLISHED,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );
    }
}
