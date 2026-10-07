package com.burnout.app.util

import com.burnout.app.R
import org.junit.Assert.assertEquals
import org.junit.Test

class UiTextTest {

    @Test
    fun testDynamicString() {
        val text = UiText.DynamicString("Hello World")
        assertEquals("Hello World", text.value)
    }

    @Test
    fun testStringResource() {
        val res = UiText.StringResource(R.string.app_name)
        assertEquals(R.string.app_name, res.resId)
        assertEquals(0, res.args.size)

        val resWithArgs = UiText.StringResource(R.string.q1_requirement, 3)
        assertEquals(R.string.q1_requirement, resWithArgs.resId)
        assertEquals(1, resWithArgs.args.size)
        assertEquals(3, resWithArgs.args[0])
    }
}
