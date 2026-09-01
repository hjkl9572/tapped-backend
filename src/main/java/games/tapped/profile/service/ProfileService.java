package games.tapped.profile.service;

import games.tapped.common.exception.DomainConflictException;
import games.tapped.profile.dto.HandleAvailabilityResponse;
import games.tapped.profile.dto.ProfileResponse;
import games.tapped.profile.dto.ProfileUpdateCommand;
import games.tapped.profile.dto.PublicProfileResponse;
import games.tapped.profile.entity.Profile;
import games.tapped.profile.repository.ProfileRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.UUID;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private static final int NICKNAME_MIN_LENGTH = 2;
    private static final int NICKNAME_MAX_LENGTH = 30;
    private static final int INTRODUCTION_MAX_LENGTH = 2000;
    private static final int AVATAR_URL_MAX_LENGTH = 2048;
    private static final Pattern AVATAR_URL_PATTERN = Pattern.compile("^https?://.*");
    private static final Pattern CONTROL_CHAR_PATTERN = Pattern.compile("[\\x00-\\x1F\\x7F]");
    private static final Pattern HANDLE_PATTERN = Pattern.compile("^[a-z0-9_]{3,20}$");

    private final ProfileRepository profileRepository;

    @Transactional
    public ProfileResponse updateCurrentProfile(UUID userId, ProfileUpdateCommand command) {
        Profile profile = profileRepository.findByUserIdForUpdate(userId)
                .orElseThrow(() -> new EntityNotFoundException("Profile not found"));

        if (command.nicknamePresent()) {
            applyNickname(profile, command.nickname());
        }
        if (command.introductionPresent()) {
            profile.changeIntroduction(validatedIntroduction(command.introduction()));
        }
        if (command.avatarUrlPresent()) {
            profile.changeAvatar(validatedAvatarUrl(command.avatarUrl()));
        }

        try {
            profileRepository.saveAndFlush(profile);
        } catch (DataIntegrityViolationException exception) {
            throw new DomainConflictException("That nickname is already in use.");
        }

        return toResponse(profile);
    }

    @Transactional(readOnly = true)
    public PublicProfileResponse getByHandle(String rawHandle) {
        String handle = normalizeHandleForLookup(rawHandle);
        if (handle.isEmpty()) {
            throw new IllegalArgumentException("Handle is required.");
        }

        Profile profile = profileRepository.findByHandleIgnoreCase(handle)
                .orElseThrow(() -> new EntityNotFoundException("Profile not found."));

        return toPublicResponse(profile);
    }

    @Transactional(readOnly = true)
    public HandleAvailabilityResponse checkHandleAvailability(String rawHandle) {
        String handle = normalizeHandleForLookup(rawHandle);
        if (!HANDLE_PATTERN.matcher(handle).matches()) {
            throw new IllegalArgumentException("Invalid handle.");
        }

        return new HandleAvailabilityResponse(!profileRepository.existsByHandleIgnoreCase(handle));
    }

    private void applyNickname(Profile profile, String rawNickname) {
        String nickname = normalizeRequiredNickname(rawNickname);
        String currentNickname = profile.getNickname();
        if (currentNickname != null && currentNickname.equalsIgnoreCase(nickname)) {
            return;
        }
        if (profileRepository.existsByNicknameIgnoreCase(nickname)) {
            throw new DomainConflictException("That nickname is already in use.");
        }

        profile.changeNickname(nickname);
    }

    private String normalizeRequiredNickname(String value) {
        String trimmed = value == null ? "" : value.trim();
        if (trimmed.length() < NICKNAME_MIN_LENGTH || trimmed.length() > NICKNAME_MAX_LENGTH) {
            throw new IllegalArgumentException(
                    "nickname must be between " + NICKNAME_MIN_LENGTH
                            + " and " + NICKNAME_MAX_LENGTH + " characters"
            );
        }

        return trimmed;
    }

    private String validatedIntroduction(String value) {
        if (value == null) {
            return null;
        }
        if (value.trim().length() > INTRODUCTION_MAX_LENGTH) {
            throw new IllegalArgumentException(
                    "introduction must be at most " + INTRODUCTION_MAX_LENGTH + " characters"
            );
        }

        return value;
    }

    private String validatedAvatarUrl(String value) {
        if (value == null) {
            return null;
        }
        if (value.length() > AVATAR_URL_MAX_LENGTH
                || !AVATAR_URL_PATTERN.matcher(value).matches()
                || CONTROL_CHAR_PATTERN.matcher(value).find()) {
            throw new IllegalArgumentException("avatarUrl is invalid");
        }

        return value;
    }

    private String normalizeHandleForLookup(String rawHandle) {
        return rawHandle == null ? "" : rawHandle.trim().toLowerCase(Locale.ROOT);
    }

    private ProfileResponse toResponse(Profile profile) {
        return new ProfileResponse(
                profile.getUserId(),
                profile.getHandle(),
                profile.getNickname(),
                profile.getBio(),
                profile.getAvatarUrl()
        );
    }

    private PublicProfileResponse toPublicResponse(Profile profile) {
        return new PublicProfileResponse(
                profile.getHandle(),
                profile.getNickname(),
                profile.getBio(),
                profile.getAvatarUrl()
        );
    }
}
