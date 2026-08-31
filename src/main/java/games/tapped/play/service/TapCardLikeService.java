package games.tapped.play.service;

import games.tapped.play.dto.TapCardLikeResponse;
import games.tapped.play.repository.TapCardLikeRepository;
import games.tapped.play.repository.TapCardRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TapCardLikeService {

    private final TapCardRepository tapCardRepository;
    private final TapCardLikeRepository tapCardLikeRepository;
    private final Clock clock = Clock.systemUTC();

    @Transactional
    public TapCardLikeResponse like(UUID cardId, UUID userId) {
        requireExistingCard(cardId);

        tapCardLikeRepository.insertIfAbsent(
                UUID.randomUUID(),
                cardId,
                userId,
                OffsetDateTime.now(clock)
        );

        return new TapCardLikeResponse(
                cardId,
                tapCardLikeRepository.countByTapCardId(cardId),
                true
        );
    }

    @Transactional
    public TapCardLikeResponse unlike(UUID cardId, UUID userId) {
        requireExistingCard(cardId);

        tapCardLikeRepository.deleteByTapCardIdAndUserId(cardId, userId);

        return new TapCardLikeResponse(
                cardId,
                tapCardLikeRepository.countByTapCardId(cardId),
                false
        );
    }

    private void requireExistingCard(UUID cardId) {
        tapCardRepository.findByIdAndDeletedAtIsNull(cardId)
                .orElseThrow(() -> new EntityNotFoundException("Tap card not found"));
    }
}
