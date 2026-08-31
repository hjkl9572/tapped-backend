package games.tapped.play.controller;

import games.tapped.play.dto.TapCountPeriod;
import games.tapped.play.dto.TapCountResponse;
import games.tapped.play.service.TapQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/taps")
@RequiredArgsConstructor
public class TapController {

    private final TapQueryService service;

    @GetMapping("/count")
    public TapCountResponse getCount(@RequestParam String period) {
        return service.countTaps(TapCountPeriod.fromApiValue(period));
    }
}
