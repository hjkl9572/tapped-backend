package games.tapped.profile.dto;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.node.NullNode;

/**
 * Captures PATCH field presence: {@code fooPresent} distinguishes "key omitted"
 * (leave unchanged) from "key supplied" (validate and apply, possibly clearing to null).
 */
public record ProfileUpdateCommand(
        boolean nicknamePresent,
        String nickname,
        boolean introductionPresent,
        String introduction,
        boolean avatarUrlPresent,
        String avatarUrl
) {

    public static ProfileUpdateCommand from(JsonNode body) {
        JsonNode node = body == null ? NullNode.getInstance() : body;
        if (node.isMissingNode() || node.isNull()) {
            return new ProfileUpdateCommand(false, null, false, null, false, null);
        }
        if (!node.isObject()) {
            throw new IllegalArgumentException("Request body must be a JSON object");
        }

        return new ProfileUpdateCommand(
                node.has("nickname"), textOrNull(node, "nickname"),
                node.has("introduction"), textOrNull(node, "introduction"),
                node.has("avatarUrl"), textOrNull(node, "avatarUrl")
        );
    }

    private static String textOrNull(JsonNode node, String field) {
        JsonNode value = node.get(field);
        if (value == null || value.isNull()) {
            return null;
        }
        if (!value.isString()) {
            throw new IllegalArgumentException(field + " must be a string");
        }

        return value.stringValue();
    }
}
