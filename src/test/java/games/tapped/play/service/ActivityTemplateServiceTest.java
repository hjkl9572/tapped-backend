package games.tapped.play.service;

import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.repository.ActivityTemplateChallengeConfigRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import games.tapped.play.repository.PublicActivityTemplateRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.BDDMockito.given;

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
    void anyoneCanGetPublicTemplate() {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Public template",
                        "Rules"
                );

        UUID templateId = template.getId();

        given(repository.findById(templateId))
                .willReturn(Optional.of(template));

        ActivityTemplate result =
                service.get(templateId, null);

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


}
