package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

public record CreateInstanceResponse(
        @JsonProperty("play_instance_id")
        UUID playInstanceId,

        @JsonProperty("sequence_no")
        int sequenceNo,

        @JsonProperty("template_id")
        UUID templateId
) {
}
