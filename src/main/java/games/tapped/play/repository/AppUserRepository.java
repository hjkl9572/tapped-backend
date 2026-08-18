package games.tapped.play.repository;

import games.tapped.play.entity.AppUser;
import games.tapped.play.entity.AuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {

    Optional<AppUser> findByAuthProviderAndProviderSubject(
            AuthProvider authProvider,
            String providerSubject
    );
}
