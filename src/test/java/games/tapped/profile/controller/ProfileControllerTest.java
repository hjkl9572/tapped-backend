package games.tapped.profile.controller;

import games.tapped.profile.dto.HandleAvailabilityResponse;
import games.tapped.profile.dto.ProfileResponse;
import games.tapped.profile.dto.ProfileUpdateCommand;
import games.tapped.profile.dto.PublicProfileResponse;
import games.tapped.profile.service.ProfileService;
import games.tapped.security.AppJwtPrincipal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class ProfileControllerTest {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    ProfileService profileService;

    private UsernamePasswordAuthenticationToken authenticationFor(UUID userId) {
        return new UsernamePasswordAuthenticationToken(
                new AppJwtPrincipal(userId),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
    }

    @Test
    void authenticatedUserCanUpdateNickname() throws Exception {
        UUID userId = UUID.randomUUID();
        given(profileService.updateCurrentProfile(
                eq(userId),
                eq(new ProfileUpdateCommand(true, "new-name", false, null, false, null))
        )).willReturn(new ProfileResponse(userId, "handle1", "new-name", "bio", null));

        mockMvc.perform(patch("/api/profiles/current")
                        .with(authentication(authenticationFor(userId)))
                        .contentType("application/json")
                        .content("{\"nickname\":\"new-name\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").value("new-name"));

        verify(profileService).updateCurrentProfile(
                eq(userId),
                eq(new ProfileUpdateCommand(true, "new-name", false, null, false, null))
        );
    }

    @Test
    void resolvesCurrentUserFromPrincipalNotFromBody() throws Exception {
        UUID userId = UUID.randomUUID();
        given(profileService.updateCurrentProfile(eq(userId), org.mockito.ArgumentMatchers.any()))
                .willReturn(new ProfileResponse(userId, "handle1", "n", null, null));

        mockMvc.perform(patch("/api/profiles/current")
                        .with(authentication(authenticationFor(userId)))
                        .contentType("application/json")
                        .content("{\"nickname\":\"n\",\"userId\":\"" + UUID.randomUUID() + "\"}"))
                .andExpect(status().isOk());

        verify(profileService).updateCurrentProfile(eq(userId), org.mockito.ArgumentMatchers.any());
    }

    @Test
    void anonymousUserCannotUpdateProfile() throws Exception {
        mockMvc.perform(patch("/api/profiles/current")
                        .contentType("application/json")
                        .content("{\"nickname\":\"new-name\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void existingHandleReturnsPublicProfile() throws Exception {
        given(profileService.getByHandle("someone"))
                .willReturn(new PublicProfileResponse("someone", "nick", "bio", null));

        mockMvc.perform(get("/api/profiles/by-handle/{handle}", "someone"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.handle").value("someone"));
    }

    @Test
    void nonexistentHandleReturnsNotFound() throws Exception {
        given(profileService.getByHandle("missing"))
                .willThrow(new jakarta.persistence.EntityNotFoundException("Profile not found."));

        mockMvc.perform(get("/api/profiles/by-handle/{handle}", "missing"))
                .andExpect(status().isNotFound());
    }

    @Test
    void byHandleIsAccessibleAnonymously() throws Exception {
        given(profileService.getByHandle("someone"))
                .willReturn(new PublicProfileResponse("someone", "nick", null, null));

        mockMvc.perform(get("/api/profiles/by-handle/{handle}", "someone"))
                .andExpect(status().isOk());
    }

    @Test
    void availableHandleReturnsTrue() throws Exception {
        given(profileService.checkHandleAvailability("freehandle"))
                .willReturn(new HandleAvailabilityResponse(true));

        mockMvc.perform(get("/api/profiles/handles/{handle}/availability", "freehandle"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true));
    }

    @Test
    void takenHandleReturnsFalse() throws Exception {
        given(profileService.checkHandleAvailability("takenhandle"))
                .willReturn(new HandleAvailabilityResponse(false));

        mockMvc.perform(get("/api/profiles/handles/{handle}/availability", "takenhandle"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(false));
    }

    @Test
    void invalidHandleReturnsBadRequest() throws Exception {
        given(profileService.checkHandleAvailability("a"))
                .willThrow(new IllegalArgumentException("Invalid handle."));

        mockMvc.perform(get("/api/profiles/handles/{handle}/availability", "a"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void handleAvailabilityIsAccessibleAnonymously() throws Exception {
        given(profileService.checkHandleAvailability("freehandle"))
                .willReturn(new HandleAvailabilityResponse(true));

        mockMvc.perform(get("/api/profiles/handles/{handle}/availability", "freehandle"))
                .andExpect(status().isOk());
    }
}
