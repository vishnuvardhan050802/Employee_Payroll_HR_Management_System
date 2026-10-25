package com.employee.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.regex.Pattern;

public final class ValidationUtil {
    private static final Pattern EMAIL = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private ValidationUtil() { }
    public static boolean email(String value) { return value != null && EMAIL.matcher(value).matches(); }
    public static BigDecimal nonNegativeMoney(String value) {
        try { BigDecimal amount = new BigDecimal(value); if (amount.signum() < 0) throw new IllegalArgumentException("Amount cannot be negative."); return amount.setScale(2, java.math.RoundingMode.HALF_UP); }
        catch (NumberFormatException ex) { throw new IllegalArgumentException("Enter a valid amount."); }
    }
    public static boolean dateRange(LocalDate start, LocalDate end) { return start != null && end != null && !end.isBefore(start); }
}
