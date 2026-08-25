package games.tapped.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final JwtTokenService jwtTokenService;


    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication)
            throws IOException, ServletException {

        AppPrincipal principal =
                (AppPrincipal)authentication.getPrincipal();

        String token = jwtTokenService.createAccessToken(
                principal.getUserId()
        );

        response.setContentType("application/json");
        response.getWriter().write("""
                {
                    "accessToken": "%s"
                }
                """.formatted(token));

    }
}
