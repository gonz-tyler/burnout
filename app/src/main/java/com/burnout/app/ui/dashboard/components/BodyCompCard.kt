package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Scale
import androidx.compose.material.icons.rounded.WaterDrop
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.local.entity.BodyMeasurement
import com.burnout.app.domain.model.Style
import com.burnout.app.ui.theme.AppTheme
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter

/**
 * Card showing current weight / body-fat, plus derived lean-body-mass and
 * goal-weight figures once both inputs are available. Port of body_comp_card.dart.
 */
@Composable
fun BodyCompCard(
    measurements: List<BodyMeasurement>,
    unitSystem: UnitSystem,
    goalsEnabled: Boolean,
) {
    val latest = measurements.lastOrNull()
    val weight = latest?.weightKg
    val bf = latest?.bodyFatPercentage
    val goalbf = latest?.goalBodyFatPercentage

    val weightUnitString = if (unitSystem == UnitSystem.METRIC) "kg" else "lbs"

    var lbmStr = "--"
    var goalWeightStr = "--"

    if (weight != null && bf != null) {
        val lbm = weight * (1 - (bf / 100))
        if (goalbf != null) {
            val goal = lbm / (1 - (goalbf / 100))
            val displayGoal = WeightConverter.displayWeight(goal, unitSystem)
            goalWeightStr = "%.1f $weightUnitString".format(displayGoal)
        }



        val displayLbm = WeightConverter.displayWeight(lbm, unitSystem)


        lbmStr = "%.1f $weightUnitString".format(displayLbm)

    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceContainerHigh, RoundedCornerShape(AppTheme.radiusL))
            .padding(20.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = androidx.compose.foundation.layout.Arrangement.SpaceAround,
        ) {
            CompItem(
                label = stringResource(R.string.weight),//"Weight",
                value = weight?.let { WeightConverter.displayWeight(it, unitSystem) },
                unit = weightUnitString,
                icon = Icons.Rounded.Scale,
            )
            androidx.compose.foundation.layout.Box(
                modifier = Modifier
                    .width(1.dp)
                    .height(40.dp)
                    .background(MaterialTheme.colorScheme.outlineVariant),
            )
            CompItem(
                label = stringResource(R.string.body_fat),//"Body Fat",
                value = bf,
                unit = "%",
                icon = Icons.Rounded.WaterDrop,
            )
        }

        if (weight != null && bf != null) {
            Spacer(Modifier.height(16.dp))
            HorizontalDivider()
            Spacer(Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = androidx.compose.foundation.layout.Arrangement.SpaceBetween,
            ) {
                SubCompItem(label = stringResource(R.string.lean_body_mass), value = lbmStr)
                if (goalbf != null && goalsEnabled) {
                    SubCompItem(label = stringResource(R.string.goal_weight, goalbf), value = goalWeightStr)
                }
            }
        }
    }
}

@Composable
private fun CompItem(label: String, value: Double?, unit: String, icon: ImageVector) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.padding(bottom = 8.dp))
        Row(verticalAlignment = Alignment.Bottom) {
            if (value != null && value > 0) {
                DelayedAnimatedNumber(
                    value = value,
                    formatter = { "%.1f".format(it) },
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                )
            } else {
                Text("--", fontSize = 24.sp, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.width(2.dp))
            Text(unit, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant, fontWeight = FontWeight.SemiBold)
        }
        Text(label, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun SubCompItem(label: String, value: String) {
    Column(horizontalAlignment = Alignment.Start) {
        Text(label, fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant, fontWeight = FontWeight.SemiBold)
        Text(value, fontSize = 15.sp, fontWeight = FontWeight.Bold)
    }
}
