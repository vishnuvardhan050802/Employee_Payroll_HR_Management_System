package com.employee.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Transparent educational salary calculation. All monetary operations use BigDecimal. */
public final class PayrollCalculator {
    public record Result(BigDecimal gross, BigDecimal net) { }
    private PayrollCalculator() { }
    public static Result calculate(BigDecimal basic, BigDecimal hra, BigDecimal other, BigDecimal bonus, BigDecimal deductions) {
        BigDecimal[] values = {basic, hra, other, bonus, deductions};
        for (BigDecimal value : values) if (value == null || value.signum() < 0) throw new IllegalArgumentException("Salary components must be zero or greater.");
        BigDecimal gross = basic.add(hra).add(other).add(bonus).setScale(2, RoundingMode.HALF_UP);
        BigDecimal net = gross.subtract(deductions).setScale(2, RoundingMode.HALF_UP);
        if (net.signum() < 0) throw new IllegalArgumentException("Deductions cannot exceed gross salary.");
        return new Result(gross, net);
    }
}
