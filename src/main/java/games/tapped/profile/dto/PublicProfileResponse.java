package games.tapped.profile.dto;

public record PublicProfileResponse(
        String handle,
        String nickname,
        String introduction,
        String avatarUrl
) {
}
