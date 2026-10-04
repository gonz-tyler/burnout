package com.burnout.app.ui.theme

import android.os.Build
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.materialkolor.PaletteStyle
import com.materialkolor.dynamicColorScheme

object BurnoutThemeTokens {
    val radiusL = 28.dp
}

/**
 * Status/navigation bar colours are handled by enableEdgeToEdge() in MainActivity,
 * so no window.statusBarColor side effect is needed here.
 */
@Composable
fun BurnoutTheme(
    seedColorInt: Int = 0xFFC9A24B.toInt(),
    darkTheme: Boolean,
    dynamicColor: Boolean = false,
    paletteStyle: PaletteStyle = PaletteStyle.TonalSpot,
    content: @Composable () -> Unit
) {
    val context = LocalContext.current

    val colorScheme = remember(seedColorInt, darkTheme, dynamicColor, paletteStyle) {
        if (dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        } else {
            dynamicColorScheme(
                seedColor = Color(seedColorInt),
                isDark = darkTheme,
                style = paletteStyle
            )
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}