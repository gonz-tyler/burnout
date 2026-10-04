package com.burnout.app.ui.workout

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.rounded.DirectionsRun
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.rounded.*
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.burnout.app.R
import com.burnout.app.domain.service.Labor
import com.burnout.app.domain.service.LaborsService
import com.burnout.app.domain.service.Quest
import com.burnout.app.domain.service.QuestsService
import com.burnout.app.ui.viewmodel.WorkoutViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CampaignScreen(
    workoutViewModel: WorkoutViewModel,
    onNavigateBack: () -> Unit
) {
    val uiState by workoutViewModel.uiState.collectAsState()

    val labors = LaborsService.checkLabors(
        uiState = uiState,
        getPersonalRecord = workoutViewModel::getPersonalRecord
    )

    val quests = QuestsService.checkWeeklyQuests(
        sessions = uiState.workoutSessions,
        weeklyGoal = uiState.weeklyGoal
    )

    var selectedTabIndex by remember { mutableIntStateOf(0) }
    val tabs = listOf(stringResource(R.string.twelve_labors), stringResource(R.string.weekly_trials))

    Scaffold(
        containerColor = Color.Black,
        topBar = {
            Column {
                TopAppBar(
                    title = { Text(stringResource(R.string.campaign).uppercase(), fontWeight = FontWeight.Bold) },
                    navigationIcon = {
                        IconButton(onClick = onNavigateBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.back_description))
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Black, titleContentColor = Color.White, navigationIconContentColor = Color.White)
                )
                TabRow(
                    selectedTabIndex = selectedTabIndex,
                    containerColor = Color.Black,
                    contentColor = MaterialTheme.colorScheme.primary,
                    indicator = { tabPositions ->
                        TabRowDefaults.SecondaryIndicator(
                            modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTabIndex]),
                            color = MaterialTheme.colorScheme.primary
                        )
                    },
                    divider = {}
                ) {
                    tabs.forEachIndexed { index, title ->
                        Tab(
                            selected = selectedTabIndex == index,
                            onClick = { selectedTabIndex = index },
                            text = { 
                                Text(
                                    text = title,
                                    fontWeight = if (selectedTabIndex == index) FontWeight.Bold else FontWeight.Medium,
                                    letterSpacing = 1.sp
                                )
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        Column(modifier = Modifier.padding(innerPadding)) {
            if (selectedTabIndex == 0) {
                LaborsView(labors)
            } else {
                QuestsView(quests)
            }
        }
    }
}

@Composable
private fun LaborsView(labors: List<Labor>) {
    val completedCount = labors.count { it.isCompleted }
    
    Column(modifier = Modifier.fillMaxSize()) {
        Column(modifier = Modifier.padding(24.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.legends_forged),
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.5.sp,
                    fontSize = 12.sp
                )
                Text(
                    text = "$completedCount / ${labors.size}",
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Black,
                    fontSize = 14.sp
                )
            }
            Spacer(Modifier.height(12.dp))
            LinearProgressIndicator(
                progress = { completedCount.toFloat() / labors.size },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(CircleShape),
                color = MaterialTheme.colorScheme.primary,
                trackColor = Color(0xFF1C222B),
                gapSize = 0.dp,
                drawStopIndicator = {},
            )
        }

        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            itemsIndexed(labors, key = { _, labor -> labor.id }) { index, labor ->
                LaborMedallion(labor, index)
            }
        }
    }
}

@Composable
private fun LaborMedallion(labor: Labor, index: Int) {
    val isLaborLocked = !labor.isCompleted
    val isEven = index % 2 == 0
    val shape = RoundedCornerShape(
        topStart = if (isEven) 40.dp else 12.dp,
        topEnd = if (isEven) 12.dp else 40.dp,
        bottomStart = if (isEven) 12.dp else 40.dp,
        bottomEnd = if (isEven) 40.dp else 12.dp
    )

    var showDetail by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier
            .aspectRatio(0.85f)
            .clickable { showDetail = true },
        shape = shape,
        colors = CardDefaults.cardColors(
            containerColor = if (isLaborLocked) Color(0xFF1C222B) else MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f)
        )
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Watermark (simplified)
            Icon(
                imageVector = getFallbackIcon(labor.title),
                contentDescription = null,
                modifier = Modifier
                    .size(120.dp)
                    .align(Alignment.BottomEnd)
                    .offset(x = 24.dp, y = 24.dp)
                    .graphicsLayer { rotationZ = -15f },
                tint = if (isLaborLocked) Color.White.copy(alpha = 0.05f) else MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
            )

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Icon(
                        imageVector = getFallbackIcon(labor.title),
                        contentDescription = null,
                        modifier = Modifier.size(28.dp),
                        tint = if (isLaborLocked) Color.Gray else MaterialTheme.colorScheme.primary
                    )
                    Spacer(Modifier.height(12.dp))
                    Text(
                        text = labor.title.uppercase(),
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.Black,
                        color = if (isLaborLocked) Color.Gray else Color.White,
                        letterSpacing = 1.sp,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (isLaborLocked) {
                    Column {
                        LinearProgressIndicator(
                            progress = { labor.progress },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(4.dp)
                                .clip(CircleShape),
                            color = Color.Gray,
                            trackColor = Color.Black.copy(alpha = 0.3f),
                            gapSize = 0.dp,
                            drawStopIndicator = {},
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = labor.requirement,
                            style = MaterialTheme.typography.labelSmall,
                            color = Color.Gray,
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Rounded.Verified,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(Modifier.width(4.dp))
                        Text(
                            text = stringResource(R.string.forged),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }

    if (showDetail) {
        AlertDialog(
            onDismissRequest = { showDetail = false },
            containerColor = Color(0xFF1C222B),
            title = { Text(labor.title, fontWeight = FontWeight.Bold, color = Color.White) },
            text = {
                Column {
                    Text(labor.description, color = Color.Gray)
                    Spacer(Modifier.height(16.dp))
                    HorizontalDivider(color = Color.White.copy(alpha = 0.1f))
                    Spacer(Modifier.height(16.dp))
                    Text(
                        text = stringResource(R.string.requirement),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(labor.requirement, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold, color = Color.White)
                }
            },
            confirmButton = {
                TextButton(onClick = { showDetail = false }) {
                    Text(stringResource(R.string.close))
                }
            }
        )
    }
}

@Composable
private fun QuestsView(quests: List<Quest>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(quests, key = { it.id }) { quest ->
            QuestCard(quest)
        }
    }
}

@Composable
private fun QuestCard(quest: Quest) {
    val theme = MaterialTheme.colorScheme
    val cardColor = if (quest.isCompleted) theme.primaryContainer.copy(alpha = 0.2f) else Color(0xFF1C222B)
    val textColor = if (quest.isCompleted) theme.primary else Color.White

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = cardColor)
    ) {
        Row(
            modifier = Modifier
                .padding(20.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .background(if (quest.isCompleted) theme.primary else Color(0xFF2C343E), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Rounded.EmojiEvents,
                    contentDescription = null,
                    tint = if (quest.isCompleted) theme.onPrimary else Color.Gray,
                    modifier = Modifier.size(28.dp)
                )
            }
            Spacer(Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = quest.title.uppercase(),
                    color = textColor,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    letterSpacing = 1.sp
                )
                Text(
                    text = quest.description,
                    color = Color.Gray,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
                Spacer(Modifier.height(12.dp))

                if (!quest.isCompleted) {
                    Column {
                        LinearProgressIndicator(
                            progress = { quest.progress },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(6.dp)
                                .clip(CircleShape),
                            color = theme.primary,
                            trackColor = Color.Black.copy(alpha = 0.3f),
                            gapSize = 0.dp,
                            drawStopIndicator = {},
                        )
                        Spacer(Modifier.height(6.dp))
                        Text(
                            text = quest.requirement,
                            color = Color.Gray,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                } else {
                    Surface(
                        color = theme.primary,
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.completed),
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                            color = theme.onPrimary,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.sp
                        )
                    }
                }
            }
        }
    }
}

private fun getFallbackIcon(title: String): ImageVector {
    val t = title.lowercase()
    return when {
        t.contains("lion") -> Icons.Rounded.LocalFireDepartment
        t.contains("hydra") -> Icons.Rounded.WaterDrop
        t.contains("boar") -> Icons.Rounded.Pets
        t.contains("hind") || t.contains("deer") -> Icons.Rounded.Nature
        t.contains("birds") -> Icons.Rounded.Flight
        t.contains("bull") -> Icons.Rounded.Agriculture
        t.contains("stables") -> Icons.Rounded.CleanHands
        t.contains("belt") -> Icons.Rounded.Shield
        t.contains("apples") -> Icons.Rounded.Eco
        t.contains("cerberus") -> Icons.Rounded.Security
        t.contains("mares") -> Icons.AutoMirrored.Rounded.DirectionsRun
        t.contains("cattle") -> Icons.Rounded.Grass
        else -> Icons.Rounded.Star
    }
}
