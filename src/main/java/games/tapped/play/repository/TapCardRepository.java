package games.tapped.play.repository;

import games.tapped.play.entity.TapCard;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TapCardRepository
        extends JpaRepository<TapCard, UUID> {

    Optional<TapCard> findByIdAndDeletedAtIsNull(UUID id);

    Optional<TapCard> findFirstByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
            UUID activityInstanceId
    );

    Optional<TapCard> findFirstByActivityInstanceIdAndDeletedAtIsNullOrderBySequenceNoDescCreatedAtDescIdDesc(
            UUID activityInstanceId
    );

    List<TapCard> findAllByActivityInstanceIdAndDeletedAtIsNullOrderByTapSequenceNoAscSequenceNoAsc(
            UUID activityInstanceId
    );

    @Query("""
            select coalesce(max(card.sequenceNo), 0)
            from TapCard card
            where card.tapId = :tapId
              and card.deletedAt is null
            """)
    int findMaxSequenceNoForTap(@Param("tapId") UUID tapId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select card from TapCard card where card.id = :id")
    Optional<TapCard> findByIdForUpdate(@Param("id") UUID id);

    @Query(
            value = """
                    with eligible_cards as (
                        select
                            tc.id as card_id,
                            tc.tap_id as tap_id,
                            tc.activity_instance_id as activity_instance_id,
                            ai.activity_template_id as activity_template_id,
                            ai.created_by as owner_user_id,
                            p.handle as owner_handle,
                            p.nickname as owner_nickname,
                            p.avatar_url as owner_avatar_url,
                            at.title as instance_title,
                            at.title as template_title,
                            tc.note as note,
                            coalesce(tc.photo_path, at.photo_path) as photo_path,
                            coalesce(cfg.fail_card_fee_minor, 0) as fail_card_fee_minor,
                            case when cfg.challenger_final_verdict = 'FAIL' then 'FAIL' else 'SUCCESS' end as result,
                            coalesce(lc.like_count, 0) as like_count,
                            coalesce(rc.reply_count, 0) as reply_count,
                            ((coalesce(lc.like_count, 0) * 10 + coalesce(rc.reply_count, 0) * 18)::numeric
                                + least(coalesce(cfg.fail_card_fee_minor, 0)::numeric / 100, 100) * 2) as base_score,
                            tc.created_at as card_created_at,
                            tc.updated_at as card_updated_at,
                            ai.completed_at as completed_at,
                            greatest(coalesce(ai.completed_at, tc.created_at), tc.created_at) as rank_sort_at
                        from tap_cards tc
                        join activity_instances ai on ai.id = tc.activity_instance_id
                        join activity_templates at on at.id = ai.activity_template_id
                        join activity_instance_challenge_config cfg on cfg.activity_instance_id = ai.id
                        left join profiles p on p.user_id = ai.created_by
                        left join (
                            select tap_card_id, count(*) as like_count
                            from tap_card_likes
                            group by tap_card_id
                        ) lc on lc.tap_card_id = tc.id
                        left join (
                            select tap_card_id, count(*) as reply_count
                            from tap_card_replies
                            where status = 'VISIBLE' and deleted_at is null
                            group by tap_card_id
                        ) rc on rc.tap_card_id = tc.id
                        where tc.deleted_at is null
                            and ai.deleted_at is null
                            and ai.state = 'COMPLETED'
                            and ai.completed_at is not null
                            and ai.terminated_at is null
                            and ai.mode_kind = 'CHALLENGE'
                            and at.deleted_at is null
                            and at.visibility = 'PUBLIC'
                            and at.lifecycle_state = 'PUBLISHED'
                            and cfg.ref_state = 'DECIDED'
                            and cfg.ref_verdict in ('SUCCESS', 'FAIL')
                            and cfg.challenger_final_verdict in ('SUCCESS', 'FAIL')
                            and (case when cfg.challenger_final_verdict = 'FAIL' then 'FAIL' else 'SUCCESS' end) = :result
                    ),
                    best_per_user as (
                        select
                            eligible_cards.*,
                            row_number() over (
                                partition by owner_user_id
                                order by base_score desc, reply_count desc, like_count desc,
                                         fail_card_fee_minor desc, rank_sort_at desc, card_id
                            ) as owner_card_rank
                        from eligible_cards
                    )
                    select
                        row_number() over (
                            order by base_score desc, reply_count desc, like_count desc,
                                     fail_card_fee_minor desc, rank_sort_at desc, card_id
                        ) as "rank",
                        base_score as "score",
                        card_id as "cardId",
                        tap_id as "tapId",
                        activity_instance_id as "activityInstanceId",
                        activity_template_id as "activityTemplateId",
                        owner_user_id as "ownerUserId",
                        owner_handle as "ownerHandle",
                        owner_nickname as "ownerNickname",
                        owner_avatar_url as "ownerAvatarUrl",
                        instance_title as "instanceTitle",
                        template_title as "templateTitle",
                        result as "result",
                        note as "note",
                        photo_path as "photoPath",
                        like_count as "likeCount",
                        reply_count as "replyCount",
                        fail_card_fee_minor as "failCardFeeMinor",
                        card_created_at as "cardCreatedAt",
                        card_updated_at as "cardUpdatedAt",
                        completed_at as "completedAt",
                        rank_sort_at as "rankSortAt"
                    from best_per_user
                    where owner_card_rank = 1
                    order by base_score desc, reply_count desc, like_count desc,
                             fail_card_fee_minor desc, rank_sort_at desc, card_id
                    limit :limit
                    """,
            nativeQuery = true
    )
    List<TapCardLeaderboardRow> findLeaderboard(
            @Param("result") String result,
            @Param("limit") int limit
    );

    @Query(
            value = """
                    with candidates as (
                        select
                            tc.id as card_id,
                            tc.tap_id as tap_id,
                            tc.activity_instance_id as activity_instance_id,
                            ai.activity_template_id as activity_template_id,
                            at.title as instance_title,
                            at.status as template_status,
                            tc.note as note,
                            coalesce(tc.photo_path, at.photo_path) as photo_path,
                            coalesce(cfg.fail_card_fee_minor, 0) as fail_card_fee_minor,
                            cfg.challenger_final_verdict::text as challenger_final_verdict,
                            ai.state::text as instance_state,
                            cfg.ref_verdict::text as ref_verdict,
                            coalesce(lc.like_count, 0) as like_count,
                            coalesce(rc.reply_count, 0) as reply_count,
                            greatest(
                                tc.updated_at,
                                tap.updated_at,
                                ai.updated_at,
                                coalesce(cfg.updated_at, tc.updated_at),
                                coalesce(cfg.challenger_finalized_at, tc.updated_at)
                            ) as sort_updated_at
                        from tap_cards tc
                        join activity_taps tap on tap.id = tc.tap_id
                        join activity_instances ai on ai.id = tap.activity_instance_id
                        left join activity_instance_challenge_config cfg on cfg.activity_instance_id = ai.id
                        left join activity_templates at on at.id = ai.activity_template_id
                        left join (
                            select tap_card_id, count(*) as like_count
                            from tap_card_likes
                            group by tap_card_id
                        ) lc on lc.tap_card_id = tc.id
                        left join (
                            select tap_card_id, count(*) as reply_count
                            from tap_card_replies
                            where status = 'VISIBLE' and deleted_at is null
                            group by tap_card_id
                        ) rc on rc.tap_card_id = tc.id
                        where ai.created_by = :userId
                            and tc.deleted_at is null
                            and ai.deleted_at is null
                        order by tc.updated_at desc
                        limit :limit
                    )
                    select
                        card_id as "cardId",
                        tap_id as "tapId",
                        activity_instance_id as "activityInstanceId",
                        activity_template_id as "activityTemplateId",
                        instance_title as "instanceTitle",
                        template_status as "templateStatus",
                        note as "note",
                        photo_path as "photoPath",
                        fail_card_fee_minor as "failCardFeeMinor",
                        challenger_final_verdict as "challengerFinalVerdict",
                        instance_state as "instanceState",
                        ref_verdict as "refVerdict",
                        like_count as "likeCount",
                        reply_count as "replyCount",
                        sort_updated_at as "sortUpdatedAt"
                    from candidates
                    order by sort_updated_at desc, card_id
                    """,
            nativeQuery = true
    )
    List<PersonalFeedRow> findPersonalFeed(
            @Param("userId") UUID userId,
            @Param("limit") int limit
    );

    @Query(
            value = """
                    with tap_day_window as (
                        select (now() at time zone 'America/New_York')::date as tap_day
                    )
                    select
                        tc.id as id,
                        tc.activity_instance_id as activity_instance_id,
                        tc.tap_id as tap_id,
                        tc.note as note,
                        coalesce(tc.photo_path, at.photo_path) as photo_path,
                        tc.created_at as created_at,
                        at.id as template_id,
                        at.title as template_title,
                        at.rules as template_rules,
                        at.photo_path as template_photo_path,
                        coalesce(lc.like_count, 0) as like_count,
                        coalesce(rc.reply_count, 0) as reply_count
                    from tap_cards tc
                    join activity_instances ai on ai.id = tc.activity_instance_id
                    join tap_day_window tdw on true
                    left join activity_templates at on at.id = ai.activity_template_id and at.deleted_at is null
                    left join (
                        select tap_card_id, count(*) as like_count
                        from tap_card_likes
                        group by tap_card_id
                    ) lc on lc.tap_card_id = tc.id
                    left join (
                        select tap_card_id, count(*) as reply_count
                        from tap_card_replies
                        where status = 'VISIBLE' and deleted_at is null
                        group by tap_card_id
                    ) rc on rc.tap_card_id = tc.id
                    where ai.created_by = :userId
                        and tc.deleted_at is null
                        and ai.deleted_at is null
                        and (tc.created_at at time zone 'America/New_York')::date = tdw.tap_day
                    order by tc.created_at desc, tc.id desc
                    limit :limit
                    """,
            nativeQuery = true
    )
    List<TapCardTrayRow> findTodayTray(
            @Param("userId") UUID userId,
            @Param("limit") int limit
    );
}
