package games.tapped.play.repository;

import java.util.UUID;

public interface TapCardLikeCountRow {

    UUID getTapCardId();

    Long getLikeCount();
}
