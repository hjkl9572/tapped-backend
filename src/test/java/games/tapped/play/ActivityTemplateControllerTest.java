package games.tapped.play;

import games.tapped.play.dto.CreateActivityTemplateRequest;
import games.tapped.play.entity.UpdateActivityTemplateRequest;
import games.tapped.play.service.ActivityTemplateService;
import games.tapped.security.AppJwtPrincipal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;


import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;


@SpringBootTest
@AutoConfigureMockMvc
class ActivityTemplateControllerTest {

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

        given(activityTemplateService.create(
                eq(userId),
                any(CreateActivityTemplateRequest.class)
        )).willReturn(templateId);

        mockMvc.perform(
                post("/api/activity-templates")
                        .with(authentication(authentication))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "title": "Run every day",
                                    "rules": "Run at least 20 minutes"
                                }
                                """)
        )
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(templateId.toString()));
    }

    @Test
    void anonymousUserCannotCreateTemplate() throws Exception {
        mockMvc.perform(
                        post("/api/activity-templates")
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                    {
                                      "title": "Run every day",
                                      "rules": "Run at least 20 minutes"
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
                        put("/api/activity-templates/{templateId}", templateId)
                                .with(authentication(authentication))
                                .with(csrf())
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
                any(UpdateActivityTemplateRequest.class)
        );
    }

    @Test
    void anonymousUserCannotUpdateTemplate() throws Exception {
        UUID templateId = UUID.randomUUID();
        mockMvc.perform(
                        put("/api/activity-templates/{templateId}", templateId)
                                .with(csrf())
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
}
