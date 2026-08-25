package games.tapped.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.security.converter.RsaKeyConverters;

import java.io.IOException;
import java.io.InputStream;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;


@Configuration
@Slf4j
public class JwtKeyConfig {

    @Bean
    RSAPublicKey rsaPublicKey(
            @Value("${spring.jwt.public-key}") Resource resource
    ) throws IOException {

        try (InputStream inputStream = resource.getInputStream()) {
            return RsaKeyConverters.x509().convert(inputStream);
        }
    }

    @Bean
    RSAPrivateKey rsaPrivateKey(
            @Value("${spring.jwt.private-key}") Resource resource
    ) throws IOException {
        try (InputStream input = resource.getInputStream()) {
            return RsaKeyConverters.pkcs8().convert(input);
        }
    }
}