package games.tapped.play.notification;

public record MailDeliveryResult(
        boolean success,
        String providerMessageId,
        Integer providerStatus,
        String errorMessage
) {
    public static MailDeliveryResult success(String providerMessageId) {
        return new MailDeliveryResult(true, providerMessageId, null, null);
    }

    public static MailDeliveryResult failure(Integer providerStatus, String errorMessage) {
        return new MailDeliveryResult(false, null, providerStatus, errorMessage);
    }
}
