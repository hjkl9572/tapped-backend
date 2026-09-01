package games.tapped.profile.service;

import games.tapped.common.exception.DomainConflictException;
import games.tapped.profile.dto.HandleAvailabilityResponse;
import games.tapped.profile.dto.ProfileResponse;
import games.tapped.profile.dto.ProfileUpdateCommand;
import games.tapped.profile.dto.PublicProfileResponse;
import games.tapped.profile.entity.Profile;
import games.tapped.profile.repository.ProfileRepository;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

    @Mock
    ProfileRepository profileRepository;

    @InjectMocks
    ProfileService service;

    private Profile profileFor(UUID userId, String nickname, String bio, String avatarUrl, String handle) {
        Profile profile;
        try {
            var constructor = Profile.class.getDeclaredConstructor();
            constructor.setAccessible(true);
            profile = constructor.newInstance();
        } catch (ReflectiveOperationException exception) {
            throw new RuntimeException(exception);
        }
        ReflectionTestUtils.setField(profile, "id", UUID.randomUUID());
        ReflectionTestUtils.setField(profile, "userId", userId);
        ReflectionTestUtils.setField(profile, "nickname", nickname);
        ReflectionTestUtils.setField(profile, "bio", bio);
        ReflectionTestUtils.setField(profile, "avatarUrl", avatarUrl);
        ReflectionTestUtils.setField(profile, "handle", handle);
        return profile;
    }

    @Test
    void nicknameOnlyUpdateLeavesOtherFieldsUnchanged() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "existing bio", "https://img/a.png", "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));
        given(profileRepository.existsByNicknameIgnoreCase("new-name")).willReturn(false);

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "new-name", false, null, false, null)
        );

        assertEquals("new-name", response.nickname());
        assertEquals("existing bio", response.introduction());
        assertEquals("https://img/a.png", response.avatarUrl());
    }

    @Test
    void introductionOnlyUpdateLeavesNicknameAndAvatarUnchanged() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "kept-name", "old bio", "https://img/a.png", "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, true, "new bio", false, null)
        );

        assertEquals("kept-name", response.nickname());
        assertEquals("new bio", response.introduction());
        assertEquals("https://img/a.png", response.avatarUrl());
        verify(profileRepository, never()).existsByNicknameIgnoreCase(anyString());
    }

    @Test
    void avatarOnlyUpdateAcceptsValidHttpsUrl() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "kept-name", "kept bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, false, null, true, "https://cdn.example.com/a.png")
        );

        assertEquals("https://cdn.example.com/a.png", response.avatarUrl());
    }

    @Test
    void multiFieldUpdateAppliesAllPresentFields() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "old bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));
        given(profileRepository.existsByNicknameIgnoreCase("new-name")).willReturn(false);

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "new-name", true, "new bio", true, "https://cdn.example.com/b.png")
        );

        assertEquals("new-name", response.nickname());
        assertEquals("new bio", response.introduction());
        assertEquals("https://cdn.example.com/b.png", response.avatarUrl());
    }

    @Test
    void omittedFieldsRemainUnchangedWhenBodyIsEmpty() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "kept-name", "kept bio", "https://img/a.png", "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, false, null, false, null)
        );

        assertEquals("kept-name", response.nickname());
        assertEquals("kept bio", response.introduction());
        assertEquals("https://img/a.png", response.avatarUrl());
    }

    @Test
    void explicitNullIntroductionClearsField() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "kept-name", "old bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, true, null, false, null)
        );

        assertNull(response.introduction());
    }

    @Test
    void nicknameNoOpWhenOnlyCaseDiffers() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "SameName", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        ProfileResponse response = service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "samename", false, null, false, null)
        );

        assertEquals("SameName", response.nickname());
        verify(profileRepository, never()).existsByNicknameIgnoreCase(anyString());
    }

    @Test
    void nicknameConflictMapsToDomainConflictException() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));
        given(profileRepository.existsByNicknameIgnoreCase("taken")).willReturn(true);

        assertThrows(DomainConflictException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "taken", false, null, false, null)
        ));
    }

    @Test
    void databaseUniqueViolationRaceMapsToDomainConflictException() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));
        given(profileRepository.existsByNicknameIgnoreCase("racer")).willReturn(false);
        given(profileRepository.saveAndFlush(any())).willThrow(new DataIntegrityViolationException("dup"));

        assertThrows(DomainConflictException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "racer", false, null, false, null)
        ));
    }

    @Test
    void nicknameTooShortIsRejected() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        assertThrows(IllegalArgumentException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "a", false, null, false, null)
        ));
    }

    @Test
    void nicknameTooLongIsRejected() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        assertThrows(IllegalArgumentException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "a".repeat(31), false, null, false, null)
        ));
    }

    @Test
    void introductionTooLongIsRejected() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        assertThrows(IllegalArgumentException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, true, "x".repeat(2001), false, null)
        ));
    }

    @Test
    void nonHttpAvatarUrlIsRejected() {
        UUID userId = UUID.randomUUID();
        Profile profile = profileFor(userId, "old-name", "bio", null, "handle1");
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.of(profile));

        assertThrows(IllegalArgumentException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(false, null, false, null, true, "ftp://cdn.example.com/a.png")
        ));
    }

    @Test
    void updateForMissingProfileThrowsNotFound() {
        UUID userId = UUID.randomUUID();
        given(profileRepository.findByUserIdForUpdate(userId)).willReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class, () -> service.updateCurrentProfile(
                userId,
                new ProfileUpdateCommand(true, "new-name", false, null, false, null)
        ));
    }

    @Test
    void getByHandleReturnsProjectionForExistingHandle() {
        Profile profile = profileFor(UUID.randomUUID(), "nick", "bio", "https://img/a.png", "someHandle");
        given(profileRepository.findByHandleIgnoreCase("somehandle")).willReturn(Optional.of(profile));

        PublicProfileResponse response = service.getByHandle(" SomeHandle ");

        assertEquals("someHandle", response.handle());
        assertEquals("nick", response.nickname());
    }

    @Test
    void getByHandleForNonexistentHandleThrowsNotFound() {
        given(profileRepository.findByHandleIgnoreCase("missing")).willReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class, () -> service.getByHandle("missing"));
    }

    @Test
    void getByHandleRejectsEmptyHandle() {
        assertThrows(IllegalArgumentException.class, () -> service.getByHandle("   "));
    }

    @Test
    void checkHandleAvailabilityReturnsTrueWhenUnused() {
        given(profileRepository.existsByHandleIgnoreCase("freehandle")).willReturn(false);

        HandleAvailabilityResponse response = service.checkHandleAvailability("FreeHandle");

        assertTrue(response.available());
    }

    @Test
    void checkHandleAvailabilityReturnsFalseWhenTaken() {
        given(profileRepository.existsByHandleIgnoreCase("takenhandle")).willReturn(true);

        HandleAvailabilityResponse response = service.checkHandleAvailability("takenhandle");

        assertFalse(response.available());
    }

    @Test
    void checkHandleAvailabilityRejectsInvalidRegex() {
        assertThrows(IllegalArgumentException.class, () -> service.checkHandleAvailability("a"));
    }

    @Test
    void checkHandleAvailabilityNormalizesTrimAndLowercase() {
        given(profileRepository.existsByHandleIgnoreCase("mixedcase")).willReturn(false);

        HandleAvailabilityResponse response = service.checkHandleAvailability("  MixedCase  ");

        assertTrue(response.available());
        verify(profileRepository).existsByHandleIgnoreCase("mixedcase");
    }
}
