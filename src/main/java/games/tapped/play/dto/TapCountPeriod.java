package games.tapped.play.dto;

public enum TapCountPeriod {
    WEEK;

    public static TapCountPeriod fromApiValue(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("period is required");
        }

        try {
            return TapCountPeriod.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Unsupported period: " + value);
        }
    }
}
