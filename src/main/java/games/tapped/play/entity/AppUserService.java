package games.tapped.play.entity;

import games.tapped.play.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AppUserService {

    private final AppUserRepository appUserRepository;

    @Transactional
    public AppUser findOrCreateGoogleUser(
            String providerSubject,
            String email
    ) {
        return appUserRepository
                .findByAuthProviderAndProviderSubject(
                        AuthProvider.GOOGLE,
                        providerSubject
                )
                .orElseGet(() -> {
                    AppUser newUser = new AppUser(
                            email,
                            AuthProvider.GOOGLE,
                            providerSubject
                    );

                    return appUserRepository.save(newUser);
                });
    }
}