package games.tapped.play.service;

import games.tapped.play.dto.LeaderboardResult;
import games.tapped.play.dto.TapCardLeaderboardEntry;
import games.tapped.play.dto.TapCardLeaderboardResponse;
import games.tapped.play.dto.TapCardLikeStatsResponse;
import games.tapped.play.repository.TapCardLeaderboardRow;
import games.tapped.play.repository.TapCardLikeCountRow;
import games.tapped.play.repository.TapCardLikeRepository;
import games.tapped.play.repository.TapCardRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class TapCardQueryServiceTest {

    @Mock
    TapCardRepository tapCardRepository;

    @Mock
    TapCardLikeRepository tapCardLikeRepository;

    @InjectMocks
    TapCardQueryService service;

    @Test
    void leaderboardDelegatesToRepositoryWithMaxEntriesAndMapsRows() {
        UUID cardId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();

        TapCardLeaderboardRow row = mock(TapCardLeaderboardRow.class);
        given(row.getRank()).willReturn(1L);
        given(row.getScore()).willReturn(52.0);
        given(row.getCardId()).willReturn(cardId);
        given(row.getTapId()).willReturn(UUID.randomUUID());
        given(row.getActivityInstanceId()).willReturn(UUID.randomUUID());
        given(row.getActivityTemplateId()).willReturn(UUID.randomUUID());
        given(row.getOwnerUserId()).willReturn(ownerId);
        given(row.getOwnerHandle()).willReturn("handle");
        given(row.getOwnerNickname()).willReturn("nickname");
        given(row.getOwnerAvatarUrl()).willReturn(null);
        given(row.getInstanceTitle()).willReturn("Run every day");
        given(row.getTemplateTitle()).willReturn("Run every day");
        given(row.getResult()).willReturn("SUCCESS");
        given(row.getNote()).willReturn("note");
        given(row.getPhotoPath()).willReturn(null);
        given(row.getLikeCount()).willReturn(4L);
        given(row.getReplyCount()).willReturn(1L);
        given(row.getFailCardFeeMinor()).willReturn(0);
        given(row.getCardCreatedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getCardUpdatedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getCompletedAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));
        given(row.getRankSortAt()).willReturn(Instant.parse("2026-01-01T00:00:00Z"));

        given(tapCardRepository.findLeaderboard("SUCCESS", TapCardQueryService.MAX_LEADERBOARD_ENTRIES))
                .willReturn(List.of(row));

        TapCardLeaderboardResponse response = service.getLeaderboard(LeaderboardResult.SUCCESS);

        assertEquals(1, response.entries().size());
        TapCardLeaderboardEntry entry = response.entries().get(0);
        assertEquals(cardId, entry.cardId());
        assertEquals(LeaderboardResult.SUCCESS, entry.result());
        assertEquals(4L, entry.likeCount());
        assertEquals(1L, entry.replyCount());

        verify(tapCardRepository).findLeaderboard("SUCCESS", TapCardQueryService.MAX_LEADERBOARD_ENTRIES);
    }

    @Test
    void leaderboardReturnsEmptyWhenNoRowsMatch() {
        given(tapCardRepository.findLeaderboard(eq("FAIL"), any(Integer.class)))
                .willReturn(List.of());

        TapCardLeaderboardResponse response = service.getLeaderboard(LeaderboardResult.FAIL);

        assertTrue(response.entries().isEmpty());
    }

    @Test
    void likeStatsFillsZeroCountForCardsWithoutLikes() {
        UUID withLikes = UUID.randomUUID();
        UUID withoutLikes = UUID.randomUUID();

        TapCardLikeCountRow countRow = mock(TapCardLikeCountRow.class);
        given(countRow.getTapCardId()).willReturn(withLikes);
        given(countRow.getLikeCount()).willReturn(5L);

        given(tapCardLikeRepository.countByCardIds(anyCollection())).willReturn(List.of(countRow));
        given(tapCardLikeRepository.findLikedCardIds(anyCollection(), any())).willReturn(List.of());

        TapCardLikeStatsResponse response = service.getLikeStats(
                List.of(withLikes, withoutLikes),
                UUID.randomUUID()
        );

        assertEquals(2, response.items().size());
        assertEquals(5L, response.items().stream()
                .filter(item -> item.tapCardId().equals(withLikes)).findFirst().orElseThrow().likeCount());
        assertEquals(0L, response.items().stream()
                .filter(item -> item.tapCardId().equals(withoutLikes)).findFirst().orElseThrow().likeCount());
    }

    @Test
    void likeStatsMarksLikedByMeOnlyForLikedCards() {
        UUID liked = UUID.randomUUID();
        UUID notLiked = UUID.randomUUID();
        UUID userId = UUID.randomUUID();

        given(tapCardLikeRepository.countByCardIds(anyCollection())).willReturn(List.of());
        given(tapCardLikeRepository.findLikedCardIds(anyCollection(), eq(userId))).willReturn(List.of(liked));

        TapCardLikeStatsResponse response = service.getLikeStats(List.of(liked, notLiked), userId);

        assertTrue(response.items().stream().filter(i -> i.tapCardId().equals(liked)).findFirst().orElseThrow().likedByMe());
        assertFalse(response.items().stream().filter(i -> i.tapCardId().equals(notLiked)).findFirst().orElseThrow().likedByMe());
    }

    @Test
    void anonymousLikeStatsNeverMarksLikedByMe() {
        UUID cardId = UUID.randomUUID();

        given(tapCardLikeRepository.countByCardIds(anyCollection())).willReturn(List.of());

        TapCardLikeStatsResponse response = service.getLikeStats(List.of(cardId), null);

        assertFalse(response.items().get(0).likedByMe());
        verify(tapCardLikeRepository, never()).findLikedCardIds(anyCollection(), any());
    }

    @Test
    void likeStatsDedupsDuplicateIds() {
        UUID cardId = UUID.randomUUID();

        given(tapCardLikeRepository.countByCardIds(anyCollection())).willReturn(List.of());

        TapCardLikeStatsResponse response = service.getLikeStats(List.of(cardId, cardId), null);

        assertEquals(1, response.items().size());
    }

    @Test
    void likeStatsRejectsEmptyIds() {
        assertThrows(IllegalArgumentException.class, () -> service.getLikeStats(List.of(), null));
    }

    @Test
    void likeStatsRejectsBatchesLargerThanMax() {
        List<UUID> tooMany = java.util.stream.Stream
                .generate(UUID::randomUUID)
                .limit(TapCardQueryService.MAX_LIKE_STATS_BATCH_SIZE + 1)
                .toList();

        assertThrows(IllegalArgumentException.class, () -> service.getLikeStats(tooMany, null));
    }
}
