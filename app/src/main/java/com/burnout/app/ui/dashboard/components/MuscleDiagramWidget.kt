package com.burnout.app.ui.dashboard.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.caverock.androidsvg.SVG
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.w3c.dom.Document
import org.w3c.dom.Element
import java.io.ByteArrayOutputStream
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult

/**
 * Kotlin/Compose port of muscle_diagram_widget.dart.
 *
 * Flutter used flutter_svg + the `xml` package to parse two body-diagram
 * SVGs, recolor each <path> by id according to that muscle's training
 * intensity (0.0-1.0), then re-render the modified SVG string.
 *
 * This port uses the same technique: org.w3c.dom for XML manipulation
 * (built into the JDK/Android), and AndroidSVG to rasterize the modified
 * SVG. Add this dependency to app/build.gradle.kts:
 *
 *     implementation("com.caverock:androidsvg-aar:1.4")
 *
 * Front/back SVGs are expected at res/raw/male_front_muscle.xml and
 * res/raw/male_back_muscle.xml (copy the .svg contents in as-is; Android's
 * raw resource loader is extension-agnostic about validating content, but
 * res/raw filenames must be lowercase and cannot use a .svg-registered
 * mimetype restriction, so a .xml extension is the safe default).
 */
@Composable
fun MuscleDiagramWidget(
    muscleIntensity: Map<String, Double>,
    frontSvgRawResId: Int,
    backSvgRawResId: Int,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val primaryColor = MaterialTheme.colorScheme.primary

    // Follow the app's theme (which respects the in-app light/dark/system setting)
    // rather than the phone's system setting.
    val isDark = MaterialTheme.colorScheme.surface.luminance() < 0.5f

    // M3 primary is a muted mid-tone; boost it for the "fully worked" end of the heatmap.
    val hotColor = remember(primaryColor, isDark) { vividColor(primaryColor, isDark) }

    var frontPicture by remember { mutableStateOf<android.graphics.Picture?>(null) }
    var backPicture by remember { mutableStateOf<android.graphics.Picture?>(null) }

    val intensityState = rememberUpdatedState(muscleIntensity)

    LaunchedEffect(muscleIntensity, primaryColor, hotColor, isDark) {
        val standardized = intensityState.value.mapKeys { standardizeMuscleId(it.key) }

        withContext(Dispatchers.Default) {
            val front = renderMuscleSvg(
                context = context,
                rawResId = frontSvgRawResId,
                intensity = standardized,
                primaryColor = primaryColor,
                hotColor = hotColor,
                isDark = isDark,
            )
            val back = renderMuscleSvg(
                context = context,
                rawResId = backSvgRawResId,
                intensity = standardized,
                primaryColor = primaryColor,
                hotColor = hotColor,
                isDark = isDark,
            )
            frontPicture = front
            backPicture = back
        }
    }

    if (frontPicture == null || backPicture == null) {
        androidx.compose.foundation.layout.Box(
            modifier = modifier.height(300.dp).size(300.dp),
            contentAlignment = Alignment.Center,
        ) {
            CircularProgressIndicator()
        }
        return
    }

    Row(modifier = modifier.height(300.dp)) {
        PictureView(picture = frontPicture!!, modifier = Modifier.weight(1f).height(300.dp))
        PictureView(picture = backPicture!!, modifier = Modifier.weight(1f).height(300.dp))
    }
}

/**
 * A plain View whose picture can be swapped after creation.
 *
 * AndroidView's `factory` only runs once, so the old anonymous View kept drawing
 * the first Picture it was given forever. Holding the picture as a property and
 * setting it from `update` makes new renders (e.g. a period change) actually show.
 */
private class PictureCanvasView(context: android.content.Context) : android.view.View(context) {
    var picture: android.graphics.Picture? = null
        set(value) {
            field = value
            invalidate()
        }

    override fun onDraw(canvas: android.graphics.Canvas) {
        super.onDraw(canvas)
        val pic = picture ?: return

        canvas.save()
        val scaleX = width.toFloat() / pic.width.coerceAtLeast(1).toFloat()
        val scaleY = height.toFloat() / pic.height.coerceAtLeast(1).toFloat()
        val scale = minOf(scaleX, scaleY)

        val dx = (width - pic.width * scale) / 2f
        val dy = (height - pic.height * scale) / 2f

        canvas.translate(dx, dy)
        canvas.scale(scale, scale)
        canvas.drawPicture(pic)
        canvas.restore()
    }
}

@Composable
private fun PictureView(picture: android.graphics.Picture, modifier: Modifier = Modifier) {
    AndroidView(
        modifier = modifier,
        factory = { ctx -> PictureCanvasView(ctx) },
        update = { view -> view.picture = picture },
    )
}

private fun standardizeMuscleId(muscleName: String): String {
    return muscleName
        .replace(Regex(" \\(.+\\)"), "")
        .replace(" ", "_")
        .lowercase()
}

/**
 * Pushes a theme colour towards a vivid version of the same hue.
 * Near-grey seeds are returned unchanged, since boosting saturation would invent a hue.
 */
private fun vividColor(base: Color, isDark: Boolean): Color {
    val hsv = FloatArray(3)
    android.graphics.Color.colorToHSV(base.toArgb(), hsv)
    if (hsv[1] < 0.15f) return base
    hsv[1] = maxOf(hsv[1], 0.85f)
    hsv[2] = maxOf(hsv[2], if (isDark) 0.90f else 0.95f)
    return Color(android.graphics.Color.HSVToColor(hsv))
}

/** Loads a res/raw SVG, recolors its <path> elements, and rasterizes it via AndroidSVG. */
private fun renderMuscleSvg(
    context: android.content.Context,
    rawResId: Int,
    intensity: Map<String, Double>,
    primaryColor: Color,
    hotColor: Color,
    isDark: Boolean,
): android.graphics.Picture {
    val raw = context.resources.openRawResource(rawResId).bufferedReader().use { it.readText() }

    val factory = DocumentBuilderFactory.newInstance()
    val builder = factory.newDocumentBuilder()
    val doc: Document = builder.parse(raw.byteInputStream())

    val baseCanvasColor = if (!isDark) Color(0xFF828282) else Color(0xFFF2F2F2)
//    val baseCanvasColor = Color(0xFFF2F2F2)

    // Untrained muscles keep a subtle tint of the theme colour.
    val inactiveMuscleColor = alphaBlend(primaryColor.copy(alpha = 0.05f), baseCanvasColor)

    val paths = doc.getElementsByTagName("path")
    for (i in 0 until paths.length) {
        val element = paths.item(i) as? Element ?: continue
        val id = element.getAttribute("id").takeIf { it.isNotEmpty() } ?: continue
        if (id == "body" || id == "head") continue

        val lookupId = id.replace(" ", "_").lowercase()
        val muscleIntensity = intensity[lookupId] ?: 0.0

        val style = element.getAttribute("style").takeIf { it.isNotEmpty() } ?: continue

        var strokeWidth = "1"
        val strokeWidthMatch = Regex("stroke-width\\s*:\\s*([^;]+)").find(style)
        if (strokeWidthMatch != null) {
            strokeWidth = strokeWidthMatch.groupValues[1].trim()
        } else {
            val attrWidth = element.getAttribute("stroke-width").takeIf { it.isNotEmpty() }
            if (attrWidth != null) strokeWidth = attrWidth
        }

        val finalColor = if (muscleIntensity > 0) {
            // Any trained muscle starts at a clearly visible level (25%) and ramps to the vivid colour.
            val t = (0.25f + 0.75f * muscleIntensity.toFloat()).coerceIn(0f, 1f)
            lerp(inactiveMuscleColor, hotColor, t)
        } else {
            inactiveMuscleColor
        }
        val fillHex = colorToHex(finalColor)

//        val newStyle = "fill:$fillHex;fill-opacity:1.0;stroke:#000000;stroke-width:$strokeWidth;stroke-opacity:1"
        val newStyle = "fill:$fillHex;fill-opacity:1.0;stroke:#000000;stroke-width:0;stroke-opacity:0"
        element.setAttribute("style", newStyle)
        element.setAttribute("vector-effect", "non-scaling-stroke")
    }

    val modifiedSvgString = documentToString(doc)
    val svg = SVG.getFromString(modifiedSvgString)

    val picture = android.graphics.Picture()
    val w = (svg.documentWidth.takeIf { it > 0 } ?: 512f).toInt()
    val h = (svg.documentHeight.takeIf { it > 0 } ?: 512f).toInt()
    val canvas = picture.beginRecording(w, h)
    svg.renderToCanvas(canvas)
    picture.endRecording()
    return picture
}

private fun alphaBlend(foreground: Color, background: Color): Color {
    val a = foreground.alpha
    val r = foreground.red * a + background.red * (1 - a)
    val g = foreground.green * a + background.green * (1 - a)
    val b = foreground.blue * a + background.blue * (1 - a)
    return Color(r, g, b, 1f)
}

private fun colorToHex(color: Color): String {
    val argb = color.toArgb()
    return "#%06X".format(argb and 0xFFFFFF)
}

private fun documentToString(doc: Document): String {
    val transformer = TransformerFactory.newInstance().newTransformer()
    transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes")
    val output = ByteArrayOutputStream()
    transformer.transform(DOMSource(doc), StreamResult(output))
    return output.toString("UTF-8")
}