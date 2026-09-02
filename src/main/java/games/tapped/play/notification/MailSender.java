package games.tapped.play.notification;

public interface MailSender {
    MailDeliveryResult sendRefDecisionRequest(RefDecisionMailRequest request);
}
