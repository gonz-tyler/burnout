package com.burnout.app.ui.pantheon

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material.icons.rounded.WorkspacePremium
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.data.PantheonGod
import com.burnout.app.data.datastore.FeatureToggles
import com.burnout.app.data.pantheonGods
import com.burnout.app.domain.model.Sex
import com.burnout.app.domain.service.StrengthRank
import com.burnout.app.domain.service.StrengthRankInfo
import com.burnout.app.domain.service.StrengthRankingService
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.util.UnitSystem
import com.burnout.app.util.WeightConverter
import com.core.designsystem.components.AnimatedLinearProgressIndicator

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PantheonScreen(
    workoutViewModel: WorkoutViewModel,
    sex: Sex,
    features: FeatureToggles,
    onBack: () -> Unit,
    bottomPadding: Dp = 0.dp,
) {
    val uiState by workoutViewModel.uiState.collectAsState()
    val unitSys = if (uiState.unitSystem == "imperial") UnitSystem.IMPERIAL else UnitSystem.METRIC
    val unitString = if (unitSys == UnitSystem.METRIC) "kg" else "lbs"

    val userBwKg = uiState.latestMeasurement?.weightKg
    val displayBw = WeightConverter.displayWeight(
        userBwKg ?: if (sex == Sex.FEMALE) StrengthRankingService.DEFAULT_FEMALE_BW_KG else StrengthRankingService.DEFAULT_MALE_BW_KG,
        unitSys,
    )

    val rankInfos = remember(pantheonGods, uiState.workoutSessions, userBwKg, sex) {
        pantheonGods.map { god ->
            val prKg = workoutViewModel.getPersonalRecord(god.lift)
            StrengthRankingService.evaluate(
                liftName = god.lift,
                prKg = prKg,
                userBodyWeightKg = userBwKg,
                sex = sex,
            )
        }
    }

    val overallRank = remember(rankInfos) {
        StrengthRankingService.calculateOverallRank(rankInfos)
    }

    var selectedGodForDetail by remember { mutableStateOf<Pair<PantheonGod, StrengthRankInfo>?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.legendary_feats_title),
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                            contentDescription = stringResource(R.string.back_description),
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            )
        },
        modifier = Modifier.fillMaxSize(),
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = 8.dp,
                bottom = 16.dp + bottomPadding,
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            // Header Greek Hero Card
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceContainerHigh,
                    ),
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(
                                Brush.verticalGradient(
                                    colors = listOf(
                                        MaterialTheme.colorScheme.primary.copy(alpha = 0.15f),
                                        Color.Transparent,
                                    ),
                                )
                            )
                            .padding(20.dp),
                    ) {
                        Column {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    imageVector = Icons.Rounded.WorkspacePremium,
                                    contentDescription = null,
                                    tint = rankColor(overallRank),
                                    modifier = Modifier.size(32.dp),
                                )
                                Spacer(Modifier.width(10.dp))
                                Column {
                                    Text(
                                        text = stringResource(R.string.pantheon_overall_rank).uppercase(),
                                        fontSize = 11.sp,
                                        letterSpacing = 1.2.sp,
                                        fontWeight = FontWeight.ExtraBold,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    )
                                    Text(
                                        text = rankName(overallRank),
                                        style = MaterialTheme.typography.headlineMedium,
                                        fontWeight = FontWeight.Black,
                                        color = rankColor(overallRank),
                                    )
                                }
                            }
                            Spacer(Modifier.height(12.dp))
                            Text(
                                text = stringResource(R.string.pantheon_header_subtitle),
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.SemiBold,
                            )
                            Spacer(Modifier.height(4.dp))
                            val sexLabel = if (sex == Sex.FEMALE) stringResource(R.string.female) else stringResource(R.string.male)
                            Text(
                                text = stringResource(R.string.bodyweight_ref, displayBw, unitString, sexLabel),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }
            }

            // List of 6 Pantheon Lifts
            items(pantheonGods.indices.toList(), key = { pantheonGods[it].lift }) { index ->
                val god = pantheonGods[index]
                val info = rankInfos[index]
                val godName = when (features.gods) {
                    "gods" -> stringResource(god.godRes)
                    "goddesses" -> stringResource(god.goddessRes)
                    else -> stringResource(god.bothRes)
                }

                GodRankCard(
                    god = god,
                    godName = godName,
                    info = info,
                    unitSystem = unitSys,
                    unitString = unitString,
                    onClick = { selectedGodForDetail = god to info },
                )
            }
        }
    }

    selectedGodForDetail?.let { (god, info) ->
        val godName = when (features.gods) {
            "gods" -> stringResource(god.godRes)
            "goddesses" -> stringResource(god.goddessRes)
            else -> stringResource(god.bothRes)
        }
        RankThresholdSheet(
            god = god,
            godName = godName,
            info = info,
            unitSystem = unitSys,
            unitString = unitString,
            sex = sex,
            onDismiss = { selectedGodForDetail = null },
        )
    }
}

@Composable
private fun GodRankCard(
    god: PantheonGod,
    godName: String,
    info: StrengthRankInfo,
    unitSystem: UnitSystem,
    unitString: String,
    onClick: () -> Unit,
) {
    val displayPr = WeightConverter.displayWeight(info.currentPrKg, unitSystem)

    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow,
        ),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    color = god.color.copy(alpha = 0.2f),
                    contentColor = god.color,
                    shape = CircleShape,
                    modifier = Modifier.size(44.dp),
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(god.icon, contentDescription = null, modifier = Modifier.size(24.dp))
                    }
                }
                Spacer(Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = godName,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = god.lift,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "%.1f $unitString".format(displayPr),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = stringResource(R.string.bodyweight_ratio, info.multiplier),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Spacer(Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.Rounded.ChevronRight,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Spacer(Modifier.height(12.dp))

            // Rank Badge & Progress bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                RankBadge(rank = info.currentRank)

                val remainingDisplay = WeightConverter.displayWeight(info.remainingKgForNextRank, unitSystem)
                Text(
                    text = if (info.nextRank != null) {
                        stringResource(R.string.next_rank_needed, remainingDisplay, unitString, rankName(info.nextRank))
                    } else {
                        stringResource(R.string.rank_maxed)
                    },
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Spacer(Modifier.height(8.dp))

            AnimatedLinearProgressIndicator(
                progress = { info.progressToNextRank },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp),
                color = rankColor(info.currentRank),
                trackColor = MaterialTheme.colorScheme.surfaceContainerHigh,
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RankThresholdSheet(
    god: PantheonGod,
    godName: String,
    info: StrengthRankInfo,
    unitSystem: UnitSystem,
    unitString: String,
    sex: Sex,
    onDismiss: () -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 16.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Rounded.AutoAwesome,
                    contentDescription = null,
                    tint = god.color,
                    modifier = Modifier.size(28.dp),
                )
                Spacer(Modifier.width(10.dp))
                Column {
                    Text(
                        text = "$godName — ${god.lift}",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = stringResource(R.string.rank_thresholds_title),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            Spacer(Modifier.height(20.dp))

            val thresholds = remember(god.lift, info.bodyWeightKg, sex) {
                StrengthRankingService.thresholdsKg(god.lift, info.bodyWeightKg, sex)
            }

            StrengthRank.entries.forEach { rank ->
                val targetKg = thresholds[rank] ?: 0.0

                val isCurrent = info.currentRank == rank
                val displayTarget = WeightConverter.displayWeight(targetKg, unitSystem)

                Surface(
                    color = if (isCurrent) rankColor(rank).copy(alpha = 0.15f) else Color.Transparent,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RankBadge(rank = rank)
                            if (isCurrent) {
                                Spacer(Modifier.width(8.dp))
                                Text(
                                    text = "★ Current",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = rankColor(rank),
                                )
                            }
                        }
                        Text(
                            text = if (rank == StrengthRank.MORTAL) "0 $unitString" else "≥ %.1f $unitString".format(displayTarget),
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp,
                        )
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
private fun RankBadge(rank: StrengthRank) {
    Surface(
        color = rankColor(rank).copy(alpha = 0.2f),
        contentColor = rankColor(rank),
        shape = RoundedCornerShape(8.dp),
    ) {
        Text(
            text = rankName(rank).uppercase(),
            fontSize = 11.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = 0.8.sp,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
        )
    }
}

@Composable
private fun rankName(rank: StrengthRank): String = when (rank) {
    StrengthRank.MORTAL -> stringResource(R.string.rank_mortal)
    StrengthRank.HERO -> stringResource(R.string.rank_hero)
    StrengthRank.DEMIGOD -> stringResource(R.string.rank_demigod)
    StrengthRank.OLYMPIAN -> stringResource(R.string.rank_olympian)
    StrengthRank.TITAN -> stringResource(R.string.rank_titan)
}

@Composable
private fun rankColor(rank: StrengthRank): Color = when (rank) {
    StrengthRank.MORTAL -> MaterialTheme.colorScheme.onSurfaceVariant
    StrengthRank.HERO -> Color(0xFFD84315) // Bronze/Amber
    StrengthRank.DEMIGOD -> Color(0xFF0288D1) // Cyan/Electric Blue
    StrengthRank.OLYMPIAN -> Color(0xFF7B1FA2) // Royal Purple
    StrengthRank.TITAN -> Color(0xFFFF8F00) // Gold/Titan Orange
}
