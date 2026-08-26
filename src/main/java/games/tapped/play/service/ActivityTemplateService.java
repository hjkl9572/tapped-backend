package games.tapped.play.service;

import games.tapped.play.dto.CreateActivityTemplateRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.UpdateActivityTemplateRequest;
import games.tapped.play.repository.ActivityTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ActivityTemplateService {

    private final ActivityTemplateRepository repository;

    @Transactional
    public UUID create(
            UUID userId,
            CreateActivityTemplateRequest request
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
            UpdateActivityTemplateRequest request
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
}