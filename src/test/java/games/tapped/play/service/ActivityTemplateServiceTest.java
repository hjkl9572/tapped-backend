package games.tapped.play.service;

import games.tapped.play.dto.PatchTemplateRequest;
import games.tapped.play.dto.ShowcaseTemplatesResponse;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.repository.ActivityTemplateChallengeConfigRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import games.tapped.play.repository.PublicActivityTemplateRepository;
import games.tapped.play.repository.ShowcaseTemplateRow;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ActivityTemplateServiceTest {

    @Mock
    ActivityTemplateRepository repository;

    @Mock
    ActivityTemplateChallengeConfigRepository challengeConfigRepository;

    @Mock
    PublicActivityTemplateRepository publicActivityTemplateRepository;

    @InjectMocks
    ActivityTemplateService service;

    @Test
    void ownerCanUpdateTemplate() {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        userId,
                        "Old title",
                        "Old rules"
                );

        given(repository.findByIdForUpdate(templateId))
                .willReturn(Optional.of(template));

        UpdateTemplateRequest request =
                new UpdateTemplateRequest(
                        "New title",
                        "New rules"
                );

        service.update(templateId, userId, request);

        assertEquals("New title", template.getTitle());
        assertEquals("New rules", template.getRules());
        assertEquals(userId, template.getUpdatedBy());
    }

    @Test
    void patchOnlyChangesProvidedFields() {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        userId,
                        "Old title",
                        "Old rules"
                );
        template.changeVisibility(TemplateVisibility.PRIVATE);

        given(repository.findByIdForUpdate(templateId))
                .willReturn(Optional.of(template));

        PatchTemplateRequest request = new PatchTemplateRequest(
                null,
                null,
                TemplateVisibility.PUBLIC,
                null,
                null,
                null
        );

        service.patch(templateId, userId, request);

        assertEquals("Old title", template.getTitle());
        assertEquals("Old rules", template.getRules());
        assertEquals(TemplateVisibility.PUBLIC, template.getVisibility());
        assertEquals(userId, template.getUpdatedBy());
    }

    @Test
    void nonOwnerCannotUpdateTemplate() {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Old title",
                        "Old rules"
                );

        UUID templateId = template.getId();

        given(repository.findByIdForUpdate(templateId))
                .willReturn(Optional.of(template));

        UpdateTemplateRequest request =
                new UpdateTemplateRequest(
                        "Hacked title",
                        "Hacked rules"
                );

        assertThrows(
                AccessDeniedException.class,
                () -> service.update(
                        templateId,
                        otherUserId,
                        request
                )
        );

        assertEquals("Old title", template.getTitle());
        assertEquals("Old rules", template.getRules());
    }

    @Test
    void ownerCanDeleteTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Title",
                        "Rules"
                );

        UUID templateId = template.getId();

        given(repository.findByIdForUpdate(templateId))
                .willReturn(Optional.of(template));

        service.delete(templateId, ownerId);

        assertNotNull(template.getDeletedAt());
        assertEquals(ownerId, template.getDeletedBy());
    }

    @Test
    void nonOwnerCannotDeleteTemplate() {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Title",
                        "Rules"
                );

        UUID templateId = template.getId();

        given(repository.findByIdForUpdate(templateId))
                .willReturn(Optional.of(template));

        assertThrows(
                AccessDeniedException.class,
                () -> service.delete(templateId, otherUserId)
        );

        assertNull(template.getDeletedAt());
        assertNull(template.getDeletedBy());
    }

    @Test
    void anonymousCanGetPublicPublishedTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        UUID.randomUUID(),
                        ownerId,
                        "Public template",
                        "Rules",
                        TemplateVisibility.PUBLIC,
                        TemplateLifecycleState.PUBLISHED,
                        null,
                        OffsetDateTime.now(ZoneOffset.UTC)
                );

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        ActivityTemplate result =
                service.get(template.getId(), null);

        assertSame(template, result);
    }

    @Test
    void anonymousCannotGetPublicDraftTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Public draft template",
                        "Rules"
                );

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        assertThrows(
                EntityNotFoundException.class,
                () -> service.get(template.getId(), null)
        );
    }

    @Test
    void nonOwnerCannotGetPublicArchivedTemplate() {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        UUID.randomUUID(),
                        ownerId,
                        "Archived template",
                        "Rules",
                        TemplateVisibility.PUBLIC,
                        TemplateLifecycleState.ARCHIVED,
                        null,
                        OffsetDateTime.now(ZoneOffset.UTC)
                );

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        assertThrows(
                EntityNotFoundException.class,
                () -> service.get(template.getId(), otherUserId)
        );
    }

    @Test
    void ownerCanGetOwnDraftTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Public draft template",
                        "Rules"
                );

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        ActivityTemplate result =
                service.get(template.getId(), ownerId);

        assertSame(template, result);
    }

    @Test
    void ownerCanGetPrivateTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Private template",
                        "Rules"
                );

        template.changeVisibility(TemplateVisibility.PRIVATE);

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        ActivityTemplate result =
                service.get(template.getId(), ownerId);

        assertSame(template, result);
    }

    @Test
    void nonOwnerCannotGetPrivateTemplate() {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Private template",
                        "Rules"
                );

        template.changeVisibility(TemplateVisibility.PRIVATE);

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        assertThrows(
                AccessDeniedException.class,
                () -> service.get(template.getId(), otherUserId)
        );
    }

    @Test
    void anonymousUserCannotGetPrivateTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Private template",
                        "Rules"
                );

        template.changeVisibility(TemplateVisibility.PRIVATE);

        given(repository.findById(template.getId()))
                .willReturn(Optional.of(template));

        assertThrows(
                AccessDeniedException.class,
                () -> service.get(template.getId(), null)
        );
    }

    @Test
    void showcaseUsesDefaultLimitWhenNull() {
        given(repository.findShowcaseTemplates(ActivityTemplateService.DEFAULT_SHOWCASE_LIMIT))
                .willReturn(List.of());

        service.getShowcaseTemplates(null);

        verify(repository).findShowcaseTemplates(ActivityTemplateService.DEFAULT_SHOWCASE_LIMIT);
    }

    @Test
    void showcaseForwardsExplicitLimitToRepository() {
        given(repository.findShowcaseTemplates(5)).willReturn(List.of());

        service.getShowcaseTemplates(5);

        verify(repository).findShowcaseTemplates(5);
    }

    @Test
    void showcaseRejectsZeroLimit() {
        assertThrows(IllegalArgumentException.class, () -> service.getShowcaseTemplates(0));
    }

    @Test
    void showcaseRejectsNegativeLimit() {
        assertThrows(IllegalArgumentException.class, () -> service.getShowcaseTemplates(-1));
    }

    @Test
    void showcaseRejectsLimitAboveMax() {
        assertThrows(
                IllegalArgumentException.class,
                () -> service.getShowcaseTemplates(ActivityTemplateService.MAX_SHOWCASE_LIMIT + 1)
        );
    }

    @Test
    void showcaseAllowsLimitAtMax() {
        given(repository.findShowcaseTemplates(ActivityTemplateService.MAX_SHOWCASE_LIMIT))
                .willReturn(List.of());

        service.getShowcaseTemplates(ActivityTemplateService.MAX_SHOWCASE_LIMIT);

        verify(repository).findShowcaseTemplates(ActivityTemplateService.MAX_SHOWCASE_LIMIT);
    }

    @Test
    void showcaseMapsRowsToResponseItems() {
        UUID id = UUID.randomUUID();
        UUID originId = UUID.randomUUID();
        ShowcaseTemplateRow row = mock(ShowcaseTemplateRow.class);
        given(row.getId()).willReturn(id);
        given(row.getOriginId()).willReturn(originId);
        given(row.getTitle()).willReturn("Run every day");
        given(row.getRules()).willReturn("Run at least 20 minutes");
        given(row.getPhotoPath()).willReturn("templates/run.png");
        given(row.getCreatorDisplayName()).willReturn("Jane");
        given(row.getPublishedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(repository.findShowcaseTemplates(12)).willReturn(List.of(row));

        ShowcaseTemplatesResponse response = service.getShowcaseTemplates(null);

        assertEquals(1, response.items().size());
        assertEquals(id, response.items().get(0).id());
        assertEquals(originId, response.items().get(0).originId());
        assertEquals("Run every day", response.items().get(0).title());
        assertEquals("templates/run.png", response.items().get(0).photoPath());
        assertEquals("Jane", response.items().get(0).creatorDisplayName());
    }

    @Test
    void showcaseReturnsEmptyItemsWhenNoTemplatesEligible() {
        given(repository.findShowcaseTemplates(12)).willReturn(List.of());

        ShowcaseTemplatesResponse response = service.getShowcaseTemplates(null);

        assertTrue(response.items().isEmpty());
    }
}
