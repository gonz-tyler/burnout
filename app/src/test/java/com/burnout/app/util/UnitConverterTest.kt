package com.burnout.app.util

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class UnitConverterTest {

    @Test
    fun testWeightConversion() {
        // Metric
        assertEquals(70.0, WeightConverter.displayWeight(70.0, UnitSystem.METRIC), 0.001)
        assertEquals(70.0, WeightConverter.saveWeight(70.0, UnitSystem.METRIC)!!, 0.001)
        assertNull(WeightConverter.saveWeight(null, UnitSystem.METRIC))
        assertNull(WeightConverter.saveWeight(0.0, UnitSystem.METRIC))
        assertEquals(0.0, WeightConverter.displayWeight(null, UnitSystem.METRIC), 0.001)
        assertEquals(0.0, WeightConverter.displayWeight(0.0, UnitSystem.METRIC), 0.001)

        // Imperial
        val convertedDisplay = WeightConverter.displayWeight(100.0, UnitSystem.IMPERIAL)
        assertEquals(220.5, convertedDisplay, 0.1)

        val convertedSave = WeightConverter.saveWeight(220.462, UnitSystem.IMPERIAL)
        assertEquals(100.0, convertedSave!!, 0.1)
    }

    @Test
    fun testLengthConversion() {
        // Metric
        assertEquals(175.0, LengthConverter.displayLength(175.0, UnitSystem.METRIC), 0.001)
        assertEquals(175.0, LengthConverter.saveLength(175.0, UnitSystem.METRIC)!!, 0.001)
        assertNull(LengthConverter.saveLength(null, UnitSystem.METRIC))
        assertNull(LengthConverter.saveLength(0.0, UnitSystem.METRIC))
        assertEquals(0.0, LengthConverter.displayLength(null, UnitSystem.METRIC), 0.001)
        assertEquals(0.0, LengthConverter.displayLength(0.0, UnitSystem.METRIC), 0.001)

        // Imperial
        val convertedDisplay = LengthConverter.displayLength(100.0, UnitSystem.IMPERIAL)
        assertEquals(39.4, convertedDisplay, 0.1)
        assertEquals(100.0, LengthConverter.saveLength(39.4, UnitSystem.IMPERIAL)!!, 0.1)
    }
}
