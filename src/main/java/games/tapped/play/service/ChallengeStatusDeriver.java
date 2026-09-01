package games.tapped.play.service;

import games.tapped.play.dto.ChallengeProcessStatus;
import games.tapped.play.entity.ActivityChallengerFinalVerdict;
import games.tapped.play.entity.ActivityInstanceState;
import games.tapped.play.entity.ActivityRefVerdict;

import java.time.OffsetDateTime;

/**
 * Shared challenge-status precedence used by both the play-instance summary
 * ({@link ActivityInstanceService}) and the personal feed ({@link TapCardQueryService})
 * so the two read models never drift apart.
 */
final class ChallengeStatusDeriver {

    private ChallengeStatusDeriver() {
    }

    static ChallengeProcessStatus deriveStatus(
            OffsetDateTime instanceDeletedAt,
            ActivityChallengerFinalVerdict challengerFinalVerdict,
            String templateStatus,
            ActivityInstanceState instanceState,
            ActivityRefVerdict refVerdict
    ) {
        if (instanceDeletedAt != null) {
            return ChallengeProcessStatus.TERMINATED;
        }
        if (challengerFinalVerdict != null) {
            return switch (challengerFinalVerdict) {
                case SUCCESS -> ChallengeProcessStatus.COMPLETED_SUCCESS;
                case FAIL -> ChallengeProcessStatus.COMPLETED_FAIL;
                case CHICKEN -> ChallengeProcessStatus.COMPLETED_CHICKEN;
                case DISPUTE -> ChallengeProcessStatus.COMPLETED_DISPUTE;
            };
        }

        ChallengeProcessStatus legacyStatus = mapLegacyTemplateStatus(templateStatus);
        if (legacyStatus == ChallengeProcessStatus.COMPLETED_SUCCESS
                || legacyStatus == ChallengeProcessStatus.COMPLETED_FAIL
                || legacyStatus == ChallengeProcessStatus.COMPLETED_DISPUTE) {
            return legacyStatus;
        }
        if (instanceState == ActivityInstanceState.COMPLETED) {
            return refVerdict == ActivityRefVerdict.FAIL
                    ? ChallengeProcessStatus.COMPLETED_FAIL
                    : ChallengeProcessStatus.COMPLETED_SUCCESS;
        }
        if (instanceState == ActivityInstanceState.TERMINATED) {
            return refVerdict == ActivityRefVerdict.FAIL
                    ? ChallengeProcessStatus.COMPLETED_FAIL
                    : ChallengeProcessStatus.TERMINATED;
        }
        if (refVerdict == ActivityRefVerdict.SUCCESS) {
            return ChallengeProcessStatus.REF_DECIDED_SUCCESS;
        }
        if (refVerdict == ActivityRefVerdict.FAIL) {
            return ChallengeProcessStatus.REF_DECIDED_FAIL;
        }
        if (legacyStatus != null) {
            return legacyStatus;
        }

        return ChallengeProcessStatus.WAITING_FOR_REF_DECISION;
    }

    private static ChallengeProcessStatus mapLegacyTemplateStatus(String status) {
        if (status == null) {
            return null;
        }

        return switch (status.trim()) {
            case "MAIL_FAILED", "MAIL_SENT", "MAIL_QUEUED" ->
                    ChallengeProcessStatus.WAITING_FOR_REF_DECISION;
            case "WATCHER_MARKED_SUCCESS" -> ChallengeProcessStatus.REF_DECIDED_SUCCESS;
            case "WATCHER_MARKED_FAIL" -> ChallengeProcessStatus.REF_DECIDED_FAIL;
            case "CHALLENGER_FINAL_SUCCESS" -> ChallengeProcessStatus.COMPLETED_SUCCESS;
            case "CHALLENGER_FINAL_FAIL" -> ChallengeProcessStatus.COMPLETED_FAIL;
            case "CHALLENGER_FINAL_DISAGREE" -> ChallengeProcessStatus.COMPLETED_DISPUTE;
            case "CANCELLED" -> ChallengeProcessStatus.TERMINATED;
            default -> null;
        };
    }
}
