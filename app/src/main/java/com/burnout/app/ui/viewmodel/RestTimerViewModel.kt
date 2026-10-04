package com.burnout.app.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class RestTimerState(
    val isRunning: Boolean = false,
    val label: String? = null,
    val totalSeconds: Int = 0,
    val remainingSeconds: Int = 0
) {
    val progress: Float
        get() = if (totalSeconds == 0) 0f else (remainingSeconds.toFloat() / totalSeconds).coerceIn(0f, 1f)
}

class RestTimerViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(RestTimerState())
    val uiState: StateFlow<RestTimerState> = _uiState.asStateFlow()

    private var timerJob: Job? = null

    fun start(seconds: Int, label: String? = null) {
        timerJob?.cancel()
        _uiState.value = RestTimerState(
            isRunning = true,
            label = label,
            totalSeconds = seconds,
            remainingSeconds = seconds
        )

        timerJob = viewModelScope.launch {
            while (_uiState.value.remainingSeconds > 0) {
                delay(1000L)
                _uiState.update { state ->
                    val newRemaining = state.remainingSeconds - 1
                    state.copy(
                        remainingSeconds = newRemaining,
                        isRunning = newRemaining > 0
                    )
                }
            }
        }
    }

    fun addSeconds(delta: Int) {
        if (!_uiState.value.isRunning) return
        _uiState.update { state ->
            val newRemaining = (state.remainingSeconds + delta).coerceAtLeast(0)
            val newTotal = (state.totalSeconds + delta).coerceAtLeast(0)
            state.copy(
                remainingSeconds = newRemaining,
                totalSeconds = newTotal,
                isRunning = newRemaining > 0
            )
        }
    }

    fun skip() {
        timerJob?.cancel()
        _uiState.value = RestTimerState()
    }

    override fun onCleared() {
        super.onCleared()
        timerJob?.cancel()
    }
}