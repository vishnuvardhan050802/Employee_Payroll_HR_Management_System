package com.employee.util;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

class PayrollCalculatorTest {
    private BigDecimal m(String v) { return new BigDecimal(v); }
    @Test void computesGrossAndNet() { var r=PayrollCalculator.calculate(m("30000"),m("12000"),m("2500"),m("500"),m("1000")); assertEquals(m("45000.00"),r.gross()); assertEquals(m("44000.00"),r.net()); }
    @Test void allowsZeroBonusAndDeductions() { var r=PayrollCalculator.calculate(m("1"),m("0"),m("0"),m("0"),m("0")); assertEquals(m("1.00"),r.net()); }
    @Test void roundsToTwoPlaces() { assertEquals(m("0.34"),PayrollCalculator.calculate(m("0.335"),m("0"),m("0"),m("0"),m("0")).gross()); }
    @Test void rejectsNegativeComponent() { assertThrows(IllegalArgumentException.class,()->PayrollCalculator.calculate(m("1"),m("-1"),m("0"),m("0"),m("0"))); }
    @Test void rejectsNetBelowZero() { assertThrows(IllegalArgumentException.class,()->PayrollCalculator.calculate(m("1"),m("0"),m("0"),m("0"),m("2"))); }
    @Test void acceptsExactZeroNet() { assertEquals(m("0.00"),PayrollCalculator.calculate(m("10"),m("0"),m("0"),m("0"),m("10")).net()); }
}
