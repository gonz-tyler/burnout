package com.burnout.app.ui.dashboard.components

import android.text.format.DateFormat
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CalendarToday
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.data.local.entity.BodyMeasurement
import com.burnout.app.domain.model.Style
import com.burnout.app.ui.components.ModernDatePickerDialog
import com.burnout.app.util.LengthConverter
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import com.burnout.app.R
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MeasurementSheet(
    latest: BodyMeasurement?,
    unitSystem: UnitSystem,
    goalsEnabled: Boolean,
    onDismiss: () -> Unit,
    onSave: (BodyMeasurement) -> Unit,
    sheetState: SheetState = rememberModalBottomSheetState(),
) {
    val weightUnitString = if (unitSystem == UnitSystem.METRIC) "kg" else "lbs"
    val lengthUnitString = if (unitSystem == UnitSystem.METRIC) "cm" else "in"

    fun formatVal(v: Double?): String {
        if (v == null || v == 0.0) return ""
        return "%.1f".format(v).removeSuffix(".0")
    }

    var selectedDateMillis by remember { mutableStateOf(System.currentTimeMillis()) }
    var showDatePicker by remember { mutableStateOf(false) }

    var weight by remember { mutableStateOf(formatVal(latest?.weightKg?.let { WeightConverter.displayWeight(it, unitSystem) })) }
    var fat by remember { mutableStateOf(formatVal(latest?.bodyFatPercentage)) }
    var goalFat by remember { mutableStateOf(formatVal(latest?.goalBodyFatPercentage)) }
    var wrist by remember { mutableStateOf(formatVal(latest?.wristSize?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var neck by remember { mutableStateOf(formatVal(latest?.neck?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var shoulders by remember { mutableStateOf(formatVal(latest?.shoulders?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var chest by remember { mutableStateOf(formatVal(latest?.chest?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var waist by remember { mutableStateOf(formatVal(latest?.waist?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var hips by remember { mutableStateOf(formatVal(latest?.hips?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var glutes by remember { mutableStateOf(formatVal(latest?.glutes?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var lBicep by remember { mutableStateOf(formatVal(latest?.leftBicep?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var rBicep by remember { mutableStateOf(formatVal(latest?.rightBicep?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var lForearm by remember { mutableStateOf(formatVal(latest?.leftForearm?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var rForearm by remember { mutableStateOf(formatVal(latest?.rightForearm?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var lThigh by remember { mutableStateOf(formatVal(latest?.leftThigh?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var rThigh by remember { mutableStateOf(formatVal(latest?.rightThigh?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var lCalf by remember { mutableStateOf(formatVal(latest?.leftCalf?.let { LengthConverter.displayLength(it, unitSystem) })) }
    var rCalf by remember { mutableStateOf(formatVal(latest?.rightCalf?.let { LengthConverter.displayLength(it, unitSystem) })) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = MaterialTheme.colorScheme.surfaceContainerHigh,
        contentWindowInsets = { WindowInsets.navigationBars }
    ) {
        Column(modifier = Modifier.fillMaxHeight(0.9f)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, top = 12.dp, end = 12.dp, bottom = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    stringResource(R.string.log_measurement), style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Rounded.Close, contentDescription = stringResource(R.string.close))
                }
            }
            HorizontalDivider()

            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(0.dp),
            ) {
                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 16.dp)
                            .clickable { showDatePicker = true },
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Rounded.CalendarToday, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text(stringResource(R.string.date), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                            Text(DateFormat.format("MMM d, yyyy", selectedDateMillis).toString(), style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold)
                        }
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))
                }

                item { SectionTitle(stringResource(R.string.body_composition)) }
                item {
                    Row {
                        DialogInput(weight, { weight = it }, stringResource(R.string.weight_unit_label, weightUnitString), Modifier.weight(1f))
                        Spacer(Modifier.width(12.dp))
                        DialogInput(fat, { fat = it }, stringResource(R.string.body_fat_percent), Modifier.weight(1f))

                    }
                }
                if (goalsEnabled) {
                    item { SectionTitle(stringResource(R.string.goal_bf)) }
                    item { DialogInput(goalFat, { goalFat = it}, stringResource(R.string.goal_bf_percent), Modifier.weight(1f)) }
                }
                item { SectionTitle(stringResource(R.string.reference)) }
                item { DialogInput(wrist, { wrist = it }, stringResource(R.string.anchor_wrist_label, lengthUnitString)) }
                item { SectionTitle(stringResource(R.string.torso)) }
                item { DialogInput(neck, { neck = it }, stringResource(R.string.neck_unit, lengthUnitString)) }
                item { DialogInput(shoulders, { shoulders = it }, stringResource(R.string.shoulders_unit, lengthUnitString)) }
                item { DialogInput(chest, { chest = it }, stringResource(R.string.chest_unit, lengthUnitString)) }
                item { DialogInput(waist, { waist = it }, stringResource(R.string.waist_unit, lengthUnitString)) }
                item { DialogInput(hips, { hips = it }, stringResource(R.string.hips_unit, lengthUnitString)) }
                item { DialogInput(glutes, { glutes = it }, stringResource(R.string.glutes_unit, lengthUnitString)) }
                item { SectionTitle(stringResource(R.string.arms_lr)) }
                item {
                    Row {
                        DialogInput(lBicep, { lBicep = it }, stringResource(R.string.l_bicep), Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rBicep, { rBicep = it }, stringResource(R.string.r_bicep), Modifier.weight(1f))
                    }
                }
                item {
                    Row {
                        DialogInput(lForearm, { lForearm = it }, stringResource(R.string.l_forearm), Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rForearm, { rForearm = it }, stringResource(R.string.r_forearm), Modifier.weight(1f))
                    }
                }
                item { SectionTitle(stringResource(R.string.legs_lr)) }
                item {
                    Row {
                        DialogInput(lThigh, { lThigh = it }, stringResource(R.string.l_thigh), Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rThigh, { rThigh = it }, stringResource(R.string.r_thigh), Modifier.weight(1f))
                    }
                }
                item {
                    Row {
                        DialogInput(lCalf, { lCalf = it }, stringResource(R.string.l_calf), Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rCalf, { rCalf = it }, stringResource(R.string.r_calf), Modifier.weight(1f))
                    }
                }
            }

            Surface(
                modifier = Modifier.fillMaxWidth(),
                tonalElevation = 8.dp,
                shadowElevation = 8.dp
            ) {
                Button(
                    onClick = {
                        val newMeasurement = BodyMeasurement(
                            id = UUID.randomUUID().toString(),
                            date = selectedDateMillis,
                            weightKg = WeightConverter.saveWeight(weight.toDoubleOrNull(), unitSystem),
                            bodyFatPercentage = fat.toDoubleOrNull(),
                            goalBodyFatPercentage = goalFat.toDoubleOrNull(),
                            neck = LengthConverter.saveLength(neck.toDoubleOrNull(), unitSystem),
                            shoulders = LengthConverter.saveLength(shoulders.toDoubleOrNull(), unitSystem),
                            chest = LengthConverter.saveLength(chest.toDoubleOrNull(), unitSystem),
                            waist = LengthConverter.saveLength(waist.toDoubleOrNull(), unitSystem),
                            hips = LengthConverter.saveLength(hips.toDoubleOrNull(), unitSystem),
                            glutes = LengthConverter.saveLength(glutes.toDoubleOrNull(), unitSystem),
                            leftBicep = LengthConverter.saveLength(lBicep.toDoubleOrNull(), unitSystem),
                            rightBicep = LengthConverter.saveLength(rBicep.toDoubleOrNull(), unitSystem),
                            leftForearm = LengthConverter.saveLength(lForearm.toDoubleOrNull(), unitSystem),
                            rightForearm = LengthConverter.saveLength(rForearm.toDoubleOrNull(), unitSystem),
                            leftThigh = LengthConverter.saveLength(lThigh.toDoubleOrNull(), unitSystem),
                            rightThigh = LengthConverter.saveLength(rThigh.toDoubleOrNull(), unitSystem),
                            leftCalf = LengthConverter.saveLength(lCalf.toDoubleOrNull(), unitSystem),
                            rightCalf = LengthConverter.saveLength(rCalf.toDoubleOrNull(), unitSystem),
                            wristSize = LengthConverter.saveLength(wrist.toDoubleOrNull(), unitSystem),
                        )
                        onSave(newMeasurement)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp)
                        .height(56.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
                ) {
                    Text(stringResource(R.string.save_measurements).uppercase(), fontWeight = FontWeight.Black, letterSpacing = 1.sp)
                }
            }
        }
    }

    if (showDatePicker) {
        ModernDatePickerDialog(
            initialSelectedDateMillis = selectedDateMillis,
            onDismiss = { showDatePicker = false },
            onConfirm = { date ->
                if (date != null) selectedDateMillis = date
                showDatePicker = false
            }
        )
    }
}

@Composable
private fun SectionTitle(title: String) {
    Text(
        text = title,
        fontWeight = FontWeight.Bold,
        color = MaterialTheme.colorScheme.primary,
        fontSize = 13.sp,
        modifier = Modifier.padding(top = 12.dp, bottom = 8.dp),
    )
}

@Composable
private fun DialogInput(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(keyboardType = KeyboardType.Decimal),
        modifier = modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp),
        singleLine = true,
    )
}