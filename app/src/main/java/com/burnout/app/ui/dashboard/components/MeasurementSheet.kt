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
                Text("Log Measurements", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Rounded.Close, contentDescription = "Close")
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
                            Text("Date", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                            Text(DateFormat.format("MMM d, yyyy", selectedDateMillis).toString(), style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold)
                        }
                    }
                    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))
                }

                item { SectionTitle("Body Composition") }
                item {
                    Row {
                        DialogInput(weight, { weight = it }, "Weight ($weightUnitString)", Modifier.weight(1f))
                        Spacer(Modifier.width(12.dp))
                        DialogInput(fat, { fat = it }, "Body Fat %", Modifier.weight(1f))

                    }
                }
                if (goalsEnabled) {
                    item { SectionTitle("Goal Body Fat") }
                    item { DialogInput(goalFat, { goalFat = it}, "Goal Body Fat %", Modifier.weight(1f)) }
                }
                item { SectionTitle("Reference") }
                item { DialogInput(wrist, { wrist = it }, "Wrist ($lengthUnitString) - anchor") }
                item { SectionTitle("Torso") }
                item { DialogInput(neck, { neck = it }, "Neck ($lengthUnitString)") }
                item { DialogInput(shoulders, { shoulders = it }, "Shoulders ($lengthUnitString)") }
                item { DialogInput(chest, { chest = it }, "Chest ($lengthUnitString)") }
                item { DialogInput(waist, { waist = it }, "Waist ($lengthUnitString)") }
                item { DialogInput(hips, { hips = it }, "Hips ($lengthUnitString)") }
                item { DialogInput(glutes, { glutes = it }, "Glutes ($lengthUnitString) - fullest point") }
                item { SectionTitle("Arms (L/R)") }
                item {
                    Row {
                        DialogInput(lBicep, { lBicep = it }, "L Bicep", Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rBicep, { rBicep = it }, "R Bicep", Modifier.weight(1f))
                    }
                }
                item {
                    Row {
                        DialogInput(lForearm, { lForearm = it }, "L Forearm", Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rForearm, { rForearm = it }, "R Forearm", Modifier.weight(1f))
                    }
                }
                item { SectionTitle("Legs (L/R)") }
                item {
                    Row {
                        DialogInput(lThigh, { lThigh = it }, "L Thigh", Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rThigh, { rThigh = it }, "R Thigh", Modifier.weight(1f))
                    }
                }
                item {
                    Row {
                        DialogInput(lCalf, { lCalf = it }, "L Calf", Modifier.weight(1f))
                        Spacer(Modifier.width(8.dp))
                        DialogInput(rCalf, { rCalf = it }, "R Calf", Modifier.weight(1f))
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
                    Text("SAVE MEASUREMENTS", fontWeight = FontWeight.Black, letterSpacing = 1.sp)
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