package games.tapped.play.service;

import games.tapped.play.dto.TapCountPeriod;
import games.tapped.play.dto.TapCountResponse;
import games.tapped.play.repository.ActivityTapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
public class TapQueryService {

    private static final Duration WEEKLY_WINDOW = Duration.ofDays(7);

    private final ActivityTapRepository tapRepository;
    private final Clock clock = Clock.systemUTC();

    @Transactional(readOnly = true)
    public TapCountResponse countTaps(TapCountPeriod period) {
        return switch (period) {
            case WEEK -> countWeeklyTaps();
        };
    }

    private TapCountResponse countWeeklyTaps() {
        OffsetDateTime windowEnd = OffsetDateTime.now(clock);
        OffsetDateTime windowStart = windowEnd.minus(WEEKLY_WINDOW);

        return new TapCountResponse(
                tapRepository.countFinalizedBetween(windowStart, windowEnd)
        );
    }
}
