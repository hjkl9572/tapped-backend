package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.AppUserService;
import games.tapped.play.entity.TapCard;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@Transactional
class TapCardLikeRepositoryTest {

    @Autowired
    AppUserService appUserService;

    @Autowired
    ActivityTemplateRepository templateRepository;

    @Autowired
    ActivityInstanceRepository instanceRepository;

    @Autowired
    ActivityTapRepository tapRepository;

    @Autowired
    TapCardRepository tapCardRepository;

    @Autowired
    TapCardLikeRepository tapCardLikeRepository;

    private UUID newUser() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    private UUID newTapCard() {
        UUID owner = newUser();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);

        ActivityTemplate template = ActivityTemplate.createRoot(owner, "Run every day", "Rules");
        templateRepository.saveAndFlush(template);

        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(), owner, TemplatePlayContext.ONLINE,
                TemplateRelationshipMode.SOLO, UUID.randomUUID().toString(), 1, null, now
        );
        instanceRepository.saveAndFlush(instance);

        ActivityTap tap = ActivityTap.open(instance.getId(), owner, 1, now);
        tapRepository.saveAndFlush(tap);

        TapCard card = TapCard.create(instance.getId(), tap.getId(), owner, 1, 1, null, null, now);
        tapCardRepository.saveAndFlush(card);

        return card.getId();
    }

    @Test
    void insertIfAbsentDoesNotCreateDuplicateRowsForTheSameUserAndCard() {
        UUID cardId = newTapCard();
        UUID userId = newUser();

        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), cardId, userId, OffsetDateTime.now(ZoneOffset.UTC));
        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), cardId, userId, OffsetDateTime.now(ZoneOffset.UTC));

        assertEquals(1L, tapCardLikeRepository.countByTapCardId(cardId));
    }

    @Test
    void deleteByTapCardIdAndUserIdIsIdempotent() {
        UUID cardId = newTapCard();
        UUID userId = newUser();
        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), cardId, userId, OffsetDateTime.now(ZoneOffset.UTC));

        tapCardLikeRepository.deleteByTapCardIdAndUserId(cardId, userId);
        tapCardLikeRepository.deleteByTapCardIdAndUserId(cardId, userId);

        assertEquals(0L, tapCardLikeRepository.countByTapCardId(cardId));
    }

    @Test
    void countByCardIdsReturnsRowsOnlyForCardsWithLikes() {
        UUID likedCard = newTapCard();
        UUID unlikedCard = newTapCard();
        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), likedCard, newUser(), OffsetDateTime.now(ZoneOffset.UTC));
        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), likedCard, newUser(), OffsetDateTime.now(ZoneOffset.UTC));

        List<TapCardLikeCountRow> rows = tapCardLikeRepository.countByCardIds(List.of(likedCard, unlikedCard));

        assertEquals(1, rows.size());
        assertEquals(likedCard, rows.get(0).getTapCardId());
        assertEquals(2L, rows.get(0).getLikeCount());
    }

    @Test
    void findLikedCardIdsReturnsOnlyCardsLikedByTheGivenUser() {
        UUID cardId = newTapCard();
        UUID liker = newUser();
        UUID otherUser = newUser();
        tapCardLikeRepository.insertIfAbsent(UUID.randomUUID(), cardId, liker, OffsetDateTime.now(ZoneOffset.UTC));

        List<UUID> likedByLiker = tapCardLikeRepository.findLikedCardIds(List.of(cardId), liker);
        List<UUID> likedByOther = tapCardLikeRepository.findLikedCardIds(List.of(cardId), otherUser);

        assertTrue(likedByLiker.contains(cardId));
        assertFalse(likedByOther.contains(cardId));
    }
}
