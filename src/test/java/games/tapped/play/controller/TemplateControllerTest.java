package games.tapped.play.controller;

import games.tapped.play.dto.CreateTemplateRequest;
import games.tapped.play.dto.UpdateTemplateRequest;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.service.ActivityTemplateService;
import games.tapped.security.AppJwtPrincipal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;


import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;


@SpringBootTest
@AutoConfigureMockMvc
class TemplateControllerTest {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    ActivityTemplateService activityTemplateService;

    @Test
    void authenticatedUserCanCreateTemplate() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();

        AppJwtPrincipal principal = new AppJwtPrincipal(userId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        ActivityTemplate template = ActivityTemplate.createRoot(
                templateId,
                userId,
                "Run every day",
                "Run at least 20 minutes",
                TemplateVisibility.PUBLIC,
                TemplateLifecycleState.DRAFT,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );

        given(activityTemplateService.save(
                eq(userId),
                any(CreateTemplateRequest.class)
        )).willReturn(template);

        mockMvc.perform(
                post("/api/templates")
                        .with(authentication(authentication))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "title": "Run every day",
                                    "rules": "Run at least 20 minutes",
                                    "lifecycleState": "DRAFT"
                                }
                                """)
        )
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.template_id").value(templateId.toString()))
                .andExpect(jsonPath("$.lifecycle_state").value("DRAFT"));
    }

    @Test
    void anonymousUserCannotCreateTemplate() throws Exception {
        mockMvc.perform(
                        post("/api/templates")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                    {
                                      "title": "Run every day",
                                      "rules": "Run at least 20 minutes",
                                      "lifecycleState": "DRAFT"
                                    }
                                    """)
                )
                .andExpect(status().isUnauthorized());
    }


    @Test
    void authenticatedUserCanUpdateTemplate() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();

        AppJwtPrincipal principal = new AppJwtPrincipal(userId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        mockMvc.perform(
                        put("/api/templates/{templateId}", templateId)
                                .with(authentication(authentication))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                    {
                                        "title": "Updated title",
                                        "rules": "Updated rules"
                                    }
                                    """)
                )
                .andExpect(status().isNoContent());

        verify(activityTemplateService).update(
                eq(templateId),
                eq(userId),
                any(UpdateTemplateRequest.class)
        );
    }

    @Test
    void anonymousUserCannotUpdateTemplate() throws Exception {
        UUID templateId = UUID.randomUUID();
        mockMvc.perform(
                        put("/api/templates/{templateId}", templateId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                    {
                                        "title": "Updated title",
                                        "rules": "Updated rules"
                                    }
                                    """)
                )
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authenticatedUserCanDeleteTemplate() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();

        AppJwtPrincipal principal = new AppJwtPrincipal(userId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        mockMvc.perform(
                        delete("/api/templates/{templateId}", templateId)
                                .with(authentication(authentication))
                )
                .andExpect(status().isNoContent());

        verify(activityTemplateService)
                .delete(templateId, userId);
    }

    @Test
    void anonymousUserCannotDeleteTemplate() throws Exception {
        UUID templateId = UUID.randomUUID();

        mockMvc.perform(
                        delete("/api/templates/{templateId}", templateId)
                )
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authenticatedUserCanGetPublicTemplate() throws Exception {
        UUID userId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        userId,
                        "Public template",
                        "Rules"
                );

        UUID templateId = template.getId();

        AppJwtPrincipal principal = new AppJwtPrincipal(userId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        given(activityTemplateService.get(
                templateId,
                userId
        )).willReturn(template);

        mockMvc.perform(
                        get("/api/templates/{templateId}", templateId)
                                .with(authentication(authentication))
                )
                .andExpect(status().isOk());
    }

    @Test
    void authenticatedNonOwnerCannotGetPrivateTemplate() throws Exception {
        UUID ownerId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Private template",
                        "Rules"
                );

        UUID templateId = template.getId();

        AppJwtPrincipal principal = new AppJwtPrincipal(otherUserId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        given(activityTemplateService.get(
                templateId,
                otherUserId
        )).willThrow(new AccessDeniedException("Not allowed"));

        mockMvc.perform(
                        get("/api/templates/{templateId}", templateId)
                                .with(authentication(authentication))
                )
                .andExpect(status().isForbidden());
    }

    @Test
    void anonymousUserCanGetPublicTemplate() throws Exception {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Public template",
                        "Rules"
                );

        UUID templateId = template.getId();

        given(activityTemplateService.get(
                templateId,
                null
        )).willReturn(template);

        mockMvc.perform(
                        get("/api/templates/{templateId}", templateId)
                )
                .andExpect(status().isOk());

        verify(activityTemplateService)
                .get(templateId, null);
    }

    @Test
    void authenticatedOwnerCanGetPrivateTemplate() throws Exception {
        UUID ownerId = UUID.randomUUID();

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        ownerId,
                        "Private template",
                        "Rules"
                );

        UUID templateId = template.getId();

        AppJwtPrincipal principal = new AppJwtPrincipal(ownerId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        given(activityTemplateService.get(
                templateId,
                ownerId
        )).willReturn(template);

        mockMvc.perform(
                        get("/api/templates/{templateId}", templateId)
                                .with(authentication(authentication))
                )
                .andExpect(status().isOk());

        verify(activityTemplateService)
                .get(templateId, ownerId);
    }

    @Test
    void cannotCreateTemplateWithBlankTitle() throws Exception {
        UUID userId = UUID.randomUUID();

        AppJwtPrincipal principal = new AppJwtPrincipal(userId);

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

        mockMvc.perform(
                        post("/api/templates")
                                .with(authentication(authentication))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                    {
                                      "title": "",
                                      "rules": "Rules",
                                      "lifecycleState": "DRAFT"
                                    }
                                    """)
                )
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error")
                        .value("VALIDATION_FAILED"));
    }
}
