package games.tapped.play.repository;

import games.tapped.play.entity.ActivityTemplate;
import games.tapped.play.entity.TemplateLifecycleState;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@Transactional
class ActivityTemplateRepositoryTest {

    @Autowired
    ActivityTemplateRepository repository;

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
}