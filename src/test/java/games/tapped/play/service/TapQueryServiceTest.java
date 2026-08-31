package games.tapped.play.service;

import games.tapped.play.dto.TapCountPeriod;
import games.tapped.play.dto.TapCountResponse;
import games.tapped.play.repository.ActivityTapRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Duration;
import java.time.OffsetDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class TapQueryServiceTest {

    @Mock
    ActivityTapRepository tapRepository;

    @InjectMocks
    TapQueryService service;

    @Test
    void countsWeeklyTapsUsingSevenDayWindowEndingNow() {
        given(tapRepository.countFinalizedBetween(any(), any())).willReturn(42L);

        TapCountResponse response = service.countTaps(TapCountPeriod.WEEK);

        assertEquals(42L, response.count());

        ArgumentCaptor<OffsetDateTime> startCaptor = ArgumentCaptor.forClass(OffsetDateTime.class);
        ArgumentCaptor<OffsetDateTime> endCaptor = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(tapRepository)
                .countFinalizedBetween(startCaptor.capture(), endCaptor.capture());

        Duration window = Duration.between(startCaptor.getValue(), endCaptor.getValue());
        assertEquals(Duration.ofDays(7), window);
    }

    @Test
    void returnsZeroWhenNoTapsExistInWindow() {
        given(tapRepository.countFinalizedBetween(any(), any())).willReturn(0L);

        TapCountResponse response = service.countTaps(TapCountPeriod.WEEK);

        assertEquals(0L, response.count());
    }
}
