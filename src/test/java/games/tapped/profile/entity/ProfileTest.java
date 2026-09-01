package games.tapped.profile.entity;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class ProfileTest {

    @Test
    void changeNicknameTrimsValue() {
        Profile profile = new Profile();

        profile.changeNickname("  trimmed  ");

        assertEquals("trimmed", profile.getNickname());
    }

    @Test
    void changeNicknameCollapsesBlankToNull() {
        Profile profile = new Profile();

        profile.changeNickname("   ");

        assertNull(profile.getNickname());
    }

    @Test
    void changeIntroductionCollapsesEmptyStringToNull() {
        Profile profile = new Profile();

        profile.changeIntroduction("");

        assertNull(profile.getBio());
    }

    @Test
    void changeAvatarAcceptsExplicitNullAsClear() {
        Profile profile = new Profile();
        profile.changeAvatar("https://cdn.example.com/a.png");

        profile.changeAvatar(null);

        assertNull(profile.getAvatarUrl());
    }
}
