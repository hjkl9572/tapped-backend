package games.tapped.play.controller;

import games.tapped.common.exception.DomainConflictException;
import games.tapped.play.dto.ChallengeFinalCallResponse;
import games.tapped.play.dto.ChallengeProcessStatus;
import games.tapped.play.dto.ChallengerDecisionRequest;
import games.tapped.play.dto.ChallengerDecisionResponse;
import games.tapped.play.dto.CoverCardRequest;
import games.tapped.play.dto.CoverCardResponse;
import games.tapped.play.dto.CreateInstanceRequest;
import games.tapped.play.dto.CreateInstanceResponse;
import games.tapped.play.dto.CreateTapCardRequest;
import games.tapped.play.dto.InstanceDashboardResponse;
import games.tapped.play.dto.PlayInstanceSummaryResponse;
import games.tapped.play.dto.RefDecisionErrorResponse;
import games.tapped.play.dto.RefDecisionRequest;
import games.tapped.play.dto.RefDecisionSessionResponse;
import games.tapped.play.dto.RefDecisionSuccessResponse;
import games.tapped.play.dto.RefNotificationResponse;
import games.tapped.play.dto.TapCardResponse;
import games.tapped.play.dto.TapResponse;
import games.tapped.play.dto.ToggleTapResponse;
import games.tapped.play.service.ActivityInstanceService;
import games.tapped.security.AppJwtPrincipal;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@RestController
@RequestMapping("/api/instances")
@RequiredArgsConstructor
public class InstanceController {

    private final ActivityInstanceService service;

    @PostMapping
    public ResponseEntity<CreateInstanceResponse> create(
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody CreateInstanceRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(service.create(principal.userId(), request));
    }

    @GetMapping("/dashboard")
    public InstanceDashboardResponse dashboard(
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return service.getDashboard(principal.userId());
    }

    @GetMapping("/{id}")
    public PlayInstanceSummaryResponse get(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return service.get(principal.userId(), id);
    }

    @PostMapping("/{id}/taps")
    public ToggleTapResponse toggleTap(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return service.toggleTap(principal.userId(), id);
    }

    @GetMapping("/{id}/taps/{tapId}")
    public TapResponse getTap(
            @PathVariable UUID id,
            @PathVariable UUID tapId,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return service.getTap(principal.userId(), id, tapId);
    }

    @PostMapping("/{id}/taps/{tapId}/cards")
    public TapCardResponse createTapCard(
            @PathVariable UUID id,
            @PathVariable UUID tapId,
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody CreateTapCardRequest request
    ) {
        return service.createTapCard(
                principal.userId(),
                id,
                tapId,
                request
        );
    }

    @PostMapping("/{id}/challenge/challenger-decision")
    public ChallengerDecisionResponse submitChallengerDecision(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody ChallengerDecisionRequest request
    ) {
        return service.submitChallengerDecision(
                principal.userId(),
                id,
                request
        );
    }

    @PutMapping("/{id}/cover-card")
    public CoverCardResponse setCoverCard(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal,
            @Valid @RequestBody CoverCardRequest request
    ) {
        return service.setCoverCard(
                principal.userId(),
                id,
                request.coverCardId()
        );
    }

    @GetMapping("/{id}/challenge/final-call")
    public ChallengeFinalCallResponse getFinalCall(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return service.getFinalCall(principal.userId(), id);
    }

    @PostMapping("/{id}/challenge/notifications")
    public RefNotificationResponse prepareRefNotification(
            @PathVariable UUID id,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        service.prepareRefNotification(principal.userId(), id);
        return new RefNotificationResponse(
                true,
                ChallengeProcessStatus.WAITING_FOR_REF_DECISION.name()
        );
    }

    @PostMapping("/{id}/challenge/payment/checkout")
    public ResponseEntity<Void> createPaymentCheckout(@PathVariable UUID id) {
        throw new ResponseStatusException(
                HttpStatus.NOT_IMPLEMENTED,
                "Challenge payment checkout requires the Payment provider migration"
        );
    }

    @GetMapping("/ref-decisions/session")
    public ResponseEntity<?> getRefDecisionSession(@RequestParam String token) {
        try {
            RefDecisionSessionResponse response =
                    service.getRefDecisionSession(token);
            return ResponseEntity.ok(response);
        } catch (EntityNotFoundException exception) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(new RefDecisionErrorResponse(
                            false,
                            "INVALID_TOKEN",
                            buildVerifyUrl("invalid_token", null),
                            null
                    ));
        } catch (DomainConflictException exception) {
            return ResponseEntity
                    .status(HttpStatus.GONE)
                    .body(new RefDecisionErrorResponse(
                            false,
                            "EXPIRED_TOKEN",
                            buildVerifyUrl("expired", token),
                            null
                    ));
        }
    }

    @PostMapping("/ref-decisions")
    public ResponseEntity<?> submitRefDecision(
            @Valid @RequestBody RefDecisionRequest request
    ) {
        ActivityInstanceService.RefDecisionResult result =
                service.submitRefDecision(request);

        if (result.ok()) {
            return ResponseEntity.ok(new RefDecisionSuccessResponse(
                    true,
                    result.activityInstanceId(),
                    result.nextStatus(),
                    buildResultUrl(result.activityInstanceId(), result.nextStatus())
            ));
        }

        HttpStatus status = switch (result.code()) {
            case "INVALID_TOKEN" -> HttpStatus.NOT_FOUND;
            case "INVALID_ACTION" -> HttpStatus.BAD_REQUEST;
            case "EXPIRED_TOKEN" -> HttpStatus.GONE;
            case "ALREADY_USED", "ALREADY_DECIDED" -> HttpStatus.CONFLICT;
            default -> HttpStatus.INTERNAL_SERVER_ERROR;
        };

        return ResponseEntity
                .status(status)
                .body(new RefDecisionErrorResponse(
                        false,
                        result.code(),
                        buildRefDecisionRedirect(result),
                        result.activityInstanceId()
                ));
    }

    private String buildRefDecisionRedirect(
            ActivityInstanceService.RefDecisionResult result
    ) {
        if ("ALREADY_USED".equals(result.code())) {
            return result.activityInstanceId() == null
                    ? buildVerifyUrl("already_processed", null)
                    : buildResultUrl(result.activityInstanceId(), "already_processed");
        }
        if ("ALREADY_DECIDED".equals(result.code())) {
            return result.activityInstanceId() == null
                    ? buildVerifyUrl("already_decided", null)
                    : buildResultUrl(result.activityInstanceId(), "already_decided");
        }
        if ("EXPIRED_TOKEN".equals(result.code())) {
            return buildVerifyUrl("expired", null);
        }
        if ("INVALID_ACTION".equals(result.code())) {
            return buildVerifyUrl("invalid_action", null);
        }
        if ("INVALID_TOKEN".equals(result.code())) {
            return buildVerifyUrl("invalid_token", null);
        }
        return buildVerifyUrl("server_error", null);
    }

    private String buildVerifyUrl(String result, String token) {
        String url = "/play/challenge/ref-decision/verify?result=" + result;
        return token == null || token.isBlank()
                ? url
                : url + "&token=" + token;
    }

    private String buildResultUrl(UUID activityInstanceId, String status) {
        return "/play/challenge/ref-decision/result/"
                + activityInstanceId
                + "?status="
                + status;
    }
}
