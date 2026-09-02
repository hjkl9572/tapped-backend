package games.tapped.play.service;

import games.tapped.play.dto.ShowcaseTemplateItem;
import games.tapped.play.dto.ShowcaseTemplatesResponse;
import games.tapped.play.dto.TemplateCatalogResponse;
import games.tapped.play.dto.TemplateChallengeModeRequest;
import games.tapped.play.dto.TemplatePresetResponse;
import games.tapped.play.dto.CreateTemplateRequest;
import games.tapped.play.dto.PatchTemplateRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.ActivityTemplateChallengeConfig;
import games.tapped.play.entity.PublicActivityTemplate;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.repository.ActivityTemplateChallengeConfigRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import games.tapped.play.repository.PublicActivityTemplateRepository;
import games.tapped.play.repository.ShowcaseTemplateRow;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ActivityTemplateService {

    public static final int DEFAULT_SHOWCASE_LIMIT = 12;
    public static final int MAX_SHOWCASE_LIMIT = 50;

    private final ActivityTemplateRepository repository;
    private final ActivityTemplateChallengeConfigRepository challengeConfigRepository;
    private final PublicActivityTemplateRepository publicTemplateRepository;
    private final Clock clock = Clock.systemUTC();

    @Transactional
    public UUID create(
            UUID userId,
            CreateTemplateRequest request
    ) {
        return save(userId, request).getId();
    }

    @Transactional
    public ActivityTemplate save(
            UUID userId,
            CreateTemplateRequest request
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        UUID templateId = Objects.requireNonNullElseGet(
                request.templateId(),
                UUID::randomUUID
        );
        TemplateFields fields = resolveCreateFields(request);

        ActivityTemplate template = repository.findByIdForUpdate(templateId)
                .map(existing -> {
                    assertOwner(existing, userId);
                    assertNotDeleted(existing);
                    existing.replaceContent(
                            fields.title(),
                            fields.rules(),
                            fields.visibility(),
                            fields.lifecycleState(),
                            fields.photoPath(),
                            userId,
                            now
                    );
                    return existing;
                })
                .orElseGet(() -> ActivityTemplate.createRoot(
                        templateId,
                        userId,
                        fields.title(),
                        fields.rules(),
                        fields.visibility(),
                        fields.lifecycleState(),
                        fields.photoPath(),
                        now
                ));

        repository.save(template);
        syncChallengeConfig(
                template.getId(),
                fields.challengeMode(),
                now
        );
        syncCatalogProjection(template);

        return template;
    }

    @Transactional
    public void update(
            UUID templateId,
            UUID userId,
            UpdateTemplateRequest request
    ) {
        ActivityTemplate template = repository.findByIdForUpdate(templateId)
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        assertOwner(template, userId);
        assertNotDeleted(template);

        OffsetDateTime now = OffsetDateTime.now(clock);
        template.replaceContent(
                normalizeRequiredText(request.title(), "title"),
                normalizeNullableText(request.rules(), ""),
                Objects.requireNonNullElse(
                        request.visibility(),
                        template.getVisibility()
                ),
                Objects.requireNonNullElse(
                        request.lifecycleState(),
                        template.getLifecycleState()
                ),
                request.photoPath() == null
                        ? template.getPhotoPath()
                        : normalizeNullableText(request.photoPath(), null),
                userId,
                now
        );

        if (request.modes() != null) {
            syncChallengeConfig(
                    template.getId(),
                    request.modes().challenge(),
                    now
            );
        }
        syncCatalogProjection(template);
    }

    @Transactional
    public void patch(
            UUID templateId,
            UUID userId,
            PatchTemplateRequest request
    ) {
        ActivityTemplate template = repository.findByIdForUpdate(templateId)
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        assertOwner(template, userId);
        assertNotDeleted(template);

        OffsetDateTime now = OffsetDateTime.now(clock);
        template.replaceContent(
                request.title() == null
                        ? template.getTitle()
                        : normalizeRequiredText(request.title(), "title"),
                request.rules() == null
                        ? template.getRules()
                        : normalizeNullableText(request.rules(), ""),
                Objects.requireNonNullElse(
                        request.visibility(),
                        template.getVisibility()
                ),
                Objects.requireNonNullElse(
                        request.lifecycleState(),
                        template.getLifecycleState()
                ),
                request.photoPath() == null
                        ? template.getPhotoPath()
                        : normalizeNullableText(request.photoPath(), null),
                userId,
                now
        );

        if (request.modes() != null) {
            syncChallengeConfig(
                    template.getId(),
                    request.modes().challenge(),
                    now
            );
        }
        syncCatalogProjection(template);
    }

    @Transactional
    public void delete(UUID templateId, UUID userId) {
        ActivityTemplate template = repository.findByIdForUpdate(templateId)
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        assertOwner(template, userId);
        assertNotDeleted(template);

        template.softDelete(userId, OffsetDateTime.now(clock));
        publicTemplateRepository.deleteById(templateId);
    }

    @Transactional(readOnly = true)
    public ActivityTemplate get(UUID templateId, UUID userId) {
        ActivityTemplate template = repository.findById(templateId)
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        if (template.getDeletedAt() != null) {
            throw new EntityNotFoundException("Template not found");
        }

        if (Objects.equals(template.getCreatedBy(), userId)) {
            return template;
        }

        return requirePubliclyVisible(template);
    }

    private ActivityTemplate requirePubliclyVisible(ActivityTemplate template) {
        if (template.getVisibility() == TemplateVisibility.PRIVATE) {
            throw new AccessDeniedException("Not allowed");
        }

        boolean publiclySelectable = template.getLifecycleState() == TemplateLifecycleState.PUBLISHED
                && "ACTIVE".equals(template.getStatus());

        if (!publiclySelectable) {
            throw new EntityNotFoundException("Template not found");
        }

        return template;
    }

    @Transactional(readOnly = true)
    public TemplateCatalogResponse catalog() {
        return new TemplateCatalogResponse(
                publicTemplateRepository
                        .findAllByOrderByPublishedAtDescIdDesc()
                        .stream()
                        .map(this::toPreset)
                        .toList()
        );
    }

    @Transactional(readOnly = true)
    public ShowcaseTemplatesResponse getShowcaseTemplates(Integer requestedLimit) {
        int limit = requestedLimit == null ? DEFAULT_SHOWCASE_LIMIT : requestedLimit;

        if (limit < 1) {
            throw new IllegalArgumentException("limit must be at least 1");
        }
        if (limit > MAX_SHOWCASE_LIMIT) {
            throw new IllegalArgumentException("limit must not exceed " + MAX_SHOWCASE_LIMIT);
        }

        return new ShowcaseTemplatesResponse(
                repository.findShowcaseTemplates(limit)
                        .stream()
                        .map(this::toShowcaseItem)
                        .toList()
        );
    }

    private ShowcaseTemplateItem toShowcaseItem(ShowcaseTemplateRow row) {
        return new ShowcaseTemplateItem(
                row.getId(),
                row.getOriginId(),
                row.getTitle(),
                row.getRules(),
                row.getPhotoPath(),
                row.getCreatorDisplayName(),
                row.getPublishedAt() == null ? null : row.getPublishedAt().atOffset(ZoneOffset.UTC)
        );
    }

    private TemplatePresetResponse toPreset(PublicActivityTemplate template) {
        String title = template.getTitle();
        String rules = normalizeNullableText(template.getRules(), "");

        return new TemplatePresetResponse(
                template.getId(),
                template.getId(),
                title,
                rules,
                normalizeNullableText(template.getCadenceHint(), "free"),
                resolveTemplateImage(template.getPhotoPath()),
                title
        );
    }

    private String resolveTemplateImage(String photoPath) {
        String trimmed = normalizeNullableText(photoPath, null);
        return trimmed == null
                ? "/playTemplate/defaultTemplateImage.png"
                : trimmed;
    }

    private TemplateFields resolveCreateFields(CreateTemplateRequest request) {
        TemplateChallengeModeRequest challengeMode = request.modes() == null
                ? null
                : request.modes().challenge();

        return new TemplateFields(
                normalizeRequiredText(request.title(), "title"),
                normalizeNullableText(request.rules(), ""),
                Objects.requireNonNullElse(
                        request.visibility(),
                        TemplateVisibility.PRIVATE
                ),
                Objects.requireNonNullElse(
                        request.lifecycleState(),
                        TemplateLifecycleState.DRAFT
                ),
                normalizeNullableText(request.photoPath(), null),
                challengeMode
        );
    }

    private void syncChallengeConfig(
            UUID templateId,
            TemplateChallengeModeRequest request,
            OffsetDateTime now
    ) {
        String currency = normalizeNullableText(
                request == null ? null : request.currency(),
                "USD"
        );
        Integer failCardFeeMinor = request == null || request.failCardFeeMinor() == null
                ? 0
                : request.failCardFeeMinor();
        String refEmail = normalizeNullableText(
                request == null ? null : request.refEmail(),
                null
        );
        boolean refRequired = request != null && request.refRequired() != null
                ? request.refRequired()
                : refEmail != null;

        if (failCardFeeMinor < 0) {
            throw new IllegalArgumentException("fail_card_fee_minor must be >= 0");
        }

        challengeConfigRepository.findById(templateId)
                .ifPresentOrElse(
                        config -> config.update(
                                currency,
                                failCardFeeMinor,
                                refRequired,
                                now
                        ),
                        () -> challengeConfigRepository.save(
                                ActivityTemplateChallengeConfig.create(
                                        templateId,
                                        currency,
                                        failCardFeeMinor,
                                        refRequired,
                                        now
                                )
                        )
                );
    }

    private void syncCatalogProjection(ActivityTemplate template) {
        if (template.isCatalogVisible()) {
            publicTemplateRepository.findById(template.getId())
                    .ifPresentOrElse(
                            publicTemplate -> publicTemplate.syncFrom(template),
                            () -> publicTemplateRepository.save(
                                    PublicActivityTemplate.from(template)
                            )
                    );
            return;
        }

        publicTemplateRepository.deleteById(template.getId());
    }

    private void assertOwner(ActivityTemplate template, UUID userId) {
        if (!userId.equals(template.getCreatedBy())) {
            throw new AccessDeniedException("Not resource owner");
        }
    }

    private void assertNotDeleted(ActivityTemplate template) {
        if (template.getDeletedAt() != null) {
            throw new EntityNotFoundException("Template not found");
        }
    }

    private String normalizeRequiredText(String value, String field) {
        String normalized = normalizeNullableText(value, null);
        if (normalized == null) {
            throw new IllegalArgumentException(field + " is required");
        }
        return normalized;
    }

    private String normalizeNullableText(String value, String defaultValue) {
        if (value == null) {
            return defaultValue;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty()
                ? defaultValue
                : trimmed;
    }

    private record TemplateFields(
            String title,
            String rules,
            TemplateVisibility visibility,
            TemplateLifecycleState lifecycleState,
            String photoPath,
            TemplateChallengeModeRequest challengeMode
    ) {
    }
}
