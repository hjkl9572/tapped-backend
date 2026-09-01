package games.tapped.profile.controller;

import tools.jackson.databind.JsonNode;
import games.tapped.profile.dto.HandleAvailabilityResponse;
import games.tapped.profile.dto.ProfileResponse;
import games.tapped.profile.dto.ProfileUpdateCommand;
import games.tapped.profile.dto.PublicProfileResponse;
import games.tapped.profile.service.ProfileService;
import games.tapped.security.AppJwtPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profiles")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @PatchMapping("/current")
    public ProfileResponse updateCurrent(
            @RequestBody(required = false) JsonNode body,
            @AuthenticationPrincipal AppJwtPrincipal principal
    ) {
        return profileService.updateCurrentProfile(
                principal.userId(),
                ProfileUpdateCommand.from(body)
        );
    }

    @GetMapping("/by-handle/{handle}")
    public PublicProfileResponse getByHandle(@PathVariable String handle) {
        return profileService.getByHandle(handle);
    }

    @GetMapping("/handles/{handle}/availability")
    public HandleAvailabilityResponse checkHandleAvailability(@PathVariable String handle) {
        return profileService.checkHandleAvailability(handle);
    }
}
