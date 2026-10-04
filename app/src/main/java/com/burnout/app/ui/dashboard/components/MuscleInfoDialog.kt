package com.burnout.app.ui.dashboard.components

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable

/**
 * "About Muscle Analysis" explainer dialog. Port of muscle_info_dialog.dart.
 * Show/hide state is owned by the caller (e.g. `var showInfo by remember { mutableStateOf(false) }`),
 * mirroring Flutter's imperative showDialog() call site.
 */
@Composable
fun MuscleInfoDialog(
    onDismiss: () -> Unit,
    title: String = "About Muscle Analysis",
    body: String = "Intensity is calculated from your logged training volume " +
        "(weight × reps) per muscle group, normalized against your hardest-worked muscle.",
    okLabel: String = "OK",
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = { Text(body) },
        confirmButton = {
            TextButton(onClick = onDismiss) { Text(okLabel) }
        },
    )
}
