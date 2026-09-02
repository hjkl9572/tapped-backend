package games.tapped.play.notification;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.Map;

@Component
public class ResendMailSender implements MailSender {

    private static final JsonMapper MAPPER = JsonMapper.builder().build();
    private static final URI RESEND_ENDPOINT = URI.create("https://api.resend.com/emails");

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final String apiKey;
    private final String fromAddress;
    private final String subjectPrefix;

    public ResendMailSender(
            @Value("${spring.resend.api-key}") String apiKey,
            @Value("${spring.resend.from-address}") String fromAddress,
            @Value("${spring.resend.subject-prefix}") String subjectPrefix
    ) {
        this.apiKey = apiKey;
        this.fromAddress = fromAddress;
        this.subjectPrefix = subjectPrefix;
    }

    @Override
    public MailDeliveryResult sendRefDecisionRequest(RefDecisionMailRequest request) {
        String html = RefDecisionEmailTemplate.render(
                request.title(),
                request.contents(),
                request.finalCallUrl(),
                request.expiresInHours()
        );

        String body = MAPPER.writeValueAsString(Map.of(
                "from", fromAddress,
                "to", List.of(request.refEmail()),
                "subject", RefDecisionEmailTemplate.subject(subjectPrefix),
                "html", html
        ));

        HttpRequest httpRequest = HttpRequest.newBuilder(RESEND_ENDPOINT)
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        HttpResponse<String> response;
        try {
            response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
        } catch (IOException exception) {
            return MailDeliveryResult.failure(null, exception.getMessage());
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            return MailDeliveryResult.failure(null, exception.getMessage());
        }

        JsonNode responseBody = MAPPER.readTree(response.body());

        if (response.statusCode() / 100 != 2) {
            String message = responseBody.path("message").asString(response.body());
            return MailDeliveryResult.failure(response.statusCode(), message);
        }

        return MailDeliveryResult.success(responseBody.path("id").asString(null));
    }
}
