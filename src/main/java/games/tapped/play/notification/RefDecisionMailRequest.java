package games.tapped.play.notification;

public record RefDecisionMailRequest(
        String refEmail,
        String title,
        String contents,
        String finalCallUrl,
        int expiresInHours
) {
}
