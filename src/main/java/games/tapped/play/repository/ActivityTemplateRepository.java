package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplate;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ActivityTemplateRepository
        extends JpaRepository<ActivityTemplate, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select template from ActivityTemplate template where template.id = :id")
    Optional<ActivityTemplate> findByIdForUpdate(@Param("id") UUID id);

    @Query(
            value = """
                    with ranked as (
                        select
                            t.id as id,
                            t.origin_id as origin_id,
                            t.title as title,
                            t.rules as rules,
                            t.photo_path as photo_path,
                            t.creator_display_name as creator_display_name,
                            t.published_at as published_at,
                            row_number() over (
                                partition by t.origin_id
                                order by t.published_at desc, t.id desc
                            ) as origin_rank
                        from activity_templates t
                        where t.deleted_at is null
                            and t.visibility = 'PUBLIC'
                            and t.lifecycle_state = 'PUBLISHED'
                            and t.published_at is not null
                    )
                    select
                        id as "id",
                        origin_id as "originId",
                        title as "title",
                        rules as "rules",
                        photo_path as "photoPath",
                        creator_display_name as "creatorDisplayName",
                        published_at as "publishedAt"
                    from ranked
                    where origin_rank = 1
                    order by published_at desc, id desc
                    limit :limit
                    """,
            nativeQuery = true
    )
    List<ShowcaseTemplateRow> findShowcaseTemplates(@Param("limit") int limit);
}
