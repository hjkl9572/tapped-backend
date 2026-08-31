package games.tapped.play.controller;

import games.tapped.play.dto.LeaderboardResult;
import games.tapped.play.dto.TapCardLeaderboardResponse;
import games.tapped.play.dto.TapCardLikeResponse;
import games.tapped.play.dto.TapCardLikeStatsResponse;
import games.tapped.play.service.TapCardLikeService;
import games.tapped.play.service.TapCardQueryService;
import games.tapped.security.AppJwtPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tap-cards")
@RequiredArgsConstructor
public class TapCardController {

    private final TapCardQueryService queryService;
    private final TapCardLikeService likeService;

    @GetMapping("/leaderboard")
    public TapCardLeaderboardResponse getLeaderboard(@RequestParam LeaderboardResult result) {
        return queryService.getLeaderboard(result);
    }

    @GetMapping("/like-stats")
    public TapCardLikeStatsResponse getLikeStats(
            @RequestParam List<UUID> ids,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        UUID userId = principal != null ? principal.userId() : null;

        return queryService.getLikeStats(ids, userId);
    }

    @PutMapping("/{cardId}/like")
    public TapCardLikeResponse like(
            @PathVariable UUID cardId,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return likeService.like(cardId, principal.userId());
    }

    @DeleteMapping("/{cardId}/like")
    public TapCardLikeResponse unlike(
            @PathVariable UUID cardId,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return likeService.unlike(cardId, principal.userId());
    }
}
