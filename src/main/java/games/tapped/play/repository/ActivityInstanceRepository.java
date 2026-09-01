package games.tapped.play.repository;

import games.tapped.play.entity.ActivityInstance;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ActivityInstanceRepository
        extends JpaRepository<ActivityInstance, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select instance from ActivityInstance instance where instance.id = :id")
    Optional<ActivityInstance> findByIdForUpdate(@Param("id") UUID id);

    Optional<ActivityInstance> findFirstByCreatedByAndIdempotencyKeyAndDeletedAtIsNull(
            UUID createdBy,
            String idempotencyKey
    );

    @Query("""
            select coalesce(max(instance.sequenceNo), 0)
            from ActivityInstance instance
            where instance.activityTemplateId = :templateId
              and instance.createdBy = :createdBy
              and instance.deletedAt is null
            """)
    int findMaxSequenceNo(
            @Param("templateId") UUID templateId,
            @Param("createdBy") UUID createdBy
    );

    @Query(
            value = """
                    select
                        ai.id as id,
                        ai.mode_kind::text as mode_kind,
                        at.title as title,
                        at.rules as rules,
                        at.photo_path as photo_path,
                        ai.play_context::text as play_context,
                        ai.relationship_mode::text as relationship_mode,
                        at.proof_kind as proof_kind,
                        ai.started_at as started_at,
                        ai.updated_at as updated_at,
                        lt.id as latest_tap_id,
                        lt.state::text as latest_tap_state,
                        lt.sequence_no as latest_tap_sequence_no,
                        lt.first_happened_at as latest_tap_first_happened_at,
                        lt.finalized_at as latest_tap_finalized_at,
                        lt.canceled_at as latest_tap_canceled_at
                    from activity_instances ai
                    join activity_instance_challenge_config aicc on aicc.activity_instance_id = ai.id
                    join activity_templates at
                        on at.id = ai.activity_template_id
                        and at.created_by = :userId
                        and at.deleted_at is null
                    left join lateral (
                        select atp.id, atp.state, atp.sequence_no, atp.first_happened_at,
                               atp.finalized_at, atp.canceled_at
                        from activity_taps atp
                        where atp.activity_instance_id = ai.id
                        order by atp.sequence_no desc
                        limit 1
                    ) lt on true
                    where ai.created_by = :userId
                        and ai.deleted_at is null
                        and ai.mode_kind = 'CHALLENGE'
                        and ai.state = 'ACTIVE'
                        and ai.completed_at is null
                        and ai.terminated_at is null
                        and aicc.ref_state = 'PENDING'
                        and not exists (
                            select 1
                            from activity_instance_challenge_events aice
                            where aice.activity_instance_id = ai.id
                                and aice.event_type in (
                                    'REF_DECISION_SUCCESS', 'REF_DECISION_FAIL', 'REF_DECISION_DISAGREE',
                                    'CHALLENGER_FINALIZED_SUCCESS', 'CHALLENGER_FINALIZED_FAIL',
                                    'CHALLENGER_FINALIZED_CHICKEN', 'CHALLENGER_FINALIZED_DISAGREE'
                                )
                        )
                    order by ai.updated_at desc, ai.id desc
                    """,
            nativeQuery = true
    )
    List<InstanceDashboardRow> findDashboardInstances(@Param("userId") UUID userId);
}
