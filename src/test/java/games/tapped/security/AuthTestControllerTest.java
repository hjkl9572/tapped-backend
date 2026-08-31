package games.tapped.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.oidcLogin;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class AuthTestControllerTest {

    @Autowired
    MockMvc mockMvc;

    @Test
    void authenticatedOidcUserCanAccessMe() throws Exception {
        mockMvc.perform(
                        get("/test/me")
                                .with(oidcLogin()
                                        .idToken(token -> token
                                                .subject("google-sub-123")
                                                .claim("email", "test@example.com")
                                        )
                                )
                )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sub").value("google-sub-123"))
                .andExpect(jsonPath("$.email").value("test@example.com"));
    }

    @Test
    void anonymousUserCannotAccessMe() throws Exception {
        mockMvc.perform(get("/test/me"))
                .andExpect(status().isUnauthorized());
    }
}
