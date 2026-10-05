package com.burnout.app

import android.annotation.SuppressLint
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Bundle
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.annotation.StringRes
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Leaderboard
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.outlined.Leaderboard
import androidx.compose.material.icons.outlined.LocalFireDepartment
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Shield
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.PlatformTextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.os.LocaleListCompat
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.burnout.app.data.datastore.FeatureToggles
import com.burnout.app.domain.model.Sex
import com.burnout.app.domain.model.Style
import com.burnout.app.data.datastore.SettingsDataStore
import com.burnout.app.data.local.entity.Routine
import com.burnout.app.domain.service.LaborsService
import com.burnout.app.ui.profile.ProfileScreen
import com.burnout.app.ui.routine.CreateEditRoutineScreen
import com.burnout.app.ui.settings.SettingsScreen
import com.burnout.app.ui.theme.BurnoutTheme
import com.burnout.app.ui.viewmodel.ActiveWorkoutViewModel
import com.burnout.app.ui.viewmodel.WorkoutViewModel
import com.burnout.app.ui.workout.ActiveWorkoutScreen
import com.burnout.app.ui.workout.BattleReportScreen
import com.burnout.app.ui.workout.WorkoutDetailsScreen
import com.burnout.app.ui.workout.WorkoutHistoryScreen
import com.burnout.app.ui.workout.WorkoutsScreen
import com.materialkolor.PaletteStyle
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

private object AppRoutes {
    const val HOME = "home"
    const val ROUTINE_EDITOR = "routine_editor?routineId={routineId}"
    const val ACTIVE_WORKOUT = "active_workout"
    const val BATTLE_REPORT = "battle_report"
    const val SETTINGS = "settings"
    const val CAMPAIGN = "campaign"
    const val WORKOUT_HISTORY = "workout_history"
    const val WORKOUT_DETAILS = "workout_details/{sessionId}"
}

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    private val workoutViewModel: WorkoutViewModel by viewModels()
    private val activeWorkoutViewModel: ActiveWorkoutViewModel by viewModels()
    @Inject lateinit var settingsDataStore: SettingsDataStore

    // Flipped once the first settings snapshot has been read; keeps the splash up until then
    // so users never see the default seed colour / language flash on cold start.
    private var settingsLoaded = false

    // Last dark/light value applied by the theme effect; re-applied after the splash is removed
    private var barsDark = false

    private fun applySystemBars(dark: Boolean) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(
                android.graphics.Color.TRANSPARENT,
                android.graphics.Color.TRANSPARENT
            ) { dark },
            navigationBarStyle = SystemBarStyle.auto(
                android.graphics.Color.TRANSPARENT,
                android.graphics.Color.TRANSPARENT
            ) { dark }
        )
    }

    @SuppressLint("LocalContextConfigurationRead")
    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()
        splash.setKeepOnScreenCondition { !settingsLoaded }
        splash.setOnExitAnimationListener { provider ->
            provider.view.animate()
                .alpha(0f)
                .setDuration(250L)
                .withEndAction {
                    provider.remove()
                    applySystemBars(barsDark) // the system resets bar icons when the splash goes away
                }
                .start()
            provider.iconView.animate().scaleX(1.15f).scaleY(1.15f).setDuration(250L).start()
        }
        super.onCreate(savedInstanceState)
        enableEdgeToEdge() // sensible default (follows the system) before anything is drawn
        setContent {
            val settings by settingsDataStore.uiSettings.collectAsState(initial = null)
            val featureState by settingsDataStore.features.collectAsState(initial = null)
            val sexState by settingsDataStore.sex.collectAsState(initial = null)
            val styleState by settingsDataStore.style.collectAsState(initial = null)
            val reminderTime by settingsDataStore.reminderTime.collectAsState(initial = null)

            // Nothing to draw until DataStore has delivered the first snapshot (splash covers this).
            val ui = settings ?: return@setContent
            val features = featureState ?: return@setContent
            val sex = sexState ?: return@setContent
            val style = styleState ?: return@setContent
            SideEffect { settingsLoaded = true }

            val context = LocalContext.current

            LaunchedEffect(reminderTime) {
                reminderTime?.let {
                    com.burnout.app.domain.notification.WorkManagerScheduler.scheduleDailyReminder(context, it)
                }
            }
            LaunchedEffect(ui.language) {
                val targetLocales = if (ui.language == SettingsDataStore.LANGUAGE_SYSTEM) {
                    LocaleListCompat.getEmptyLocaleList()
                } else {
                    LocaleListCompat.forLanguageTags(ui.language)
                }
                if (AppCompatDelegate.getApplicationLocales() != targetLocales) {
                    AppCompatDelegate.setApplicationLocales(targetLocales)
                }
            }

            val useDarkTheme = when (ui.themeMode) {
                "light" -> false
                "dark" -> true
                else -> isSystemInDarkTheme()
            }

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                val permissionState = androidx.activity.compose.rememberLauncherForActivityResult(
                    androidx.activity.result.contract.ActivityResultContracts.RequestPermission()
                ) { isGranted ->
                    // Handle permission result if needed
                }
                LaunchedEffect(Unit) {
                    permissionState.launch(android.Manifest.permission.POST_NOTIFICATIONS)
                }
            }

            DisposableEffect(useDarkTheme) {
                barsDark = useDarkTheme
                applySystemBars(useDarkTheme)
                onDispose { }
            }

            val paletteStyle = remember(ui.paletteStyle) {
                runCatching { PaletteStyle.valueOf(ui.paletteStyle) }.getOrDefault(PaletteStyle.TonalSpot)
            }

            BurnoutTheme(
                seedColorInt = ui.seedColor,
                darkTheme = useDarkTheme,
                dynamicColor = ui.dynamicColor,
                paletteStyle = paletteStyle
            ) {
                MainNavigation(
                    workoutViewModel = workoutViewModel,
                    activeWorkoutViewModel = activeWorkoutViewModel,
                    settingsDataStore = settingsDataStore,
                    features = features,
                    sex = sex,
                    style = style,
                    activityContext = this@MainActivity
                )
            }
        }
    }
}

@Composable
fun MainNavigation(
    workoutViewModel: WorkoutViewModel,
    activeWorkoutViewModel: ActiveWorkoutViewModel,
    settingsDataStore: SettingsDataStore,
    features: FeatureToggles,
    sex: Sex,
    style: Style,
    activityContext: android.content.Context
) {
    val navController = rememberNavController()
    val workoutState by workoutViewModel.uiState.collectAsState()

    var selectedDestination by remember { mutableStateOf(AppDestinations.WORKOUTS) }

    NavHost(
        navController = navController,
        startDestination = AppRoutes.HOME,
        enterTransition = { slideInHorizontally(initialOffsetX = { it }, animationSpec = tween(400)) },
        exitTransition = { slideOutHorizontally(targetOffsetX = { -it }, animationSpec = tween(400)) },
        popEnterTransition = { slideInHorizontally(initialOffsetX = { -it }, animationSpec = tween(400)) },
        popExitTransition = { slideOutHorizontally(targetOffsetX = { it }, animationSpec = tween(400)) }
    ) {
        composable(AppRoutes.HOME) {
            BurnoutApp(
                workoutViewModel = workoutViewModel,
                features = features,
                sex = sex,
                style = style,
                selectedDestination = selectedDestination,
                onDestinationSelected = { selectedDestination = it },
                onNavigateToEditor = { routineId ->
                    navController.navigate("routine_editor?routineId=$routineId")
                },
                onStartWorkout = { routine ->
                    activeWorkoutViewModel.startWorkout(routine)
                    navController.navigate(AppRoutes.ACTIVE_WORKOUT)
                },
                onNavigateToSettings = { navController.navigate(AppRoutes.SETTINGS) },
                onNavigateToHistory = { navController.navigate(AppRoutes.WORKOUT_HISTORY) },
                onNavigateToCampaign = { navController.navigate(AppRoutes.CAMPAIGN) }
            )
        }

        composable(
            route = AppRoutes.ROUTINE_EDITOR,
            arguments = listOf(navArgument("routineId") { nullable = true })
        ) { backStackEntry ->
            val routineId = backStackEntry.arguments?.getString("routineId")
            val routine = workoutState.routines.find { it.id == routineId }

            CreateEditRoutineScreen(
                initialRoutine = routine,
                availableExercises = workoutState.exercises,
                unitSystem = workoutState.unitSystem,
                onSaveRoutine = { updatedRoutine ->
                    workoutViewModel.addRoutine(updatedRoutine)
                    navController.popBackStack()
                },
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(AppRoutes.ACTIVE_WORKOUT) {
            val activeState by activeWorkoutViewModel.uiState.collectAsState()
            ActiveWorkoutScreen(
                routine = activeState.routine,
                workoutViewModel = workoutViewModel,
                activeViewModel = activeWorkoutViewModel,
                onNavigateBack = { navController.popBackStack() },
                onFinished = { results, routineId, durationMinutes ->
                    navController.navigate(AppRoutes.BATTLE_REPORT) {
                        popUpTo(AppRoutes.HOME)
                    }
                }
            )
        }

        composable(AppRoutes.BATTLE_REPORT) {
            BattleReportScreen(
                activeWorkoutViewModel = activeWorkoutViewModel,
                workoutViewModel = workoutViewModel,
                onSaveComplete = {
                    activeWorkoutViewModel.clearSession()
                    navController.popBackStack(AppRoutes.HOME, inclusive = false)
                }
            )
        }

        composable(AppRoutes.SETTINGS) {
            SettingsScreen(
                settingsDataStore = settingsDataStore,
                activityContext = activityContext,
                features = features,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(AppRoutes.WORKOUT_HISTORY) {
            WorkoutHistoryScreen(
                workoutViewModel = workoutViewModel,
                onNavigateToDetails = { sessionId ->
                    navController.navigate("workout_details/$sessionId")
                },
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(AppRoutes.CAMPAIGN) {
            com.burnout.app.ui.workout.CampaignScreen(
                workoutViewModel = workoutViewModel,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(
            route = AppRoutes.WORKOUT_DETAILS,
            arguments = listOf(navArgument("sessionId") { type = NavType.StringType })
        ) { backStackEntry ->
            val sessionId = backStackEntry.arguments?.getString("sessionId") ?: ""
            WorkoutDetailsScreen(
                sessionId = sessionId,
                workoutViewModel = workoutViewModel,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BurnoutApp(
    workoutViewModel: WorkoutViewModel,
    features: FeatureToggles,
    sex: Sex,
    style: Style,
    selectedDestination: AppDestinations,
    onDestinationSelected: (AppDestinations) -> Unit,
    onNavigateToEditor: (String?) -> Unit,
    onStartWorkout: (Routine?) -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToHistory: () -> Unit,
    onNavigateToCampaign: () -> Unit
) {
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior(rememberTopAppBarState())
    val uiState by workoutViewModel.uiState.collectAsState()
    val laborCount = LaborsService.countCompletedLabors(uiState, workoutViewModel::getPersonalRecord)

    Scaffold(
        modifier = Modifier.fillMaxSize().nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            CustomCollapsibleTopAppBar(
                title = {
                    AnimatedContent(
                        targetState = selectedDestination,
                        modifier = Modifier.fillMaxWidth(),
                        transitionSpec = {
                            val isMovingRight = targetState.ordinal > initialState.ordinal
                            val duration = 600

                            val slideIn = slideInVertically(
                                initialOffsetY = { fullHeight -> if (isMovingRight) fullHeight else -fullHeight },
                                animationSpec = tween(duration)
                            )
                            val slideOut = slideOutVertically(
                                targetOffsetY = { fullHeight -> if (isMovingRight) -fullHeight else fullHeight },
                                animationSpec = tween(duration)
                            )

                            (slideIn togetherWith slideOut).using(SizeTransform(clip = false))
                        },
                        contentAlignment = Alignment.CenterStart,
                        label = "FlipCardTitle"
                    ) { dest ->
                        Text(
                            text = stringResource(dest.labelRes),
                            style = MaterialTheme.typography.displayMedium.copy(
                                platformStyle = PlatformTextStyle(includeFontPadding = false)
                            ),
                            fontWeight = FontWeight.Bold,
                            maxLines = 1
                        )
                    }
                },
                actions = {
                    Surface(
                        color = MaterialTheme.colorScheme.surface,
                        shape = MaterialTheme.shapes.large
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            AnimatedVisibility(
                                visible = features.streak &&
                                        (selectedDestination == AppDestinations.PROFILE || selectedDestination == AppDestinations.WORKOUTS),
                                enter = slideInHorizontally(
                                    animationSpec = tween(350),
                                    initialOffsetX = { fullWidth -> fullWidth }
                                ) + fadeIn(animationSpec = tween(200, delayMillis = 100)),
                                exit = slideOutHorizontally(
                                    animationSpec = tween(350),
                                    targetOffsetX = { fullWidth -> fullWidth }
                                ) + fadeOut(animationSpec = tween(150))
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Filled.LocalFireDepartment,
                                        contentDescription = stringResource(R.string.streak_description),
                                        tint =
                                            if (uiState.hasWorkedOutToday) {
                                                Color(0xFFFFA726)
                                            }
                                            else {
                                                MaterialTheme.colorScheme.outline
                                            },
                                        modifier = Modifier.size(28.dp)
                                    )
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(
                                        text = uiState.currentStreak.toString(),
                                        fontWeight = FontWeight.Bold,
                                        color =
                                            if (uiState.hasWorkedOutToday) {
                                                Color(0xFFFFA726)
                                            }
                                            else {
                                                MaterialTheme.colorScheme.outline
                                            },
                                    )
                                    Spacer(modifier = Modifier.width(12.dp))
                                }
                            }
                            if (features.labors) {
                                IconButton(
                                    onClick = onNavigateToCampaign,
                                    modifier = Modifier.size(32.dp)
                                ) {
                                    Box(
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Icon(
                                            imageVector = Icons.Outlined.Shield,
                                            contentDescription = null,
                                            tint =
                                                if (laborCount == 12) {
                                                    MaterialTheme.colorScheme.primary
                                                } else {
                                                    MaterialTheme.colorScheme.outline
                                                },
                                            modifier = Modifier.size(28.dp)
                                        )
                                        Text(
                                            text = laborCount.toString(),
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 11.sp,
                                            color =
                                                if (laborCount == 12) {
                                                    MaterialTheme.colorScheme.primary
                                                } else {
                                                    MaterialTheme.colorScheme.outline
                                                },
                                        )
                                    }
                                }
                            }
                        }
                    }
                },
                scrollBehavior = scrollBehavior
            )
        },
        bottomBar = {
            FloatingBottomNavigationBar(
                selectedDestination = selectedDestination,
                onDestinationSelected = { dest ->
                    if (dest != selectedDestination) {
                        onDestinationSelected(dest)
                    }
                }
            )
        }
    ) { innerPadding ->
        val bottomBarPadding = innerPadding.calculateBottomPadding()
        AnimatedContent(
            targetState = selectedDestination,
            transitionSpec = {
                val isMovingRight = targetState.ordinal > initialState.ordinal
                if (isMovingRight) {
                    slideInHorizontally(
                        initialOffsetX = { fullWidth -> fullWidth },
                        animationSpec = tween(300)
                    ) togetherWith slideOutHorizontally(
                        targetOffsetX = { fullWidth -> -fullWidth },
                        animationSpec = tween(300)
                    )
                } else {
                    slideInHorizontally(
                        initialOffsetX = { fullWidth -> -fullWidth },
                        animationSpec = tween(300)
                    ) togetherWith slideOutHorizontally(
                        targetOffsetX = { fullWidth -> fullWidth },
                        animationSpec = tween(300)
                    )
                }
            },
//            modifier = Modifier.fillMaxSize().padding(innerPadding),//.calculateTopPadding()),
            modifier = Modifier.fillMaxSize().padding(top = innerPadding.calculateTopPadding()),
            label = "ScreenTransition"
        ) { destination ->
            when (destination) {
                AppDestinations.DASHBOARD -> com.burnout.app.ui.dashboard.DashboardScreen(
                    viewModel = workoutViewModel,
                    unitSystem = if (uiState.unitSystem == "imperial") com.burnout.app.util.UnitSystem.IMPERIAL else com.burnout.app.util.UnitSystem.METRIC,
                    features = features,
                    sex = sex,
                    style = style,
                    frontSvgRawResId = if (uiState.gender == "male") R.raw.male_front_muscle else R.raw.female_front_muscle,
                    backSvgRawResId = if (uiState.gender == "male") R.raw.male_back_muscle else R.raw.female_back_muscle,
                    onOpenStrengthLevel = { _, _, _ -> /* TODO */ },
                    bottomPadding = bottomBarPadding,
                )

                AppDestinations.WORKOUTS -> WorkoutsScreen(
                    routines = uiState.routines,
                    features = features,
                    onCreateRoutineClick = { onNavigateToEditor(null) },
                    onStartEmptyWorkoutClick = { onStartWorkout(null) },
                    onStartRoutineClick = { onStartWorkout(it) },
                    onEditRoutineClick = { onNavigateToEditor(it.id) },
                    onDuplicateRoutineClick = { workoutViewModel.duplicateRoutine(it) },
                    onDeleteRoutineClick = { workoutViewModel.deleteRoutine(it) },
                    onCampaignClick = onNavigateToCampaign,
                    bottomPadding = bottomBarPadding,
                )

                AppDestinations.PROFILE -> ProfileScreen(
                    workoutViewModel = workoutViewModel,
                    onNavigateToHistory = onNavigateToHistory,
                    onNavigateToSettings = onNavigateToSettings,
                    features = features,
                    bottomPadding = bottomBarPadding,
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomCollapsibleTopAppBar(
    title: @Composable () -> Unit,
    actions: @Composable RowScope.() -> Unit,
    scrollBehavior: TopAppBarScrollBehavior
) {
    val density = LocalDensity.current
    val statusBarHeight = WindowInsets.statusBars.asPaddingValues(density).calculateTopPadding()
    val expandedHeight = 136.dp + statusBarHeight
    val maxOffsetPx = with(density) { -72.dp.toPx() }

    SideEffect {
        if (scrollBehavior.state.heightOffsetLimit != maxOffsetPx) {
            scrollBehavior.state.heightOffsetLimit = maxOffsetPx
        }
    }

    val collapsedFraction = scrollBehavior.state.collapsedFraction
    val currentHeight = expandedHeight - (72.dp * collapsedFraction)
    val titleScale = 1f - (0.38f * collapsedFraction)

    Surface(
        color = MaterialTheme.colorScheme.surface,
        modifier = Modifier.fillMaxWidth().height(currentHeight)
    ) {
        Box(modifier = Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.statusBars)) {
            Row(
                modifier = Modifier.align(Alignment.TopEnd).height(64.dp).padding(end = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                actions()
            }
            val bottomPadding = (12.dp * (1f - collapsedFraction)) + (4.dp * collapsedFraction)
            Box(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(start = 16.dp, end = 96.dp, bottom = bottomPadding)
                    .fillMaxWidth()
                    .height(58.dp)
                    .graphicsLayer {
                        scaleX = titleScale
                        scaleY = titleScale
                        transformOrigin = TransformOrigin(0f, 0.5f)
                    }
                    .clipToBounds(),
                contentAlignment = Alignment.CenterStart
            ) {
                title()
            }
        }
    }
}

@Composable
fun FloatingBottomNavigationBar(
    selectedDestination: AppDestinations,
    onDestinationSelected: (AppDestinations) -> Unit
) {
    val fadeColor = MaterialTheme.colorScheme.surface // match your screen background
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    colorStops = arrayOf(
                        0f to fadeColor.copy(alpha = 0f),
//                        0.5f to fadeColor.copy(alpha = 0.85f),
                        0.5f to fadeColor,
                        1f to fadeColor
                    )
                )
            )
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(start = 24.dp, end = 24.dp, top = 72.dp, bottom = 20.dp)
    ) {
        Surface(
            modifier = Modifier.fillMaxWidth().height(64.dp),
            shape = RoundedCornerShape(36.dp),
            color = MaterialTheme.colorScheme.surfaceContainerLow,
            shadowElevation = 12.dp
        ) {
            Row(
                modifier = Modifier.fillMaxSize(),
                horizontalArrangement = Arrangement.SpaceAround,
                verticalAlignment = Alignment.CenterVertically
            ) {
                AppDestinations.entries.forEach { dest ->
                    FloatingNavItem(
                        icon = dest.icon,
                        activeIcon = dest.selectedIcon,
                        label = stringResource(dest.labelRes),
                        isSelected = dest == selectedDestination,
                        onClick = { onDestinationSelected(dest) }
                    )
                }
            }
        }
    }
}

@Composable
fun RowScope.FloatingNavItem(
    icon: ImageVector,
    activeIcon: ImageVector,
    label: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    var isAnimating by remember { mutableStateOf(false) }
    val scale by androidx.compose.animation.core.animateFloatAsState(
        targetValue = if (isAnimating) 1.2f else 1.0f,
        animationSpec = tween(durationMillis = 150),
        finishedListener = { isAnimating = false },
        label = "NavItemScaleBounce"
    )

    Box(
        modifier = Modifier
            .weight(1f)
            .fillMaxHeight()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null
            ) {
                isAnimating = true
                onClick()
            },
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = if (isSelected) activeIcon else icon,
            contentDescription = label,
            tint = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(28.dp)
        )
    }
}

enum class AppDestinations(
    @StringRes val labelRes: Int,
    val icon: ImageVector,
    val selectedIcon: ImageVector
) {
    DASHBOARD(R.string.nav_dashboard, Icons.Outlined.Leaderboard, Icons.Filled.Leaderboard),
    WORKOUTS(R.string.nav_workouts, Icons.Outlined.LocalFireDepartment, Icons.Filled.LocalFireDepartment),
    PROFILE(R.string.nav_profile, Icons.Outlined.Person, Icons.Filled.Person)
}

@Composable
fun PlaceholderScreen(title: String) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = stringResource(R.string.placeholder_screen_content, title), style = MaterialTheme.typography.titleMedium)
    }
}