package games.tapped.play.service;

import games.tapped.play.dto.TapCardLikeResponse;
import games.tapped.play.entity.TapCard;
import games.tapped.play.repository.TapCardLikeRepository;
import games.tapped.play.repository.TapCardRepository;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class TapCardLikeServiceTest {

    @Mock
    TapCardRepository tapCardRepository;

    @Mock
    TapCardLikeRepository tapCardLikeRepository;

    @InjectMocks
    TapCardLikeService service;

    private TapCard existingCard(UUID cardId) {
        return TapCard.create(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                1,
                1,
                null,
                null,
                OffsetDateTime.now(ZoneOffset.UTC)
        );
    }

    @Test
    void likeInsertsAndReturnsUpdatedCount() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.of(existingCard(cardId)));
        given(tapCardLikeRepository.countByTapCardId(cardId)).willReturn(3L);

        TapCardLikeResponse response = service.like(cardId, userId);

        assertEquals(cardId, response.cardId());
        assertEquals(3L, response.likeCount());
        assertEquals(true, response.liked());

        verify(tapCardLikeRepository).insertIfAbsent(any(), eq(cardId), eq(userId), any());
    }

    @Test
    void likeUsesOnlyThePassedUserIdRegardlessOfOtherInput() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.of(existingCard(cardId)));
        given(tapCardLikeRepository.countByTapCardId(cardId)).willReturn(1L);

        service.like(cardId, userId);

        verify(tapCardLikeRepository).insertIfAbsent(any(), eq(cardId), eq(userId), any());
    }

    @Test
    void repeatedLikeStaysIdempotentAtStorageLevel() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.of(existingCard(cardId)));
        given(tapCardLikeRepository.countByTapCardId(cardId)).willReturn(1L);

        service.like(cardId, userId);
        TapCardLikeResponse second = service.like(cardId, userId);

        assertEquals(true, second.liked());
        assertEquals(1L, second.likeCount());
    }

    @Test
    void likeNonexistentCardThrowsNotFound() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class, () -> service.like(cardId, userId));
        verify(tapCardLikeRepository, never()).insertIfAbsent(any(), any(), any(), any());
    }

    @Test
    void unlikeDeletesAndReturnsUpdatedCount() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.of(existingCard(cardId)));
        given(tapCardLikeRepository.countByTapCardId(cardId)).willReturn(0L);

        TapCardLikeResponse response = service.unlike(cardId, userId);

        assertEquals(false, response.liked());
        assertEquals(0L, response.likeCount());
        verify(tapCardLikeRepository).deleteByTapCardIdAndUserId(cardId, userId);
    }

    @Test
    void repeatedUnlikeStaysIdempotent() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.of(existingCard(cardId)));
        given(tapCardLikeRepository.countByTapCardId(cardId)).willReturn(0L);

        service.unlike(cardId, userId);
        TapCardLikeResponse second = service.unlike(cardId, userId);

        assertEquals(false, second.liked());
        assertEquals(0L, second.likeCount());
    }

    @Test
    void unlikeNonexistentCardThrowsNotFound() {
        UUID userId = UUID.randomUUID();
        UUID cardId = UUID.randomUUID();

        given(tapCardRepository.findByIdAndDeletedAtIsNull(cardId))
                .willReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class, () -> service.unlike(cardId, userId));
        verify(tapCardLikeRepository, never()).deleteByTapCardIdAndUserId(any(), any());
    }
}
