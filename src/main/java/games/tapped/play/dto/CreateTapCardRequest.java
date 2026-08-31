package games.tapped.play.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Size;

public record CreateTapCardRequest(
        @JsonAlias("episode")
        @Size(max = 2000)
        String note,

        @JsonProperty("photo_path")
        @JsonAlias({"photoPath", "photoUrl"})
        String photoPath,

        Boolean removePhoto
) {
}
