package com.burnout.app.ui.viewmodel

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class RestTimerViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun teardown() {
        Dispatchers.resetMain()
    }

    @Test
    fun initialStateIsIdle() = runTest {
        val viewModel = RestTimerViewModel()
        val state = viewModel.uiState.value
        assertFalse(state.isRunning)
        assertEquals(0, state.totalSeconds)
        assertEquals(0, state.remainingSeconds)
        assertEquals(0f, state.progress)
    }

    @Test
    fun startTimerSetsStateAndDecrements() = runTest {
        val viewModel = RestTimerViewModel()
        viewModel.start(10, "Rest")

        var state = viewModel.uiState.value
        assertTrue(state.isRunning)
        assertEquals(10, state.totalSeconds)
        assertEquals(10, state.remainingSeconds)
        assertEquals("Rest", state.label)

        // Advance time by 2 seconds and run pending tasks
        testDispatcher.scheduler.advanceTimeBy(2000L)
        testDispatcher.scheduler.runCurrent()

        state = viewModel.uiState.value
        assertEquals(8, state.remainingSeconds)
        assertTrue(state.isRunning)
    }

    @Test
    fun addSecondsUpdatesTimer() = runTest {
        val viewModel = RestTimerViewModel()
        viewModel.start(10, "Rest")
        viewModel.addSeconds(5)

        val state = viewModel.uiState.value
        assertEquals(15, state.totalSeconds)
        assertEquals(15, state.remainingSeconds)
    }

    @Test
    fun skipTimerResetsState() = runTest {
        val viewModel = RestTimerViewModel()
        viewModel.start(10, "Rest")
        viewModel.skip()

        val state = viewModel.uiState.value
        assertFalse(state.isRunning)
        assertEquals(0, state.totalSeconds)
        assertEquals(0, state.remainingSeconds)
    }
}
