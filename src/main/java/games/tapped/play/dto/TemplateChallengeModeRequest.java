package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.PositiveOrZero;

public record TemplateChallengeModeRequest(
        String currency,

        @JsonProperty("ref_email")
        @JsonAlias("refEmail")
        @Email
        String refEmail,

        @JsonProperty("fail_card_fee_minor")
        @JsonAlias({"failCardFeeMinor", "amountCents"})
        @PositiveOrZero
        Integer failCardFeeMinor,

        @JsonProperty("ref_required")
        @JsonAlias("refRequired")
        Boolean refRequired
) {
}
