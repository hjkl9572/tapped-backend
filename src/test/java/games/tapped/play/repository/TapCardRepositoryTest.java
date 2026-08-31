package games.tapped.play.repository;

import games.tapped.play.entity.ActivityChallengerFinalVerdict;
import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.ActivityInstanceChallengeConfig;
import games.tapped.play.entity.ActivityRefVerdict;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.AppUserService;
import games.tapped.play.entity.TapCard;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import java.util.stream.IntStream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@Transactional
class TapCardRepositoryTest {

    @Autowired
    AppUserService appUserService;

    @Autowired
    ActivityTemplateRepository templateRepository;

    @Autowired
    ActivityInstanceRepository instanceRepository;

    @Autowired
    ActivityInstanceChallengeConfigRepository configRepository;

    @Autowired
    ActivityTapRepository tapRepository;

    @Autowired
    TapCardRepository tapCardRepository;

    @Autowired
    TapCardLikeRepository tapCardLikeRepository;

    @PersistenceContext
    EntityManager entityManager;

    private UUID newOwner() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    private UUID createCard(
            UUID ownerId,
            ActivityChallengerFinalVerdict challengerVerdict,
            TemplateVisibility visibility,
            TemplateLifecycleState lifecycleState,
            boolean completeInstance,
            int failCardFeeMinor
    ) {
        return createCard(
                ownerId, challengerVerdict, visibility, lifecycleState,
                completeInstance, failCardFeeMinor, OffsetDateTime.now(ZoneOffset.UTC)
        );
    }

    private UUID createCard(
            UUID ownerId,
            ActivityChallengerFinalVerdict challengerVerdict,
            TemplateVisibility visibility,
            TemplateLifecycleState lifecycleState,
            boolean completeInstance,
            int failCardFeeMinor,
            OffsetDateTime now
    ) {
        ActivityTemplate template = ActivityTemplate.createRoot(
                UUID.randomUUID(), ownerId, "Run every day", "Rules",
                visibility, lifecycleState, null, now
        );
        templateRepository.saveAndFlush(template);

        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(), ownerId, TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO, UUID.randomUUID().toString(), 1, null, now
        );
        if (completeInstance) {
            instance.complete(null, ownerId, now);
        }
        instanceRepository.saveAndFlush(instance);

        ActivityInstanceChallengeConfig config = ActivityInstanceChallengeConfig.create(
                instance.getId(), "ref@example.com", failCardFeeMinor, now
        );
        config.markRefDecision(ActivityRefVerdict.SUCCESS, now);
        if (challengerVerdict != null) {
            config.markChallengerFinalized(challengerVerdict, now);
        }
        configRepository.saveAndFlush(config);

        ActivityTap tap = ActivityTap.open(instance.getId(), ownerId, 1, now);
        tapRepository.saveAndFlush(tap);

        TapCard card = TapCard.create(instance.getId(), tap.getId(), ownerId, 1, 1, "note", null, now);
        tapCardRepository.saveAndFlush(card);

        return card.getId();
    }

    private UUID createEligibleCard(UUID ownerId, ActivityChallengerFinalVerdict verdict, int failCardFeeMinor) {
        return createCard(
                ownerId, verdict, TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, true, failCardFeeMinor
        );
    }

    private UUID createEligibleCard(
            UUID ownerId, ActivityChallengerFinalVerdict verdict, int failCardFeeMinor, OffsetDateTime now
    ) {
        return createCard(
                ownerId, verdict, TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED,
                true, failCardFeeMinor, now
        );
    }

    private void addReply(UUID cardId, UUID authorId, String status, boolean deleted) {
        String deletedAtClause = deleted ? ", now()" : "";
        String deletedColumn = deleted ? ", deleted_at" : "";
        entityManager.createNativeQuery("""
                insert into tap_card_replies (id, tap_card_id, user_id, body, status, created_at, updated_at%s)
                values (:id, :cardId, :userId, 'nice job', CAST(:status AS content_status), now(), now()%s)
                """.formatted(deletedColumn, deletedAtClause))
                .setParameter("id", UUID.randomUUID())
                .setParameter("cardId", cardId)
                .setParameter("userId", authorId)
                .setParameter("status", status)
                .executeUpdate();
    }

    private void addProfile(UUID userId, String handle, String nickname, String avatarUrl) {
        entityManager.createNativeQuery("""
                insert into profiles (id, user_id, handle, nickname, avatar_url, created_at, updated_at)
                values (:id, :userId, :handle, :nickname, :avatarUrl, now(), now())
                """)
                .setParameter("id", UUID.randomUUID())
                .setParameter("userId", userId)
                .setParameter("handle", handle)
                .setParameter("nickname", nickname)
                .setParameter("avatarUrl", avatarUrl)
                .executeUpdate();
    }

    private void likeCard(UUID cardId, int times) {
        for (int i = 0; i < times; i++) {
            tapCardLikeRepository.insertIfAbsent(
                    UUID.randomUUID(), cardId, newOwner(), OffsetDateTime.now(ZoneOffset.UTC)
            );
        }
    }

    @Test
    void successLeaderboardIncludesEligibleSuccessCardsRankedByLikeCount() {
        UUID ownerA = newOwner();
        UUID ownerB = newOwner();
        UUID lowCard = createEligibleCard(ownerA, ActivityChallengerFinalVerdict.SUCCESS, 0);
        UUID highCard = createEligibleCard(ownerB, ActivityChallengerFinalVerdict.SUCCESS, 0);
        likeCard(highCard, 3);
        likeCard(lowCard, 1);

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        assertTrue(rows.size() >= 2);
        int highIndex = indexOfCard(rows, highCard);
        int lowIndex = indexOfCard(rows, lowCard);
        assertTrue(highIndex < lowIndex, "card with more likes should rank higher");
        assertEquals(1L, rows.get(highIndex).getRank());
        assertEquals("SUCCESS", rows.get(highIndex).getResult());
    }

    @Test
    void leaderboardRowExposesTheFullResponseProjection() {
        UUID owner = newOwner();
        UUID cardId = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 250);
        likeCard(cardId, 2);

        TapCardLeaderboardRow row = tapCardRepository.findLeaderboard("SUCCESS", 30).stream()
                .filter(r -> r.getCardId().equals(cardId))
                .findFirst()
                .orElseThrow();

        assertEquals(1L, row.getRank());
        assertEquals(cardId, row.getCardId());
        assertEquals(owner, row.getOwnerUserId());
        assertEquals("SUCCESS", row.getResult());
        assertEquals("note", row.getNote());
        assertEquals(2L, row.getLikeCount());
        assertEquals(0L, row.getReplyCount());
        assertEquals(250, row.getFailCardFeeMinor());
        // score = likeCount*10 + replyCount*18 + min(failCardFeeMinor/100, 100)*2
        //       = 2*10 + 0*18 + min(2.5, 100)*2 = 20 + 5 = 25
        assertEquals(25.0, row.getScore());
        assertTrue(row.getCardCreatedAt() != null);
        assertTrue(row.getCardUpdatedAt() != null);
        assertTrue(row.getCompletedAt() != null);
        assertTrue(row.getRankSortAt() != null);
        assertTrue(row.getTapId() != null);
        assertTrue(row.getActivityInstanceId() != null);
        assertTrue(row.getActivityTemplateId() != null);
    }

    @Test
    void leaderboardRowIncludesOwnerProfileFieldsWhenAProfileExists() {
        UUID owner = newOwner();
        addProfile(owner, "runner99", "Runner", "https://example.com/avatar.png");
        UUID cardId = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 0);

        TapCardLeaderboardRow row = tapCardRepository.findLeaderboard("SUCCESS", 30).stream()
                .filter(r -> r.getCardId().equals(cardId))
                .findFirst()
                .orElseThrow();

        assertEquals("runner99", row.getOwnerHandle());
        assertEquals("Runner", row.getOwnerNickname());
        assertEquals("https://example.com/avatar.png", row.getOwnerAvatarUrl());
    }

    @Test
    void leaderboardRowHasNullProfileFieldsWhenNoProfileExists() {
        UUID owner = newOwner();
        UUID cardId = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 0);

        TapCardLeaderboardRow row = tapCardRepository.findLeaderboard("SUCCESS", 30).stream()
                .filter(r -> r.getCardId().equals(cardId))
                .findFirst()
                .orElseThrow();

        assertEquals(null, row.getOwnerHandle());
        assertEquals(null, row.getOwnerNickname());
        assertEquals(null, row.getOwnerAvatarUrl());
    }

    @Test
    void replyCountOnlyCountsVisibleNonDeletedReplies() {
        UUID owner = newOwner();
        UUID cardId = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 0);
        UUID replier = newOwner();

        addReply(cardId, replier, "VISIBLE", false);
        addReply(cardId, replier, "VISIBLE", false);
        addReply(cardId, replier, "HIDDEN", false);
        addReply(cardId, replier, "VISIBLE", true);
        entityManager.flush();

        TapCardLeaderboardRow row = tapCardRepository.findLeaderboard("SUCCESS", 30).stream()
                .filter(r -> r.getCardId().equals(cardId))
                .findFirst()
                .orElseThrow();

        assertEquals(2L, row.getReplyCount());
    }

    @Test
    void failLeaderboardIsSeparateFromSuccessLeaderboard() {
        UUID ownerA = newOwner();
        UUID ownerB = newOwner();
        UUID successCard = createEligibleCard(ownerA, ActivityChallengerFinalVerdict.SUCCESS, 0);
        UUID failCard = createEligibleCard(ownerB, ActivityChallengerFinalVerdict.FAIL, 500);

        List<TapCardLeaderboardRow> failRows = tapCardRepository.findLeaderboard("FAIL", 30);
        List<TapCardLeaderboardRow> successRows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        assertTrue(failRows.stream().anyMatch(r -> r.getCardId().equals(failCard)));
        assertTrue(failRows.stream().noneMatch(r -> r.getCardId().equals(successCard)));
        assertTrue(successRows.stream().anyMatch(r -> r.getCardId().equals(successCard)));
        assertTrue(successRows.stream().noneMatch(r -> r.getCardId().equals(failCard)));
    }

    @Test
    void excludesDisputedAndChickenChallengerOutcomes() {
        UUID ownerDispute = newOwner();
        UUID ownerChicken = newOwner();
        UUID disputeCard = createEligibleCard(ownerDispute, ActivityChallengerFinalVerdict.DISPUTE, 0);
        UUID chickenCard = createEligibleCard(ownerChicken, ActivityChallengerFinalVerdict.CHICKEN, 0);

        List<TapCardLeaderboardRow> successRows = tapCardRepository.findLeaderboard("SUCCESS", 30);
        List<TapCardLeaderboardRow> failRows = tapCardRepository.findLeaderboard("FAIL", 30);

        assertTrue(successRows.stream().noneMatch(r -> r.getCardId().equals(disputeCard) || r.getCardId().equals(chickenCard)));
        assertTrue(failRows.stream().noneMatch(r -> r.getCardId().equals(disputeCard) || r.getCardId().equals(chickenCard)));
    }

    @Test
    void excludesNonPublishedOrPrivateTemplates() {
        UUID draftOwner = newOwner();
        UUID privateOwner = newOwner();
        UUID draftCard = createCard(
                draftOwner, ActivityChallengerFinalVerdict.SUCCESS,
                TemplateVisibility.PUBLIC, TemplateLifecycleState.DRAFT, true, 0
        );
        UUID privateCard = createCard(
                privateOwner, ActivityChallengerFinalVerdict.SUCCESS,
                TemplateVisibility.PRIVATE, TemplateLifecycleState.PUBLISHED, true, 0
        );

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        assertTrue(rows.stream().noneMatch(r -> r.getCardId().equals(draftCard)));
        assertTrue(rows.stream().noneMatch(r -> r.getCardId().equals(privateCard)));
    }

    @Test
    void excludesInstancesThatAreNotCompleted() {
        UUID owner = newOwner();
        UUID activeCard = createCard(
                owner, ActivityChallengerFinalVerdict.SUCCESS,
                TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, false, 0
        );

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        assertTrue(rows.stream().noneMatch(r -> r.getCardId().equals(activeCard)));
    }

    @Test
    void onlyBestCardPerOwnerAppearsOnTheLeaderboard() {
        UUID owner = newOwner();
        UUID weakerCard = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 0);
        UUID strongerCard = createEligibleCard(owner, ActivityChallengerFinalVerdict.SUCCESS, 0);
        likeCard(strongerCard, 5);

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        long ownerRowCount = rows.stream().filter(r -> r.getOwnerUserId().equals(owner)).count();
        assertEquals(1, ownerRowCount);
        assertTrue(rows.stream().anyMatch(r -> r.getCardId().equals(strongerCard)));
        assertTrue(rows.stream().noneMatch(r -> r.getCardId().equals(weakerCard)));
    }

    @Test
    void tiedCardsBreakDeterministicallyByCardId() {
        UUID ownerA = newOwner();
        UUID ownerB = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        UUID cardA = createEligibleCard(ownerA, ActivityChallengerFinalVerdict.SUCCESS, 0, now);
        UUID cardB = createEligibleCard(ownerB, ActivityChallengerFinalVerdict.SUCCESS, 0, now);

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 30);

        // Postgres orders uuid values byte-wise, which matches String comparison of the
        // canonical form but not java.util.UUID#compareTo (signed long comparison).
        UUID expectedFirst = cardA.toString().compareTo(cardB.toString()) <= 0 ? cardA : cardB;
        UUID expectedSecond = expectedFirst.equals(cardA) ? cardB : cardA;
        int firstIndex = indexOfCard(rows, expectedFirst);
        int secondIndex = indexOfCard(rows, expectedSecond);

        assertTrue(firstIndex < secondIndex);
    }

    @Test
    void respectsTheRequestedLimit() {
        List<UUID> cardIds = IntStream.range(0, 3)
                .mapToObj(i -> createEligibleCard(newOwner(), ActivityChallengerFinalVerdict.SUCCESS, 0))
                .toList();

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("SUCCESS", 2);

        assertEquals(2, rows.size());
    }

    @Test
    void returnsEmptyWhenNoCardsMatchTheRequestedResult() {
        createEligibleCard(newOwner(), ActivityChallengerFinalVerdict.SUCCESS, 0);

        List<TapCardLeaderboardRow> rows = tapCardRepository.findLeaderboard("FAIL", 30);

        assertTrue(rows.isEmpty());
    }

    private int indexOfCard(List<TapCardLeaderboardRow> rows, UUID cardId) {
        for (int i = 0; i < rows.size(); i++) {
            if (rows.get(i).getCardId().equals(cardId)) {
                return i;
            }
        }
        throw new AssertionError("card not found in leaderboard rows: " + cardId);
    }
}
