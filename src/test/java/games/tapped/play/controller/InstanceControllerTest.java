package games.tapped.play.controller;

import games.tapped.play.dto.CreateInstanceRequest;
import games.tapped.play.dto.CreateInstanceResponse;
import games.tapped.play.dto.InstanceDashboardItem;
import games.tapped.play.dto.InstanceDashboardResponse;
import games.tapped.play.dto.PlayInstanceSummaryResponse;
import games.tapped.play.dto.RefDecisionRequest;
import games.tapped.play.dto.ToggleTapData;
import games.tapped.play.dto.ToggleTapResponse;
import games.tapped.play.entity.ActivityModeKind;
import games.tapped.play.entity.ActivityTapState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.service.ActivityInstanceService;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class InstanceControllerTest {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    ActivityInstanceService activityInstanceService;

    @Test
    void authenticatedUserCanCreateInstance() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID templateId = UUID.randomUUID();
        UUID instanceId = UUID.randomUUID();
        UUID idempotencyKey = UUID.randomUUID();

        given(activityInstanceService.create(
                eq(userId),
                any(CreateInstanceRequest.class)
        )).willReturn(new CreateInstanceResponse(
                instanceId,
                1,
                templateId
        ));

        mockMvc.perform(
                post("/api/instances")
                        .with(authentication(auth(userId)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "activityTemplateId": "%s",
                                  "refEmail": "ref@example.com",
                                  "amountCents": 500,
                                  "playContext": "ONLINE",
                                  "relationshipMode": "SOLO",
                                  "idempotency_key": "%s"
                                }
                                """.formatted(templateId, idempotencyKey))
        )
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.play_instance_id").value(instanceId.toString()))
                .andExpect(jsonPath("$.sequence_no").value(1))
                .andExpect(jsonPath("$.template_id").value(templateId.toString()));
    }

    @Test
    void anonymousUserCannotCreateInstance() throws Exception {
        mockMvc.perform(
                post("/api/instances")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "activityTemplateId": "%s",
                                  "refEmail": "ref@example.com",
                                  "amountCents": 500,
                                  "idempotency_key": "%s"
                                }
                                """.formatted(UUID.randomUUID(), UUID.randomUUID()))
        )
                .andExpect(status().isUnauthorized());
    }

    @Test
    void invalidChallengeAmountFailsValidation() throws Exception {
        UUID userId = UUID.randomUUID();

        mockMvc.perform(
                post("/api/instances")
                        .with(authentication(auth(userId)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "activityTemplateId": "%s",
                                  "refEmail": "ref@example.com",
                                  "amountCents": 123,
                                  "idempotency_key": "%s"
                                }
                                """.formatted(UUID.randomUUID(), UUID.randomUUID()))
        )
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_FAILED"));
    }

    @Test
    void authenticatedUserCanReadInstanceSummary() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID instanceId = UUID.randomUUID();

        given(activityInstanceService.get(userId, instanceId))
                .willReturn(new PlayInstanceSummaryResponse(null));

        mockMvc.perform(
                get("/api/instances/{id}", instanceId)
                        .with(authentication(auth(userId)))
        )
                .andExpect(status().isOk());

        verify(activityInstanceService).get(userId, instanceId);
    }

    @Test
    void authenticatedUserCanToggleTap() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID instanceId = UUID.randomUUID();
        UUID tapId = UUID.randomUUID();

        given(activityInstanceService.toggleTap(userId, instanceId))
                .willReturn(new ToggleTapResponse(
                        true,
                        new ToggleTapData(
                                "OPENED",
                                tapId,
                                instanceId,
                                1,
                                ActivityTapState.OPENED,
                                null
                        )
                ));

        mockMvc.perform(
                post("/api/instances/{id}/taps", instanceId)
                        .with(authentication(auth(userId)))
        )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ok").value(true))
                .andExpect(jsonPath("$.data.tap_id").value(tapId.toString()));
    }

    @Test
    void refDecisionEndpointIsTokenBasedAndDoesNotRequireLogin() throws Exception {
        UUID instanceId = UUID.randomUUID();

        given(activityInstanceService.submitRefDecision(any(RefDecisionRequest.class)))
                .willReturn(ActivityInstanceService.RefDecisionResult.accepted(
                        instanceId,
                        "REF_DECIDED_SUCCESS"
                ));

        mockMvc.perform(
                post("/api/instances/ref-decisions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "token": "token-123",
                                  "verdict": "SUCCESS"
                                }
                                """)
        )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ok").value(true))
                .andExpect(jsonPath("$.activityInstanceId").value(instanceId.toString()));
    }

    @Test
    void authenticatedUserCanGetDashboard() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID instanceId = UUID.randomUUID();

        given(activityInstanceService.getDashboard(userId))
                .willReturn(new InstanceDashboardResponse(List.of(
                        new InstanceDashboardItem(
                                instanceId, ActivityModeKind.CHALLENGE, "Run every day",
                                "Run at least 20 minutes", null,
                                TemplatePlayContext.ONLINE, TemplateRelationshipMode.SOLO, "ANY",
                                java.time.OffsetDateTime.parse("2026-01-01T00:00:00Z"),
                                java.time.OffsetDateTime.parse("2026-01-01T00:00:00Z"),
                                null
                        )
                )));

        mockMvc.perform(
                        get("/api/instances/dashboard")
                                .with(authentication(auth(userId)))
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].id").value(instanceId.toString()))
                .andExpect(jsonPath("$.items[0].title").value("Run every day"));

        verify(activityInstanceService).getDashboard(userId);
    }

    @Test
    void anonymousUserCannotGetDashboard() throws Exception {
        mockMvc.perform(get("/api/instances/dashboard"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void emptyDashboardReturnsEmptyItems() throws Exception {
        UUID userId = UUID.randomUUID();
        given(activityInstanceService.getDashboard(userId))
                .willReturn(new InstanceDashboardResponse(List.of()));

        mockMvc.perform(
                        get("/api/instances/dashboard")
                                .with(authentication(auth(userId)))
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items").isEmpty());
    }

    private UsernamePasswordAuthenticationToken auth(UUID userId) {
        return new UsernamePasswordAuthenticationToken(
                new AppJwtPrincipal(userId),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
    }
}
