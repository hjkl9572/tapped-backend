package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.AppUserService;
import games.tapped.play.entity.TemplateLifecycleState;
import games.tapped.play.entity.TemplateVisibility;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@Transactional
class ActivityTemplateRepositoryTest {

    @Autowired
    ActivityTemplateRepository repository;

    @Autowired
    AppUserService appUserService;

    private UUID newOwner() {
        String subject = UUID.randomUUID().toString();
        return appUserService.findOrCreateGoogleUser(subject, subject + "@example.com").getId();
    }

    @Test
    void savesAndLoadsActivityTemplate() {
        UUID userId = UUID.fromString("ad6178be-e5f6-4c61-8228-e2c025d360cf");

        ActivityTemplate template =
                ActivityTemplate.createRoot(
                        userId,
                        "Run every day",
                        "Run at least 20 minutes"
                );

        repository.saveAndFlush(template);

        ActivityTemplate found = repository
                .findById(template.getId())
                .orElseThrow();

        assertEquals(template.getId(), found.getOriginId());
        assertEquals("Run every day", found.getTitle());
        assertEquals(userId, found.getCreatedBy());
        assertEquals(TemplateLifecycleState.DRAFT,
                found.getLifecycleState());
    }

    private ActivityTemplate publishedTemplate(
            UUID id,
            UUID createdBy,
            String title,
            OffsetDateTime publishedAt
    ) {
        return ActivityTemplate.createRoot(
                id, createdBy, title, "Rules",
                TemplateVisibility.PUBLIC, TemplateLifecycleState.PUBLISHED, null, publishedAt
        );
    }

    private void setOriginId(ActivityTemplate template, UUID originId) {
        org.springframework.test.util.ReflectionTestUtils.setField(template, "originId", originId);
    }

    @Test
    void showcaseReturnsOnlyPublicPublishedTemplates() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate published = publishedTemplate(
                UUID.randomUUID(), owner, "Published", now
        );
        repository.saveAndFlush(published);

        ActivityTemplate draft = ActivityTemplate.createRoot(owner, "Draft", "Rules");
        repository.saveAndFlush(draft);

        ActivityTemplate privateTemplate = ActivityTemplate.createRoot(
                UUID.randomUUID(), owner, "Private", "Rules",
                TemplateVisibility.PRIVATE, TemplateLifecycleState.PUBLISHED, null, now
        );
        repository.saveAndFlush(privateTemplate);

        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(50);

        assertTrue(rows.stream().anyMatch(r -> r.getId().equals(published.getId())));
        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(draft.getId())));
        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(privateTemplate.getId())));
    }

    @Test
    void showcaseExcludesSoftDeletedTemplates() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate template = publishedTemplate(UUID.randomUUID(), owner, "Deleted", now);
        template.softDelete(owner);
        repository.saveAndFlush(template);

        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(50);

        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(template.getId())));
    }

    @Test
    void showcaseReturnsOnlyMostRecentlyPublishedVersionPerOriginId() {
        UUID owner = newOwner();
        UUID originId = UUID.randomUUID();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);

        ActivityTemplate older = publishedTemplate(originId, owner, "Run 5km", now.minusDays(2));
        repository.saveAndFlush(older);

        ActivityTemplate newer = publishedTemplate(UUID.randomUUID(), owner, "Run 10km", now);
        setOriginId(newer, originId);
        repository.saveAndFlush(newer);

        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(50);

        long matchingOrigin = rows.stream().filter(r -> r.getId().equals(older.getId()) || r.getId().equals(newer.getId())).count();
        assertEquals(1, matchingOrigin);
        assertTrue(rows.stream().anyMatch(r -> r.getId().equals(newer.getId())));
        assertTrue(rows.stream().noneMatch(r -> r.getId().equals(older.getId())));
    }

    @Test
    void showcaseOrdersByPublishedAtDescending() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate older = publishedTemplate(UUID.randomUUID(), owner, "Older", now.minusDays(1));
        repository.saveAndFlush(older);
        ActivityTemplate newer = publishedTemplate(UUID.randomUUID(), owner, "Newer", now);
        repository.saveAndFlush(newer);

        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(50);

        int newerIndex = indexOfTemplate(rows, newer.getId());
        int olderIndex = indexOfTemplate(rows, older.getId());
        assertTrue(newerIndex < olderIndex, "more recently published template should sort first");
    }

    @Test
    void showcaseRespectsTheRequestedLimit() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        for (int i = 0; i < 3; i++) {
            repository.saveAndFlush(publishedTemplate(UUID.randomUUID(), owner, "Template " + i, now));
        }

        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(2);

        assertEquals(2, rows.size());
    }

    @Test
    void showcaseReturnsEmptyWhenNoTemplatesEligible() {
        List<ShowcaseTemplateRow> rows = repository.findShowcaseTemplates(50);

        assertTrue(rows.isEmpty());
    }

    @Test
    void showcaseRowExposesTheFullResponseProjection() {
        UUID owner = newOwner();
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        ActivityTemplate template = publishedTemplate(UUID.randomUUID(), owner, "Run every day", now);
        repository.saveAndFlush(template);

        ShowcaseTemplateRow row = repository.findShowcaseTemplates(50).stream()
                .filter(r -> r.getId().equals(template.getId()))
                .findFirst()
                .orElseThrow();

        assertEquals(template.getId(), row.getId());
        assertEquals(template.getOriginId(), row.getOriginId());
        assertEquals("Run every day", row.getTitle());
        assertEquals("Rules", row.getRules());
        assertTrue(row.getPublishedAt() != null);
    }

    private int indexOfTemplate(List<ShowcaseTemplateRow> rows, UUID id) {
        for (int i = 0; i < rows.size(); i++) {
            if (rows.get(i).getId().equals(id)) {
                return i;
            }
        }
        throw new AssertionError("template not found in showcase rows: " + id);
    }
}