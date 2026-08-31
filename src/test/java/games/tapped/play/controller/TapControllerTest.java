package games.tapped.play.controller;

import games.tapped.play.dto.TapCountPeriod;
import games.tapped.play.dto.TapCountResponse;
import games.tapped.play.service.TapQueryService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class TapControllerTest {

    @Autowired
    MockMvc mockMvc;

    @MockitoBean
    TapQueryService tapQueryService;

    @Test
    void anonymousUserCanGetWeeklyTapCount() throws Exception {
        given(tapQueryService.countTaps(TapCountPeriod.WEEK))
                .willReturn(new TapCountResponse(1234));

        mockMvc.perform(get("/api/taps/count").param("period", "week"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(1234));
    }

    @Test
    void periodValueIsCaseInsensitive() throws Exception {
        given(tapQueryService.countTaps(TapCountPeriod.WEEK))
                .willReturn(new TapCountResponse(0));

        mockMvc.perform(get("/api/taps/count").param("period", "WEEK"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));
    }

    @Test
    void unsupportedPeriodReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/taps/count").param("period", "month"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void malformedPeriodReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/taps/count").param("period", "!!!"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void missingPeriodReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/api/taps/count"))
                .andExpect(status().isBadRequest());
    }
}
