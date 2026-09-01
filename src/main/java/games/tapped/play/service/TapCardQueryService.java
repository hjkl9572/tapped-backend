package games.tapped.play.service;

import games.tapped.play.dto.ChallengeProcessStatus;
import games.tapped.play.dto.LeaderboardResult;
import games.tapped.play.dto.PersonalFeedItem;
import games.tapped.play.dto.PersonalFeedResponse;
import games.tapped.play.dto.TapCardLeaderboardEntry;
import games.tapped.play.dto.TapCardLeaderboardResponse;
import games.tapped.play.dto.TapCardLikeStatsEntry;
import games.tapped.play.dto.TapCardLikeStatsResponse;
import games.tapped.play.entity.ActivityChallengerFinalVerdict;
import games.tapped.play.entity.ActivityInstanceState;
import games.tapped.play.entity.ActivityRefVerdict;
import games.tapped.play.repository.PersonalFeedRow;
import games.tapped.play.repository.TapCardLeaderboardRow;
import games.tapped.play.repository.TapCardLikeCountRow;
import games.tapped.play.repository.TapCardLikeRepository;
import games.tapped.play.repository.TapCardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZoneOffset;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TapCardQueryService {

    public static final int MAX_LEADERBOARD_ENTRIES = 30;
    public static final int MAX_LIKE_STATS_BATCH_SIZE = 100;
    public static final int MAX_PERSONAL_FEED_ENTRIES = 120;

    private final TapCardRepository tapCardRepository;
    private final TapCardLikeRepository tapCardLikeRepository;

    @Transactional(readOnly = true)
    public TapCardLeaderboardResponse getLeaderboard(LeaderboardResult result) {
        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard(
                result.name(),
                MAX_LEADERBOARD_ENTRIES
        );

        return new TapCardLeaderboardResponse(
                rows.stream().map(this::toEntry).toList()
        );
    }

    @Transactional(readOnly = true)
    public TapCardLikeStatsResponse getLikeStats(List<UUID> cardIds, UUID userId) {
        if (cardIds == null || cardIds.isEmpty()) {
            throw new IllegalArgumentException("ids must not be empty");
        }

        Set<UUID> distinctIds = new LinkedHashSet<>(cardIds);
        if (distinctIds.size() > MAX_LIKE_STATS_BATCH_SIZE) {
            throw new IllegalArgumentException(
                    "ids must not contain more than " + MAX_LIKE_STATS_BATCH_SIZE + " entries"
            );
        }

        Map<UUID, Long> likeCounts = tapCardLikeRepository
                .countByCardIds(distinctIds)
                .stream()
                .collect(Collectors.toMap(
                        TapCardLikeCountRow::getTapCardId,
                        TapCardLikeCountRow::getLikeCount
                ));

        Set<UUID> likedByMe = userId == null
                ? Set.of()
                : new LinkedHashSet<>(tapCardLikeRepository.findLikedCardIds(distinctIds, userId));

        List<TapCardLikeStatsEntry> items = distinctIds.stream()
                .map(cardId -> new TapCardLikeStatsEntry(
                        cardId,
                        likeCounts.getOrDefault(cardId, 0L),
                        likedByMe.contains(cardId)
                ))
                .toList();

        return new TapCardLikeStatsResponse(items);
    }

    @Transactional(readOnly = true)
    public PersonalFeedResponse getPersonalFeed(UUID userId) {
        List<PersonalFeedRow> rows = tapCardRepository.findPersonalFeed(
                userId,
                MAX_PERSONAL_FEED_ENTRIES
        );

        return new PersonalFeedResponse(rows.stream().map(this::toPersonalFeedItem).toList());
    }

    private PersonalFeedItem toPersonalFeedItem(PersonalFeedRow row) {
        ActivityChallengerFinalVerdict finalVerdict = row.getChallengerFinalVerdict() == null
                ? null
                : ActivityChallengerFinalVerdict.valueOf(row.getChallengerFinalVerdict());
        ActivityInstanceState instanceState = ActivityInstanceState.valueOf(row.getInstanceState());
        ActivityRefVerdict refVerdict = row.getRefVerdict() == null
                ? null
                : ActivityRefVerdict.valueOf(row.getRefVerdict());

        ChallengeProcessStatus status = ChallengeStatusDeriver.deriveStatus(
                null,
                finalVerdict,
                row.getTemplateStatus(),
                instanceState,
                refVerdict
        );

        return new PersonalFeedItem(
                row.getCardId(),
                row.getActivityInstanceId(),
                row.getActivityTemplateId(),
                Objects.requireNonNullElse(row.getInstanceTitle(), "Untitled challenge"),
                row.getNote(),
                row.getPhotoPath(),
                row.getFailCardFeeMinor(),
                "USD",
                status,
                toResult(finalVerdict),
                row.getLikeCount(),
                row.getReplyCount(),
                row.getSortUpdatedAt().atOffset(ZoneOffset.UTC)
        );
    }

    private String toResult(ActivityChallengerFinalVerdict verdict) {
        if (verdict == null) {
            return null;
        }

        return switch (verdict) {
            case SUCCESS -> "SUCCESS";
            case FAIL -> "FAIL";
            case CHICKEN -> "CHICKEN";
            case DISPUTE -> "DISAGREE";
        };
    }

    private TapCardLeaderboardEntry toEntry(TapCardLeaderboardRow row) {
        return new TapCardLeaderboardEntry(
                row.getRank(),
                row.getScore(),
                row.getCardId(),
                row.getTapId(),
                row.getActivityInstanceId(),
                row.getActivityTemplateId(),
                row.getOwnerUserId(),
                row.getOwnerHandle(),
                row.getOwnerNickname(),
                row.getOwnerAvatarUrl(),
                row.getInstanceTitle(),
                row.getTemplateTitle(),
                LeaderboardResult.valueOf(row.getResult()),
                row.getNote(),
                row.getPhotoPath(),
                row.getLikeCount(),
                row.getReplyCount(),
                row.getFailCardFeeMinor(),
                row.getCardCreatedAt() == null ? null : row.getCardCreatedAt().atOffset(ZoneOffset.UTC),
                row.getCardUpdatedAt() == null ? null : row.getCardUpdatedAt().atOffset(ZoneOffset.UTC),
                row.getCompletedAt() == null ? null : row.getCompletedAt().atOffset(ZoneOffset.UTC),
                row.getRankSortAt() == null ? null : row.getRankSortAt().atOffset(ZoneOffset.UTC)
        );
    }
}
