package games.tapped.security;

import games.tapped.play.entity.AppUser;
import games.tapped.play.entity.AppUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomOidcUserService
        implements OAuth2UserService<OidcUserRequest, OidcUser> {

    private final AppUserService appUserService;

    private final OidcUserService delegate = new OidcUserService();

    @Override
    public OidcUser loadUser(OidcUserRequest userRequest) {

        OidcUser oidcUser = delegate.loadUser(userRequest);

        AppUser appUser = appUserService.findOrCreateGoogleUser(
                oidcUser.getSubject(),
                oidcUser.getEmail()
        );

        return new AppPrincipal(
                appUser.getId(),
                oidcUser
        );
    }
}