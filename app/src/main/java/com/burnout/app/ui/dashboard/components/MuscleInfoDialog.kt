package com.burnout.app.ui.dashboard.components

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import com.burnout.app.R

/**
 * "About Muscle Analysis" explainer dialog. Port of muscle_info_dialog.dart.
 * Show/hide state is owned by the caller (e.g. `var showInfo by remember { mutableStateOf(false) }`),
 * mirroring Flutter's imperative showDialog() call site.
 */
@Composable
fun MuscleInfoDialog(
    onDismiss: () -> Unit,
    title: String = stringResource(R.string.about_muscle_analysis),
    body: String = stringResource(R.string.muscle_analysis_body),
    okLabel: String = stringResource(R.string.okay),
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
