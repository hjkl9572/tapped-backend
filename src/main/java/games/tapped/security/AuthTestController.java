package games.tapped.security;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/test")
public class AuthTestController {

    @GetMapping("/me")
    public Map<String, Object> me(
            @AuthenticationPrincipal OidcUser user
    ) {
        return Map.of(
                "sub", user.getSubject(),
                "email", user.getEmail()
        );
    }

    // casting error
    @GetMapping("/jwt")
    public Map<String, Object> jwt(UsernamePasswordAuthenticationToken authentication) {
        AppJwtPrincipal principal = (AppJwtPrincipal) authentication.getPrincipal();
        return Map.of(
                "userId", principal.userId()
        );
    }

    @GetMapping("/user")
    public UUID currentUser(
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return principal.userId();
    }

}