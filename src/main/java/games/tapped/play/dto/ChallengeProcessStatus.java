package games.tapped.play.dto;

public enum ChallengeProcessStatus {
    WAITING_FOR_REF_DECISION,
    REF_DECIDED_SUCCESS,
    REF_DECIDED_FAIL,
    COMPLETED_SUCCESS,
    COMPLETED_FAIL,
    COMPLETED_CHICKEN,
    COMPLETED_DISPUTE,
    TERMINATED
}
