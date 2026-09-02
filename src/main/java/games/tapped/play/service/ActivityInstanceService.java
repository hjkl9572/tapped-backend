package games.tapped.play.service;

import games.tapped.common.exception.DomainConflictException;
import games.tapped.common.exception.MailDeliveryException;
import games.tapped.common.exception.UnprocessableOperationException;
import games.tapped.play.dto.ChallengeFinalCallResponse;
import games.tapped.play.dto.ChallengeProcessStatus;
import games.tapped.play.dto.ChallengerDecisionRequest;
import games.tapped.play.dto.ChallengerDecisionResponse;
import games.tapped.play.dto.ChallengerDecisionType;
import games.tapped.play.dto.CoverCardResponse;
import games.tapped.play.dto.CreateInstanceRequest;
import games.tapped.play.dto.CreateInstanceResponse;
import games.tapped.play.dto.CreateTapCardRequest;
import games.tapped.play.dto.InstanceDashboardItem;
import games.tapped.play.dto.InstanceDashboardResponse;
import games.tapped.play.dto.PlayInstanceSummary;
import games.tapped.play.dto.PlayInstanceSummaryResponse;
import games.tapped.play.dto.PlayInstanceTemplateSummary;
import games.tapped.play.dto.RefDecisionRequest;
import games.tapped.play.dto.RefDecisionVerdict;
import games.tapped.play.dto.RefDecisionSessionResponse;
import games.tapped.play.dto.TapCardData;
import games.tapped.play.dto.TapCardResponse;
import games.tapped.play.dto.TapDetail;
import games.tapped.play.dto.TapResponse;
import games.tapped.play.dto.TapSummary;
import games.tapped.play.dto.ToggleTapData;
import games.tapped.play.dto.ToggleTapResponse;
import games.tapped.play.entity.ActivityChallengerFinalVerdict;
import games.tapped.play.entity.ActivityInstance;
import games.tapped.play.entity.ActivityInstanceChallengeConfig;
import games.tapped.play.entity.ActivityInstanceChallengeDispute;
import games.tapped.play.entity.ActivityInstanceChallengeEvent;
import games.tapped.play.entity.ActivityInstanceChallengeMailToken;
import games.tapped.play.entity.ActivityInstanceState;
import games.tapped.play.entity.ActivityModeKind;
import games.tapped.play.entity.ActivityRefState;
import games.tapped.play.entity.ActivityRefVerdict;
import games.tapped.play.entity.ActivityTap;
import games.tapped.play.entity.ActivityTapState;
import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.ChallengeEventType;
import games.tapped.play.entity.TapCard;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplatePlayContext;
import games.tapped.play.entity.TemplateRelationshipMode;
import games.tapped.play.entity.TemplateVisibility;
import games.tapped.play.notification.MailDeliveryResult;
import games.tapped.play.notification.MailSender;
import games.tapped.play.notification.RefDecisionMailRequest;
import games.tapped.play.repository.ActivityInstanceChallengeConfigRepository;
import games.tapped.play.repository.ActivityInstanceChallengeDisputeRepository;
import games.tapped.play.repository.ActivityInstanceChallengeEventRepository;
import games.tapped.play.repository.ActivityInstanceChallengeMailTokenRepository;
import games.tapped.play.repository.ActivityInstanceRepository;
import games.tapped.play.repository.ActivityTapRepository;
import games.tapped.play.repository.ActivityTemplateRepository;
import games.tapped.play.repository.InstanceDashboardRow;
import games.tapped.play.repository.TapCardRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

@Service
public class ActivityInstanceService {

    private static final ZoneId TAP_DAY_ZONE = ZoneId.of("America/New_York");
    private static final Set<ChallengeEventType> TERMINAL_EVENTS = Set.of(
            ChallengeEventType.CHALLENGER_FINALIZED_SUCCESS,
            ChallengeEventType.CHALLENGER_FINALIZED_FAIL,
            ChallengeEventType.CHALLENGER_FINALIZED_CHICKEN,
            ChallengeEventType.CHALLENGER_FINALIZED_DISAGREE
    );
    private static final Set<ChallengeEventType> REF_DECISION_EVENTS = Set.of(
            ChallengeEventType.REF_DECISION_SUCCESS,
            ChallengeEventType.REF_DECISION_FAIL
    );

    private static final SecureRandom TOKEN_RANDOM = new SecureRandom();
    private static final int REF_ACCESS_TOKEN_EXPIRY_HOURS = 48;

    private final ActivityInstanceRepository instanceRepository;
    private final ActivityTemplateRepository templateRepository;
    private final ActivityInstanceChallengeConfigRepository challengeConfigRepository;
    private final ActivityTapRepository tapRepository;
    private final TapCardRepository tapCardRepository;
    private final ActivityInstanceChallengeEventRepository challengeEventRepository;
    private final ActivityInstanceChallengeDisputeRepository disputeRepository;
    private final ActivityInstanceChallengeMailTokenRepository mailTokenRepository;
    private final MailSender mailSender;
    private final ChallengeEventRecorder eventRecorder;
    private final String appBaseUrl;
    private final Clock clock = Clock.systemUTC();

    public ActivityInstanceService(
            ActivityInstanceRepository instanceRepository,
            ActivityTemplateRepository templateRepository,
            ActivityInstanceChallengeConfigRepository challengeConfigRepository,
            ActivityTapRepository tapRepository,
            TapCardRepository tapCardRepository,
            ActivityInstanceChallengeEventRepository challengeEventRepository,
            ActivityInstanceChallengeDisputeRepository disputeRepository,
            ActivityInstanceChallengeMailTokenRepository mailTokenRepository,
            MailSender mailSender,
            ChallengeEventRecorder eventRecorder,
            @Value("${spring.app.base-url}") String appBaseUrl
    ) {
        this.instanceRepository = instanceRepository;
        this.templateRepository = templateRepository;
        this.challengeConfigRepository = challengeConfigRepository;
        this.tapRepository = tapRepository;
        this.tapCardRepository = tapCardRepository;
        this.challengeEventRepository = challengeEventRepository;
        this.disputeRepository = disputeRepository;
        this.mailTokenRepository = mailTokenRepository;
        this.mailSender = mailSender;
        this.eventRecorder = eventRecorder;
        this.appBaseUrl = appBaseUrl;
    }

    @Transactional
    public CreateInstanceResponse create(
            UUID userId,
            CreateInstanceRequest request
    ) {
        ActivityTemplate template = templateRepository
                .findById(request.activityTemplateId())
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        assertTemplatePlayableBy(template, userId);

        String idempotencyKey = request.idempotencyKey().toString();
        ActivityInstance existing = instanceRepository
                .findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
                        userId,
                        idempotencyKey
                )
                .orElse(null);

        if (existing != null) {
            return new CreateInstanceResponse(
                    existing.getId(),
                    existing.getSequenceNo(),
                    existing.getActivityTemplateId()
            );
        }

        OffsetDateTime now = OffsetDateTime.now(clock);
        int sequenceNo = instanceRepository.findMaxSequenceNo(
                template.getId(),
                userId
        ) + 1;

        ActivityInstance instance = ActivityInstance.createChallenge(
                template.getId(),
                userId,
                Objects.requireNonNullElse(
                        request.playContext(),
                        TemplatePlayContext.ONLINE
                ),
                Objects.requireNonNullElse(
                        request.relationshipMode(),
                        TemplateRelationshipMode.SOLO
                ),
                idempotencyKey,
                sequenceNo,
                request.schedule() == null ? null : request.schedule().endAt(),
                now
        );

        instanceRepository.save(instance);
        challengeConfigRepository.save(ActivityInstanceChallengeConfig.create(
                instance.getId(),
                normalizeRequiredText(request.refEmail(), "refEmail").toLowerCase(),
                request.amountCents(),
                now
        ));

        return new CreateInstanceResponse(
                instance.getId(),
                instance.getSequenceNo(),
                template.getId()
        );
    }

    @Transactional(readOnly = true)
    public PlayInstanceSummaryResponse get(
            UUID userId,
            UUID instanceId
    ) {
        ActivityInstance instance = requireOwnedInstance(instanceId, userId);
        ActivityTemplate template = templateRepository
                .findById(instance.getActivityTemplateId())
                .orElse(null);
        ActivityInstanceChallengeConfig config =
                challengeConfigRepository.findById(instanceId).orElse(null);
        ActivityTap latestTap = tapRepository
                .findFirstByActivityInstanceIdOrderBySequenceNoDesc(instanceId)
                .orElse(null);
        TapCard firstCard = tapCardRepository
                .findFirstByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
                        instanceId
                )
                .orElse(null);

        return new PlayInstanceSummaryResponse(
                toSummary(instance, template, config, latestTap, firstCard)
        );
    }

    @Transactional(readOnly = true)
    public InstanceDashboardResponse getDashboard(UUID userId) {
        return new InstanceDashboardResponse(
                instanceRepository.findDashboardInstances(userId)
                        .stream()
                        .map(this::toDashboardItem)
                        .toList()
        );
    }

    private InstanceDashboardItem toDashboardItem(InstanceDashboardRow row) {
        TapSummary latestTap = row.getLatestTapId() == null
                ? null
                : new TapSummary(
                        row.getLatestTapId(),
                        ActivityTapState.valueOf(row.getLatestTapState()),
                        row.getLatestTapSequenceNo(),
                        toOffsetDateTime(row.getLatestTapFirstHappenedAt()),
                        toOffsetDateTime(row.getLatestTapFinalizedAt()),
                        toOffsetDateTime(row.getLatestTapCanceledAt())
                );

        return new InstanceDashboardItem(
                row.getId(),
                ActivityModeKind.valueOf(row.getModeKind()),
                row.getTitle(),
                row.getRules(),
                row.getPhotoPath(),
                TemplatePlayContext.valueOf(row.getPlayContext()),
                TemplateRelationshipMode.valueOf(row.getRelationshipMode()),
                row.getProofKind(),
                toOffsetDateTime(row.getStartedAt()),
                toOffsetDateTime(row.getUpdatedAt()),
                latestTap
        );
    }

    private OffsetDateTime toOffsetDateTime(Instant instant) {
        return instant == null ? null : instant.atOffset(ZoneOffset.UTC);
    }

    @Transactional
    public ToggleTapResponse toggleTap(
            UUID userId,
            UUID instanceId
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstance instance = requireOwnedInstanceForUpdate(instanceId, userId);
        ActivityInstanceChallengeConfig config = requireChallengeConfigForUpdate(instanceId);

        assertChallengeTappable(instance, config);

        ActivityTap latestTap = tapRepository
                .findLatestByActivityInstanceIdForUpdate(instanceId)
                .orElse(null);

        if (latestTap != null && isSameTapDay(latestTap.getFirstHappenedAt(), now)) {
            if (latestTap.getFinalizedAt() == null) {
                if (latestTap.getState() == ActivityTapState.OPENED) {
                    latestTap.cancel(now);
                    return toggleResponse("CANCELED", latestTap);
                }

                if (latestTap.getState() == ActivityTapState.CANCELED) {
                    latestTap.reopen(now);
                    return toggleResponse("REOPENED", latestTap);
                }
            }

            return toggleResponse("ALREADY_RECORDED", latestTap);
        }

        int sequenceNo = latestTap == null ? 1 : latestTap.getSequenceNo() + 1;
        ActivityTap tap = ActivityTap.open(
                instanceId,
                userId,
                sequenceNo,
                now
        );

        tapRepository.save(tap);
        instance.recordTap(now, userId);

        return toggleResponse("OPENED", tap);
    }

    @Transactional(readOnly = true)
    public TapResponse getTap(
            UUID userId,
            UUID instanceId,
            UUID tapId
    ) {
        ActivityTap tap = tapRepository
                .findByIdAndActivityInstanceId(tapId, instanceId)
                .orElseThrow(() -> new EntityNotFoundException("Tap not found"));

        requireOwnedInstance(instanceId, userId);

        return new TapResponse(new TapDetail(
                tap.getId(),
                tap.getActivityInstanceId(),
                tap.getSequenceNo(),
                tap.getFirstHappenedAt(),
                tap.getFinalizedAt(),
                tap.getCanceledAt(),
                tap.getState(),
                tap.getCreatedAt(),
                tap.getUpdatedAt()
        ));
    }

    @Transactional
    public TapCardResponse createTapCard(
            UUID userId,
            UUID instanceId,
            UUID tapId,
            CreateTapCardRequest request
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstance instance = requireOwnedInstanceForUpdate(instanceId, userId);
        ActivityInstanceChallengeConfig config = requireChallengeConfigForUpdate(instanceId);
        assertChallengeTappable(instance, config);

        ActivityTap tap = tapRepository.findByIdForUpdate(tapId)
                .orElseThrow(() -> new EntityNotFoundException("Tap not found"));

        if (!tap.getActivityInstanceId().equals(instanceId)) {
            throw new DomainConflictException("Tap does not belong to this play instance");
        }
        if (tap.getState() == ActivityTapState.CANCELED) {
            throw new DomainConflictException("Canceled taps cannot create cards");
        }

        int sequenceNo = tapCardRepository.findMaxSequenceNoForTap(tapId) + 1;
        String note = normalizeNullableText(request.note(), null);
        String photoPath = Boolean.TRUE.equals(request.removePhoto())
                ? null
                : normalizeNullableText(request.photoPath(), null);

        TapCard card = TapCard.create(
                instanceId,
                tapId,
                userId,
                sequenceNo,
                tap.getSequenceNo(),
                note,
                photoPath,
                now
        );

        tapCardRepository.save(card);
        tap.finalizeTap(now);

        return new TapCardResponse(new TapCardData(
                card.getId(),
                Objects.requireNonNullElse(card.getNote(), ""),
                card.getPhotoPath()
        ));
    }

    @Transactional
    public ChallengerDecisionResponse submitChallengerDecision(
            UUID userId,
            UUID instanceId,
            ChallengerDecisionRequest request
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstance instance = requireOwnedInstanceForUpdate(instanceId, userId);
        ActivityInstanceChallengeConfig config = requireChallengeConfigForUpdate(instanceId);

        if (hasTerminalEvent(instanceId) || config.hasTerminalChallengerVerdict()) {
            return new ChallengerDecisionResponse(true, false, instanceId);
        }

        ActivityChallengerFinalVerdict finalVerdict = switch (request.decision()) {
            case SUCCESS -> finalizeSuccess(instance, config, userId, now);
            case FAIL -> finalizeFailNoPayment(instance, config, userId, now);
            case CHICKEN -> finalizeChicken(instance, config, userId, now);
            case DISPUTE -> finalizeDispute(
                    instance,
                    config,
                    userId,
                    normalizeRequiredText(request.reasonCode(), "reasonCode"),
                    normalizeNullableText(request.details(), null),
                    now
            );
        };

        config.markChallengerFinalized(finalVerdict, now);

        return new ChallengerDecisionResponse(true, true, instanceId);
    }

    @Transactional
    public CoverCardResponse setCoverCard(
            UUID userId,
            UUID instanceId,
            UUID coverCardId
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstance instance = requireOwnedInstanceForUpdate(instanceId, userId);
        ActivityInstanceChallengeConfig config = requireChallengeConfigForUpdate(instanceId);
        TapCard card = tapCardRepository.findByIdForUpdate(coverCardId)
                .orElseThrow(() -> new EntityNotFoundException("Cover card not found"));

        if (card.getDeletedAt() != null) {
            throw new EntityNotFoundException("Cover card not found");
        }
        if (!card.getActivityInstanceId().equals(instanceId)) {
            throw new DomainConflictException("Cover card does not belong to this play instance");
        }
        if (config.getRefState() != ActivityRefState.DECIDED) {
            throw new DomainConflictException("Referee decision is required before selecting a cover card");
        }
        if (instance.getState() != ActivityInstanceState.COMPLETED
                && instance.getState() != ActivityInstanceState.TERMINATED) {
            throw new DomainConflictException("Play instance is not finalized");
        }

        ActivityInstanceChallengeEvent latestEvent = challengeEventRepository
                .findFirstByActivityInstanceIdOrderByCreatedAtDescIdDesc(instanceId)
                .orElseThrow(() -> new DomainConflictException("Final challenge event not found"));

        if (!TERMINAL_EVENTS.contains(latestEvent.getEventType())) {
            throw new DomainConflictException("Latest challenge event is not finalized");
        }

        instance.setCoverCard(coverCardId, userId, now);

        return new CoverCardResponse(true, instanceId, coverCardId);
    }

    @Transactional(readOnly = true)
    public ChallengeFinalCallResponse getFinalCall(
            UUID userId,
            UUID instanceId
    ) {
        ActivityInstance instance = requireOwnedInstance(instanceId, userId);
        ActivityTemplate template = templateRepository
                .findById(instance.getActivityTemplateId())
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));
        ActivityInstanceChallengeConfig config =
                challengeConfigRepository.findById(instanceId)
                        .orElseThrow(() -> new EntityNotFoundException("Challenge config not found"));

        return new ChallengeFinalCallResponse(
                true,
                buildFinalCallProjection(instance, template, config),
                instance.getCoverCardId(),
                toTerminalAction(config.getChallengerFinalVerdict())
        );
    }

    @Transactional
    public void prepareRefNotification(
            UUID userId,
            UUID instanceId
    ) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstance instance = requireOwnedInstanceForUpdate(instanceId, userId);
        ActivityInstanceChallengeConfig config = requireChallengeConfigForUpdate(instanceId);

        String refEmail = normalizeNullableText(config.getRefEmail(), null);
        if (refEmail == null) {
            throw new IllegalArgumentException("Ref email is missing for this play instance");
        }

        ActivityTemplate template = templateRepository.findById(instance.getActivityTemplateId())
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));

        String token = generateOpaqueToken();
        String finalCallUrl = appBaseUrl + "/play/challenge/ref-decision/" + token;
        String contents = normalizeNullableText(
                template.getRules(),
                "Please review this play and make the final call."
        );

        MailDeliveryResult result = mailSender.sendRefDecisionRequest(new RefDecisionMailRequest(
                refEmail,
                Objects.requireNonNullElse(template.getTitle(), "Play review needed"),
                contents,
                finalCallUrl,
                REF_ACCESS_TOKEN_EXPIRY_HOURS
        ));

        if (!result.success()) {
            // Written in its own transaction so the failure is durable even though
            // the token/config writes below never happen and this transaction rolls back.
            eventRecorder.recordIndependently(
                    instance.getId(),
                    ChallengeEventType.MAIL_FAILED,
                    mailFailedPayload(refEmail, result),
                    now
            );
            throw new MailDeliveryException(
                    "Failed to send referee decision email: "
                            + Objects.requireNonNullElse(result.errorMessage(), "unknown error")
            );
        }

        mailTokenRepository.save(ActivityInstanceChallengeMailToken.createRefAccess(
                instance.getId(),
                token,
                now.plusHours(REF_ACCESS_TOKEN_EXPIRY_HOURS),
                now
        ));
        config.markRefMailSent(now);
        saveEvent(
                instance.getId(),
                ChallengeEventType.MAIL_SENT,
                mailSentPayload(refEmail, result),
                now
        );
    }

    private String generateOpaqueToken() {
        byte[] bytes = new byte[32];
        TOKEN_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private Map<String, Object> mailSentPayload(String refEmail, MailDeliveryResult result) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("ref_email", refEmail);
        payload.put("token_action", ActivityInstanceChallengeMailToken.REF_ACCESS_ACTION);
        payload.put("expires_in_hours", REF_ACCESS_TOKEN_EXPIRY_HOURS);
        payload.put("provider_message_id", result.providerMessageId());
        return payload;
    }

    private Map<String, Object> mailFailedPayload(String refEmail, MailDeliveryResult result) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("ref_email", refEmail);
        payload.put("token_action", ActivityInstanceChallengeMailToken.REF_ACCESS_ACTION);
        payload.put("provider_status", result.providerStatus());
        payload.put("provider_error", result.errorMessage());
        return payload;
    }

    @Transactional(readOnly = true)
    public RefDecisionSessionResponse getRefDecisionSession(String token) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstanceChallengeMailToken mailToken =
                mailTokenRepository.findFirstByToken(normalizeRequiredText(token, "token"))
                        .orElseThrow(() -> new EntityNotFoundException("Invalid token"));

        if (mailToken.getInvalidatedAt() != null
                || !ActivityInstanceChallengeMailToken.REF_ACCESS_ACTION.equals(mailToken.getAction())) {
            throw new EntityNotFoundException("Invalid token");
        }
        if (mailToken.isExpired(now)) {
            throw new DomainConflictException("Token expired");
        }

        ActivityInstance instance = instanceRepository
                .findById(mailToken.getActivityInstanceId())
                .orElseThrow(() -> new EntityNotFoundException("Play instance not found"));
        ActivityTemplate template = templateRepository
                .findById(instance.getActivityTemplateId())
                .orElseThrow(() -> new EntityNotFoundException("Template not found"));
        ActivityInstanceChallengeConfig config =
                challengeConfigRepository.findById(instance.getId())
                        .orElseThrow(() -> new EntityNotFoundException("Challenge config not found"));

        return new RefDecisionSessionResponse(
                true,
                buildRawFinalCallProjection(instance, template, config)
        );
    }

    @Transactional
    public RefDecisionResult submitRefDecision(RefDecisionRequest request) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        ActivityInstanceChallengeMailToken mailToken =
                mailTokenRepository.findByToken(normalizeRequiredText(request.token(), "token"))
                        .orElse(null);

        if (mailToken == null) {
            return RefDecisionResult.rejected("INVALID_TOKEN", null, null);
        }
        if (mailToken.getInvalidatedAt() != null || mailToken.getUsedAt() != null) {
            return RefDecisionResult.rejected(
                    "ALREADY_USED",
                    mailToken.getActivityInstanceId(),
                    null
            );
        }
        if (mailToken.isExpired(now)) {
            return RefDecisionResult.rejected(
                    "EXPIRED_TOKEN",
                    mailToken.getActivityInstanceId(),
                    null
            );
        }
        if (!ActivityInstanceChallengeMailToken.REF_ACCESS_ACTION.equals(mailToken.getAction())) {
            return RefDecisionResult.rejected(
                    "INVALID_ACTION",
                    mailToken.getActivityInstanceId(),
                    null
            );
        }

        ActivityInstanceChallengeConfig config = challengeConfigRepository
                .findByActivityInstanceIdForUpdate(mailToken.getActivityInstanceId())
                .orElse(null);

        if (config == null) {
            return RefDecisionResult.rejected(
                    "SERVER_ERROR",
                    mailToken.getActivityInstanceId(),
                    null
            );
        }
        if (config.getRefState() == ActivityRefState.DECIDED) {
            return RefDecisionResult.rejected(
                    "ALREADY_DECIDED",
                    mailToken.getActivityInstanceId(),
                    null
            );
        }

        ActivityRefVerdict verdict = request.verdict() == RefDecisionVerdict.SUCCESS
                ? ActivityRefVerdict.SUCCESS
                : ActivityRefVerdict.FAIL;
        String nextStatus = verdict == ActivityRefVerdict.SUCCESS
                ? ChallengeProcessStatus.REF_DECIDED_SUCCESS.name()
                : ChallengeProcessStatus.REF_DECIDED_FAIL.name();
        ChallengeEventType eventType = verdict == ActivityRefVerdict.SUCCESS
                ? ChallengeEventType.REF_DECISION_SUCCESS
                : ChallengeEventType.REF_DECISION_FAIL;

        config.markRefDecision(verdict, now);
        mailToken.markUsed(now);
        mailTokenRepository.findActiveSiblingTokens(
                mailToken.getActivityInstanceId(),
                mailToken.getId()
        ).forEach(sibling -> sibling.invalidate(now));
        saveEvent(
                mailToken.getActivityInstanceId(),
                eventType,
                Map.of(
                        "token_id", mailToken.getId().toString(),
                        "token_action", mailToken.getAction(),
                        "ref_verdict", verdict.name()
                ),
                now
        );

        return RefDecisionResult.accepted(
                mailToken.getActivityInstanceId(),
                nextStatus
        );
    }

    private ActivityChallengerFinalVerdict finalizeSuccess(
            ActivityInstance instance,
            ActivityInstanceChallengeConfig config,
            UUID userId,
            OffsetDateTime now
    ) {
        assertActiveChallenge(instance);
        requireRefVerdict(config, ActivityRefVerdict.SUCCESS);
        requireLatestRefDecisionEvent(instance.getId());

        UUID coverCardId = latestCardId(instance.getId());
        instance.complete(coverCardId, userId, now);
        saveEvent(
                instance.getId(),
                ChallengeEventType.CHALLENGER_FINALIZED_SUCCESS,
                nullablePayload("cover_card_id", coverCardId),
                now
        );

        return ActivityChallengerFinalVerdict.SUCCESS;
    }

    private ActivityChallengerFinalVerdict finalizeFailNoPayment(
            ActivityInstance instance,
            ActivityInstanceChallengeConfig config,
            UUID userId,
            OffsetDateTime now
    ) {
        assertActiveChallenge(instance);
        requireRefVerdict(config, ActivityRefVerdict.FAIL);
        if (config.getFailCardFeeMinor() != 0) {
            throw new UnprocessableOperationException("Payment is required for this challenge failure");
        }

        instance.complete(null, userId, now);
        saveEvent(
                instance.getId(),
                ChallengeEventType.CHALLENGER_FINALIZED_FAIL,
                Map.of(
                        "payment_required", false,
                        "amount_minor", 0,
                        "finalized_via", "NO_PAYMENT"
                ),
                now
        );

        return ActivityChallengerFinalVerdict.FAIL;
    }

    private ActivityChallengerFinalVerdict finalizeChicken(
            ActivityInstance instance,
            ActivityInstanceChallengeConfig config,
            UUID userId,
            OffsetDateTime now
    ) {
        assertActiveChallenge(instance);
        requireAnyRefVerdict(config);
        requireLatestRefDecisionEvent(instance.getId());

        UUID coverCardId = requireLatestCardId(instance.getId());
        instance.complete(coverCardId, userId, now);
        saveEvent(
                instance.getId(),
                ChallengeEventType.CHALLENGER_FINALIZED_CHICKEN,
                Map.of("cover_card_id", coverCardId.toString()),
                now
        );

        return ActivityChallengerFinalVerdict.CHICKEN;
    }

    private ActivityChallengerFinalVerdict finalizeDispute(
            ActivityInstance instance,
            ActivityInstanceChallengeConfig config,
            UUID userId,
            String reasonCode,
            String details,
            OffsetDateTime now
    ) {
        assertActiveChallenge(instance);
        requireAnyRefVerdict(config);
        requireLatestRefDecisionEvent(instance.getId());

        UUID coverCardId = requireLatestCardId(instance.getId());
        disputeRepository.save(ActivityInstanceChallengeDispute.create(
                instance.getId(),
                userId,
                reasonCode,
                details,
                config.getRefVerdict(),
                now
        ));
        instance.complete(coverCardId, userId, now);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("cover_card_id", coverCardId.toString());
        payload.put("reason_code", reasonCode);
        payload.put("details", details);
        payload.put("ref_verdict", config.getRefVerdict().name());
        saveEvent(
                instance.getId(),
                ChallengeEventType.CHALLENGER_FINALIZED_DISAGREE,
                payload,
                now
        );

        return ActivityChallengerFinalVerdict.DISPUTE;
    }

    private PlayInstanceSummary toSummary(
            ActivityInstance instance,
            ActivityTemplate template,
            ActivityInstanceChallengeConfig config,
            ActivityTap latestTap,
            TapCard firstCard
    ) {
        String title = template != null && normalizeNullableText(template.getTitle(), null) != null
                ? template.getTitle()
                : "Untitled challenge";
        String rules = template == null ? null : template.getRules();
        String photoPath = template == null ? null : template.getPhotoPath();

        Map<String, Object> formData = new LinkedHashMap<>();
        formData.put("title", title);
        formData.put("rules", rules);
        formData.put("photo_path", photoPath);
        formData.put("refEmail", config == null ? null : config.getRefEmail());
        formData.put("amountCents", config == null ? 0 : config.getFailCardFeeMinor());

        OffsetDateTime updatedAt = maxOffsetDateTime(
                instance.getUpdatedAt(),
                template == null ? null : template.getUpdatedAt(),
                config == null ? null : config.getUpdatedAt(),
                config == null ? null : config.getChallengerFinalizedAt()
        );

        return new PlayInstanceSummary(
                instance.getId(),
                title,
                config == null ? null : config.getRefEmail(),
                config == null ? null : config.getRefUserId(),
                config == null ? 0 : config.getFailCardFeeMinor(),
                photoPath,
                template == null
                        ? null
                        : new PlayInstanceTemplateSummary(
                                template.getId(),
                                template.getTitle(),
                                template.getRules(),
                                template.getPhotoPath()
                        ),
                "USD",
                rules,
                instance.getStartedAt(),
                firstNonNull(
                        instance.getEndAt(),
                        instance.getCompletedAt(),
                        instance.getTerminatedAt()
                ),
                null,
                deriveStatus(instance, template, config),
                formData,
                instance.getCreatedAt(),
                updatedAt,
                latestTap == null ? null : new TapSummary(
                        latestTap.getId(),
                        latestTap.getState(),
                        latestTap.getSequenceNo(),
                        latestTap.getFirstHappenedAt(),
                        latestTap.getFinalizedAt(),
                        latestTap.getCanceledAt()
                ),
                firstCard == null ? null : firstCard.getPhotoPath()
        );
    }

    private ChallengeProcessStatus deriveStatus(
            ActivityInstance instance,
            ActivityTemplate template,
            ActivityInstanceChallengeConfig config
    ) {
        return ChallengeStatusDeriver.deriveStatus(
                instance.getDeletedAt(),
                config == null ? null : config.getChallengerFinalVerdict(),
                template == null ? null : template.getStatus(),
                instance.getState(),
                config == null ? null : config.getRefVerdict()
        );
    }

    private Map<String, Object> buildFinalCallProjection(
            ActivityInstance instance,
            ActivityTemplate template,
            ActivityInstanceChallengeConfig config
    ) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("instance", buildFinalCallInstance(instance, template, config));
        data.put("taps", buildFinalCallTaps(instance.getId()));
        return data;
    }

    private Map<String, Object> buildRawFinalCallProjection(
            ActivityInstance instance,
            ActivityTemplate template,
            ActivityInstanceChallengeConfig config
    ) {
        Map<String, Object> projection = new LinkedHashMap<>();
        projection.put("activity_instance_id", instance.getId());
        projection.put("completed_at", instance.getCompletedAt());
        projection.put("creator_display_name", template.getCreatorDisplayName());
        projection.put("fail_card_fee_minor", config.getFailCardFeeMinor());
        projection.put("instance_sequence_no", instance.getSequenceNo());
        projection.put("instance_state", instance.getState().name());
        projection.put("max_participants", template.getMaxParticipants());
        projection.put("min_participants", template.getMinParticipants());
        projection.put("mode_kind", instance.getModeKind().name());
        projection.put("origin_id", template.getOriginId());
        projection.put("parent_id", template.getParentId());
        projection.put("photo_path", template.getPhotoPath());
        projection.put("play_context", instance.getPlayContext().name());
        projection.put("proof_kind", template.getProofKind());
        projection.put("ref_state", config.getRefState().name());
        projection.put("ref_verdict", config.getRefVerdict() == null ? null : config.getRefVerdict().name());
        projection.put("relationship_mode", instance.getRelationshipMode().name());
        projection.put("rules", template.getRules());
        projection.put("started_at", instance.getStartedAt());
        projection.put("tap_groups", buildRawTapGroups(instance.getId()));
        projection.put("title", template.getTitle());
        projection.put("updated_at", maxOffsetDateTime(
                instance.getUpdatedAt(),
                template.getUpdatedAt(),
                config.getUpdatedAt()
        ));
        return projection;
    }

    private Map<String, Object> buildFinalCallInstance(
            ActivityInstance instance,
            ActivityTemplate template,
            ActivityInstanceChallengeConfig config
    ) {
        Map<String, Object> instanceData = new LinkedHashMap<>();
        instanceData.put("id", instance.getId());
        instanceData.put("title", template.getTitle());
        instanceData.put("rules", Objects.requireNonNullElse(template.getRules(), ""));
        instanceData.put("photo_path", template.getPhotoPath());
        instanceData.put("status", deriveFinalStatus(config));
        instanceData.put("creatorDisplayName", template.getCreatorDisplayName());
        instanceData.put("failCardFeeMinor", config.getFailCardFeeMinor());
        instanceData.put("proofKind", template.getProofKind());
        instanceData.put("refState", config.getRefState().name());
        instanceData.put("refVerdict", config.getRefVerdict() == null ? null : config.getRefVerdict().name());
        instanceData.put("startedAt", instance.getStartedAt());
        instanceData.put("completedAt", instance.getCompletedAt());
        instanceData.put("updatedAt", maxOffsetDateTime(
                instance.getUpdatedAt(),
                template.getUpdatedAt(),
                config.getUpdatedAt()
        ));
        return instanceData;
    }

    private List<Map<String, Object>> buildFinalCallTaps(UUID instanceId) {
        List<TapCard> cards = tapCardRepository
                .findAllByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
                        instanceId
                );
        List<ActivityTap> taps = tapRepository
                .findAllByActivityInstanceIdOrderBySequenceNoAsc(instanceId);
        List<Map<String, Object>> groups = new ArrayList<>();

        for (ActivityTap tap : taps) {
            List<Map<String, Object>> cardData = cards.stream()
                    .filter(card -> card.getTapId().equals(tap.getId()))
                    .sorted(Comparator.comparingInt(TapCard::getSequenceNo))
                    .map(card -> {
                        Map<String, Object> data = new LinkedHashMap<>();
                        data.put("id", card.getId());
                        data.put("photo_path", card.getPhotoPath());
                        data.put("note", card.getNote());
                        return data;
                    })
                    .toList();

            if (cardData.isEmpty()) {
                continue;
            }

            Map<String, Object> group = new LinkedHashMap<>();
            group.put("id", tap.getId());
            group.put("created_at", tap.getFirstHappenedAt());
            group.put("cards", cardData);
            groups.add(group);
        }

        return groups;
    }

    private List<Map<String, Object>> buildRawTapGroups(UUID instanceId) {
        return buildFinalCallTaps(instanceId);
    }

    private String deriveFinalStatus(ActivityInstanceChallengeConfig config) {
        if (config.getRefVerdict() == ActivityRefVerdict.SUCCESS) {
            return "SUCCESS";
        }
        if (config.getRefVerdict() == ActivityRefVerdict.FAIL) {
            return "FAIL";
        }
        return "IN_REVIEW";
    }

    private ActivityInstance requireOwnedInstance(UUID instanceId, UUID userId) {
        ActivityInstance instance = instanceRepository.findById(instanceId)
                .orElseThrow(() -> new EntityNotFoundException("Play instance not found"));
        assertOwnedInstance(instance, userId);
        assertInstanceNotDeleted(instance);
        return instance;
    }

    private ActivityInstance requireOwnedInstanceForUpdate(UUID instanceId, UUID userId) {
        ActivityInstance instance = instanceRepository.findByIdForUpdate(instanceId)
                .orElseThrow(() -> new EntityNotFoundException("Play instance not found"));
        assertOwnedInstance(instance, userId);
        assertInstanceNotDeleted(instance);
        return instance;
    }

    private ActivityInstanceChallengeConfig requireChallengeConfigForUpdate(UUID instanceId) {
        return challengeConfigRepository.findByActivityInstanceIdForUpdate(instanceId)
                .orElseThrow(() -> new EntityNotFoundException("Challenge config not found"));
    }

    private void assertTemplatePlayableBy(ActivityTemplate template, UUID userId) {
        boolean playable = template.getDeletedAt() == null
                && "ACTIVE".equals(template.getStatus())
                && template.getLifecycleState() == TemplateLifecycleState.PUBLISHED
                && (
                        template.getVisibility() == TemplateVisibility.PUBLIC
                                || userId.equals(template.getCreatedBy())
                );

        if (!playable) {
            throw new EntityNotFoundException("Template not found or not playable");
        }
    }

    private void assertOwnedInstance(ActivityInstance instance, UUID userId) {
        if (!userId.equals(instance.getCreatedBy())) {
            throw new AccessDeniedException("Not resource owner");
        }
    }

    private void assertInstanceNotDeleted(ActivityInstance instance) {
        if (instance.getDeletedAt() != null) {
            throw new EntityNotFoundException("Play instance not found");
        }
    }

    private void assertChallengeTappable(
            ActivityInstance instance,
            ActivityInstanceChallengeConfig config
    ) {
        if (instance.getModeKind() != ActivityModeKind.CHALLENGE) {
            throw new IllegalArgumentException("This play mode does not support tap here yet");
        }
        if (!instance.isActive()) {
            throw new DomainConflictException("This challenge can no longer be tapped");
        }
        if (config.getRefState() == ActivityRefState.DECIDED) {
            throw new DomainConflictException("This challenge can no longer be tapped");
        }
        if (challengeEventRepository.existsByActivityInstanceIdAndEventTypeIn(
                instance.getId(),
                Set.of(
                        ChallengeEventType.REF_DECISION_SUCCESS,
                        ChallengeEventType.REF_DECISION_FAIL,
                        ChallengeEventType.REF_DECISION_DISAGREE,
                        ChallengeEventType.CHALLENGER_FINALIZED_SUCCESS,
                        ChallengeEventType.CHALLENGER_FINALIZED_FAIL,
                        ChallengeEventType.CHALLENGER_FINALIZED_CHICKEN,
                        ChallengeEventType.CHALLENGER_FINALIZED_DISAGREE
                )
        )) {
            throw new DomainConflictException("This challenge can no longer be tapped");
        }
    }

    private void assertActiveChallenge(ActivityInstance instance) {
        if (instance.getModeKind() != ActivityModeKind.CHALLENGE) {
            throw new IllegalArgumentException("This play mode does not support this action");
        }
        if (!instance.isActive()) {
            throw new DomainConflictException("This challenge can no longer be finalized");
        }
    }

    private void requireRefVerdict(
            ActivityInstanceChallengeConfig config,
            ActivityRefVerdict verdict
    ) {
        if (config.getRefState() != ActivityRefState.DECIDED
                || config.getRefVerdict() != verdict) {
            String message = verdict == ActivityRefVerdict.SUCCESS
                    ? "Referee success decision is required before finalizing success"
                    : "Referee fail decision is required before finalizing failure";
            throw new DomainConflictException(message);
        }
    }

    private void requireAnyRefVerdict(ActivityInstanceChallengeConfig config) {
        if (config.getRefState() != ActivityRefState.DECIDED
                || config.getRefVerdict() == null) {
            throw new DomainConflictException("A referee decision is required before this action");
        }
    }

    private void requireLatestRefDecisionEvent(UUID instanceId) {
        ActivityInstanceChallengeEvent latestEvent = challengeEventRepository
                .findFirstByActivityInstanceIdOrderByCreatedAtDescIdDesc(instanceId)
                .orElseThrow(() -> new DomainConflictException("A referee decision is required before this action"));

        if (!REF_DECISION_EVENTS.contains(latestEvent.getEventType())) {
            throw new DomainConflictException("A referee decision is required before this action");
        }
    }

    private boolean hasTerminalEvent(UUID instanceId) {
        return challengeEventRepository.existsByActivityInstanceIdAndEventTypeIn(
                instanceId,
                TERMINAL_EVENTS
        );
    }

    private UUID requireLatestCardId(UUID instanceId) {
        return tapCardRepository
                .findFirstByActivityInstanceIdAndDeletedAtIsNullOrderBySequenceNoDescCreatedAtDescIdDesc(
                        instanceId
                )
                .map(TapCard::getId)
                .orElseThrow(() -> new DomainConflictException(
                        "A tap card is required before finalizing this challenge"
                ));
    }

    private UUID latestCardId(UUID instanceId) {
        return tapCardRepository
                .findFirstByActivityInstanceIdAndDeletedAtIsNullOrderBySequenceNoDescCreatedAtDescIdDesc(
                        instanceId
                )
                .map(TapCard::getId)
                .orElse(null);
    }

    private void saveEvent(
            UUID instanceId,
            ChallengeEventType eventType,
            Map<String, Object> payload,
            OffsetDateTime now
    ) {
        challengeEventRepository.save(ActivityInstanceChallengeEvent.create(
                instanceId,
                eventType,
                payload,
                now
        ));
    }

    private Map<String, Object> nullablePayload(String key, Object value) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put(key, value == null ? null : value.toString());
        return payload;
    }

    private ToggleTapResponse toggleResponse(String action, ActivityTap tap) {
        return new ToggleTapResponse(
                true,
                new ToggleTapData(
                        action,
                        tap.getId(),
                        tap.getActivityInstanceId(),
                        tap.getSequenceNo(),
                        tap.getState(),
                        tap.getFinalizedAt()
                )
        );
    }

    private boolean isSameTapDay(
            OffsetDateTime happenedAt,
            OffsetDateTime now
    ) {
        return happenedAt.atZoneSameInstant(TAP_DAY_ZONE).toLocalDate()
                .equals(now.atZoneSameInstant(TAP_DAY_ZONE).toLocalDate());
    }

    private ChallengerDecisionType toTerminalAction(
            ActivityChallengerFinalVerdict verdict
    ) {
        if (verdict == null) {
            return null;
        }

        return switch (verdict) {
            case SUCCESS -> ChallengerDecisionType.SUCCESS;
            case FAIL -> ChallengerDecisionType.FAIL;
            case CHICKEN -> ChallengerDecisionType.CHICKEN;
            case DISPUTE -> ChallengerDecisionType.DISPUTE;
        };
    }

    private String normalizeRequiredText(String value, String field) {
        String normalized = normalizeNullableText(value, null);
        if (normalized == null) {
            throw new IllegalArgumentException(field + " is required");
        }
        return normalized;
    }

    private String normalizeNullableText(String value, String defaultValue) {
        if (value == null) {
            return defaultValue;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty()
                ? defaultValue
                : trimmed;
    }

    @SafeVarargs
    private final <T> T firstNonNull(T... values) {
        for (T value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private OffsetDateTime maxOffsetDateTime(OffsetDateTime... values) {
        OffsetDateTime latest = null;
        for (OffsetDateTime value : values) {
            if (value != null && (latest == null || value.isAfter(latest))) {
                latest = value;
            }
        }
        return latest;
    }

    public record RefDecisionResult(
            boolean ok,
            String code,
            UUID activityInstanceId,
            String nextStatus
    ) {
        public static RefDecisionResult accepted(
                UUID activityInstanceId,
                String nextStatus
        ) {
            return new RefDecisionResult(
                    true,
                    "OK",
                    activityInstanceId,
                    nextStatus
            );
        }

        public static RefDecisionResult rejected(
                String code,
                UUID activityInstanceId,
                String nextStatus
        ) {
            return new RefDecisionResult(
                    false,
                    code,
                    activityInstanceId,
                    nextStatus
            );
        }
    }
}
