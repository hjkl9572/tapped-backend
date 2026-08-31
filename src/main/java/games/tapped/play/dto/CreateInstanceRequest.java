package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.Set;
import java.util.UUID;

public record CreateInstanceRequest(
        @NotNull
        UUID activityTemplateId,

        @NotBlank
        @Email
        String refEmail,

        @NotNull
        Integer amountCents,

        TemplatePlayContext playContext,

        TemplateRelationshipMode relationshipMode,

        @JsonProperty("idempotency_key")
        @JsonAlias("idempotencyKey")
        @NotNull
        UUID idempotencyKey,

        @Valid
        TemplateScheduleRequest schedule
) {
    private static final Set<Integer> ALLOWED_AMOUNTS =
            Set.of(0, 500, 2500, 5000, 10000);

    @AssertTrue(message = "amountCents must be one of the supported challenge amounts")
    public boolean isAmountCentsSupported() {
        return amountCents == null || ALLOWED_AMOUNTS.contains(amountCents);
    }
}
