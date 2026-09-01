package games.tapped.play.controller;

import games.tapped.play.dto.ShowcaseTemplatesResponse;
import games.tapped.play.dto.TemplateCatalogResponse;
import games.tapped.play.dto.TemplateMutationResponse;
import games.tapped.play.dto.TemplateResponse;
import games.tapped.play.dto.CreateTemplateRequest;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.service.ActivityTemplateService;
import games.tapped.security.AppJwtPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/templates")
@RequiredArgsConstructor
public class TemplateController {

    private final ActivityTemplateService service;

    @PostMapping
    public ResponseEntity<TemplateMutationResponse> create(
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody CreateTemplateRequest request
    ) {
        ActivityTemplate template = service.save(
                principal.userId(),
                request
        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(TemplateMutationResponse.saved(
                        template.getId(),
                        template.getPhotoPath(),
                        template.getLifecycleState()
                ));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> put(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody UpdateTemplateRequest request
    ) {
        service.update(
                id,
                principal.userId(),
                request
        );

        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Void> update(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody UpdateTemplateRequest request
    ) {
        service.update(
                id,
                principal.userId(),
                request
        );

        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        service.delete(id, principal.userId());

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/showcase")
    public ShowcaseTemplatesResponse showcase(
            @RequestParam(required = false) Integer limit
    ) {
        return service.getShowcaseTemplates(limit);
    }

    @GetMapping("/{id}")
    public TemplateResponse get(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        UUID userId = principal != null
                ? principal.userId()
                : null;

        return TemplateResponse.from(
                service.get(id, userId)
        );
    }

    @GetMapping
    public TemplateCatalogResponse catalog() {
        return service.catalog();
    }
}
