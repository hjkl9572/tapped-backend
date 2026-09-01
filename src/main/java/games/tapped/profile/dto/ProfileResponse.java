package games.tapped.profile.dto;

import java.util.UUID;

public record ProfileResponse(
        UUID userId,
        String handle,
        String nickname,
        String introduction,
        String avatarUrl
) {
}
