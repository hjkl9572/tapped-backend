package games.tapped.play.service;

import games.tapped.play.dto.CreateTemplateRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.repository.ActivityTemplateRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ActivityTemplateService {

    private final ActivityTemplateRepository repository;

    @Transactional
    public UUID create(
            UUID userId,
            CreateTemplateRequest request
    ) {
        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        userId,
                        request.title(),
                        request.rules()
                );

        repository.save(template);

        return template.getId();
    }

    @Transactional
    public void update(
            UUID templateId,
            UUID userId,
            UpdateTemplateRequest request
    ) {
        ActivityTemplate template = repository.findById(templateId)
                .orElseThrow();

        if (!userId.equals(template.getCreatedBy())) {
            throw new AccessDeniedException("Not resource owner");
        }

        template.update(
                request.title(),
                request.rules(),
                userId
        );
    }

    @Transactional
    public void delete(UUID templateId, UUID userId) {
        ActivityTemplate template = repository.findById(templateId)
                .orElseThrow();

        if (!userId.equals(template.getCreatedBy())) {
            throw new AccessDeniedException("Not resource owner");
        }

        template.softDelete(userId);
    }

    @Transactional(readOnly = true)
    public ActivityTemplate get(UUID templateId, UUID userId) {
        ActivityTemplate template = repository.findById(templateId)
                .orElseThrow();

        if (template.getDeletedAt() != null) {
            throw new EntityNotFoundException();
        }

        if (template.getVisibility() == TemplateVisibility.PRIVATE
                && !Objects.equals(template.getCreatedBy(), userId)) {
            throw new AccessDeniedException("Not allowed");
        }

        return template;
    }
}