package games.tapped.play.controller;

import games.tapped.play.dto.ChallengeProcessStatus;
import games.tapped.play.dto.LeaderboardResult;
import games.tapped.play.dto.PersonalFeedItem;
import games.tapped.play.dto.PersonalFeedResponse;
import games.tapped.play.dto.PlayInstanceTemplateSummary;
import games.tapped.play.dto.TapCardLeaderboardEntry;
import games.tapped.play.dto.TapCardLeaderboardResponse;
import games.tapped.play.dto.TapCardLikeResponse;
import games.tapped.play.dto.TapCardLikeStatsEntry;
import games.tapped.play.dto.TapCardLikeStatsResponse;
import games.tapped.play.dto.TapCardTrayItem;
import games.tapped.play.dto.TapCardTrayResponse;
import games.tapped.play.service.TapCardLikeService;
import games.tapped.play.service.TapCardQueryService;
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
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class TapCardControllerTest {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    TapCardQueryService queryService;

    @MockitoBean
    TapCardLikeService likeService;

    private UsernamePasswordAuthenticationToken authenticationFor(UUID userId) {
        return new UsernamePasswordAuthenticationToken(
                new AppJwtPrincipal(userId),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
    }

    @Test
    void anonymousUserCanGetSuccessLeaderboard() throws Exception {
        UUID cardId = UUID.randomUUID();
        given(queryService.getLeaderboard(LeaderboardResult.SUCCESS))
                .willReturn(new TapCardLeaderboardResponse(List.of(
                        new TapCardLeaderboardEntry(
                                1, 42.0, cardId, UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(),
                                UUID.randomUUID(), "handle", "nickname", null,
                                "Instance", "Template", LeaderboardResult.SUCCESS,
                                "note", null, 4, 1, 0,
                                null, null, null, null
                        )
                )));

        mockMvc.perform(get("/api/tap-cards/leaderboard").param("result", "SUCCESS"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.entries[0].cardId").value(cardId.toString()))
                .andExpect(jsonPath("$.entries[0].result").value("SUCCESS"));
    }

    @Test
    void anonymousUserCanGetFailLeaderboard() throws Exception {
        given(queryService.getLeaderboard(LeaderboardResult.FAIL))
                .willReturn(new TapCardLeaderboardResponse(List.of()));

        mockMvc.perform(get("/api/tap-cards/leaderboard").param("result", "FAIL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.entries").isEmpty());
    }

    @Test
    void unsupportedLeaderboardResultReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/tap-cards/leaderboard").param("result", "DISAGREE"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void missingLeaderboardResultReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/tap-cards/leaderboard"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void authenticatedUserCanLikeCard() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(likeService.like(cardId, userId))
                .willReturn(new TapCardLikeResponse(cardId, 3, true));

        mockMvc.perform(put("/api/tap-cards/{cardId}/like", cardId)
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cardId").value(cardId.toString()))
                .andExpect(jsonPath("$.likeCount").value(3))
                .andExpect(jsonPath("$.liked").value(true));

        verify(likeService).like(cardId, userId);
    }

    @Test
    void anonymousUserCannotLikeCard() throws Exception {
        UUID cardId = UUID.randomUUID();

        mockMvc.perform(put("/api/tap-cards/{cardId}/like", cardId))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authenticatedUserCanUnlikeCard() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(likeService.unlike(cardId, userId))
                .willReturn(new TapCardLikeResponse(cardId, 0, false));

        mockMvc.perform(delete("/api/tap-cards/{cardId}/like", cardId)
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked").value(false));

        verify(likeService).unlike(cardId, userId);
    }

    @Test
    void anonymousUserCannotUnlikeCard() throws Exception {
        UUID cardId = UUID.randomUUID();

        mockMvc.perform(delete("/api/tap-cards/{cardId}/like", cardId))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void malformedCardIdReturnsBadRequest() throws Exception {
        UUID userId = UUID.randomUUID();

        mockMvc.perform(put("/api/tap-cards/{cardId}/like", "not-a-uuid")
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isBadRequest());
    }

    @Test
    void anonymousUserCanGetLikeStats() throws Exception {
        UUID cardId = UUID.randomUUID();
        given(queryService.getLikeStats(eq(List.of(cardId)), isNull()))
                .willReturn(new TapCardLikeStatsResponse(List.of(
                        new TapCardLikeStatsEntry(cardId, 5, false)
                )));

        mockMvc.perform(get("/api/tap-cards/like-stats").param("ids", cardId.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].tapCardId").value(cardId.toString()))
                .andExpect(jsonPath("$.items[0].likeCount").value(5))
                .andExpect(jsonPath("$.items[0].likedByMe").value(false));
    }

    @Test
    void authenticatedUserGetsLikedByMeInStats() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();
        given(queryService.getLikeStats(eq(List.of(cardId)), eq(userId)))
                .willReturn(new TapCardLikeStatsResponse(List.of(
                        new TapCardLikeStatsEntry(cardId, 5, true)
                )));

        mockMvc.perform(get("/api/tap-cards/like-stats")
                        .param("ids", cardId.toString())
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].likedByMe").value(true));
    }

    @Test
    void likeStatsSupportsMultipleIds() throws Exception {
        UUID first = UUID.randomUUID();
        UUID second = UUID.randomUUID();
        given(queryService.getLikeStats(eq(List.of(first, second)), isNull()))
                .willReturn(new TapCardLikeStatsResponse(List.of(
                        new TapCardLikeStatsEntry(first, 1, false),
                        new TapCardLikeStatsEntry(second, 2, false)
                )));

        mockMvc.perform(get("/api/tap-cards/like-stats")
                        .param("ids", first + "," + second))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items.length()").value(2));
    }

    @Test
    void missingLikeStatsIdsReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/tap-cards/like-stats"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void malformedLikeStatsIdReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/tap-cards/like-stats").param("ids", "not-a-uuid"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void authenticatedUserCanGetPersonalFeed() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();
        given(queryService.getPersonalFeed(userId)).willReturn(new PersonalFeedResponse(List.of(
                new PersonalFeedItem(
                        cardId, UUID.randomUUID(), UUID.randomUUID(), "Instance", "note", null,
                        0, "USD", ChallengeProcessStatus.WAITING_FOR_REF_DECISION, null, 2, 1,
                        java.time.OffsetDateTime.parse("2026-01-01T00:00:00Z")
                )
        )));

        mockMvc.perform(get("/api/tap-cards/personal-feed")
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].cardId").value(cardId.toString()));

        verify(queryService).getPersonalFeed(userId);
    }

    @Test
    void anonymousUserCannotGetPersonalFeed() throws Exception {
        mockMvc.perform(get("/api/tap-cards/personal-feed"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void emptyPersonalFeedReturnsEmptyItems() throws Exception {
        UUID userId = UUID.randomUUID();
        given(queryService.getPersonalFeed(userId)).willReturn(new PersonalFeedResponse(List.of()));

        mockMvc.perform(get("/api/tap-cards/personal-feed")
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items").isEmpty());
    }

    @Test
    void authenticatedUserCanGetTray() throws Exception {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();
        given(queryService.getTray(userId)).willReturn(new TapCardTrayResponse(List.of(
                new TapCardTrayItem(
                        cardId, UUID.randomUUID(), UUID.randomUUID(), "note", null,
                        java.time.OffsetDateTime.parse("2026-01-01T00:00:00Z"),
                        new PlayInstanceTemplateSummary(UUID.randomUUID(), "Run every day", "Rules", null),
                        3, 2
                )
        )));

        mockMvc.perform(get("/api/tap-cards/tray")
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].id").value(cardId.toString()))
                .andExpect(jsonPath("$.items[0].template.title").value("Run every day"));

        verify(queryService).getTray(userId);
    }

    @Test
    void anonymousUserCannotGetTray() throws Exception {
        mockMvc.perform(get("/api/tap-cards/tray"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void emptyTrayReturnsEmptyItems() throws Exception {
        UUID userId = UUID.randomUUID();
        given(queryService.getTray(userId)).willReturn(new TapCardTrayResponse(List.of()));

        mockMvc.perform(get("/api/tap-cards/tray")
                        .with(authentication(authenticationFor(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items").isEmpty());
    }
}
