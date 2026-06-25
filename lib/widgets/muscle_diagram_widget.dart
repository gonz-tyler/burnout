// lib/widgets/muscle_diagram_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';
import 'package:xml/xml.dart';

class MuscleDiagramWidget extends StatefulWidget {
  final Map<String, double> muscleIntensity;

  const MuscleDiagramWidget({Key? key, required this.muscleIntensity})
    : super(key: key);

  @override
  State<MuscleDiagramWidget> createState() => _MuscleDiagramWidgetState();
}

class _MuscleDiagramWidgetState extends State<MuscleDiagramWidget> {
  String? _modifiedFrontSvgData;
  String? _modifiedBackSvgData;
  XmlDocument? _cachedFrontDocument;
  XmlDocument? _cachedBackDocument;
  Color? _primaryColor;
  Brightness?
  _currentBrightness; // Track brightness changes for light/dark mode

  @override
  void initState() {
    super.initState();
    // Start loading both SVG data sets immediately
    _initSvgs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = Theme.of(context);
    final newColor = theme.colorScheme.primary;
    final newBrightness = theme.brightness;

    // Re-paint if theme colors or light/dark mode toggles
    if (_primaryColor != newColor || _currentBrightness != newBrightness) {
      _primaryColor = newColor;
      _currentBrightness = newBrightness;

      if (_cachedFrontDocument != null && _cachedBackDocument != null) {
        _updateSvgVisuals();
      }
    }
  }

  @override
  void didUpdateWidget(MuscleDiagramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.muscleIntensity != oldWidget.muscleIntensity) {
      _updateSvgVisuals();
    }
  }

  Future<void> _initSvgs() async {
    const frontAsset = 'assets/data/images/male_front_muscle.svg';
    const backAsset = 'assets/data/images/male_back_muscle.svg';

    try {
      final results = await Future.wait([
        rootBundle.loadString(frontAsset),
        rootBundle.loadString(backAsset),
      ]);

      _cachedFrontDocument = XmlDocument.parse(results[0]);
      _cachedBackDocument = XmlDocument.parse(results[1]);

      if (mounted) {
        _updateSvgVisuals();
      }
    } catch (e) {
      debugPrint("Error loading muscle SVGs: $e");
    }
  }

  String _standardizeMuscleId(String muscleName) {
    return muscleName
        .replaceAllMapped(RegExp(r' \(.+\)'), (match) => '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  void _processXmlDocument(
    XmlDocument document,
    Map<String, double> standardizedIntensityMap,
  ) {
    if (_primaryColor == null || _currentBrightness == null) return;

    final isDark = _currentBrightness == Brightness.dark;

    // Base canvas colors that guarantee visibility without blending into pure black
    final baseCanvasColor =
        isDark
            ? const Color.fromARGB(255, 130, 130, 130)
            : const Color(0xFFF2F2F2);

    // Create a beautiful, solid 100% opaque inactive color containing a visible theme tinge
    final inactiveMuscleColor = Color.alphaBlend(
      _primaryColor!.withOpacity(
        0.15,
      ), // Adjusted opacity for a perfect, clear tinge
      baseCanvasColor,
    );

    final paths = document.findAllElements('path');

    String colorToHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
    }

    for (var element in paths) {
      final id = element.getAttribute('id');
      if (id == null) continue;

      if (id == 'body' || id == 'head') continue;

      final lookupId = id.replaceAll(' ', '_').toLowerCase();
      final double intensity = standardizedIntensityMap[lookupId] ?? 0.0;

      final style = element.getAttribute('style');
      if (style != null) {
        // 1. Extract the original stroke-width if it exists
        String strokeWidth = '1';
        final strokeWidthMatch = RegExp(
          r'stroke-width\s*:\s*([^;]+)',
        ).firstMatch(style);

        if (strokeWidthMatch != null) {
          strokeWidth = strokeWidthMatch.group(1)!.trim();
        } else {
          final attrWidth = element.getAttribute('stroke-width');
          if (attrWidth != null) strokeWidth = attrWidth;
        }

        // 2. Smoothly transition from our tinted base to the full primary theme color
        final finalColor =
            intensity > 0
                ? Color.lerp(inactiveMuscleColor, _primaryColor!, intensity)!
                : inactiveMuscleColor;

        final fillHex = colorToHex(finalColor);

        // 3. Keep fill-opacity at 1.0 to retain total solid mask over hidden paths
        final newStyle =
            'fill:$fillHex;fill-opacity:1.0;stroke:#000000;stroke-width:$strokeWidth;stroke-opacity:1';
        element.setAttribute('style', newStyle);

        // 4. Ensure stroke line weight looks uniform across both diagrams
        element.setAttribute('vector-effect', 'non-scaling-stroke');
      }
    }
  }

  void _updateSvgVisuals() {
    if (_primaryColor == null ||
        _currentBrightness == null ||
        _cachedFrontDocument == null ||
        _cachedBackDocument == null ||
        !mounted) {
      return;
    }

    final standardizedIntensityMap = widget.muscleIntensity.map(
      (key, value) => MapEntry(_standardizeMuscleId(key), value),
    );

    _processXmlDocument(_cachedFrontDocument!, standardizedIntensityMap);
    _processXmlDocument(_cachedBackDocument!, standardizedIntensityMap);

    setState(() {
      _modifiedFrontSvgData = _cachedFrontDocument!.toXmlString();
      _modifiedBackSvgData = _cachedBackDocument!.toXmlString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_modifiedFrontSvgData == null || _modifiedBackSvgData == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final svgWidth = constraints.maxWidth / 2;
        const svgHeight = 300.0;

        return SizedBox(
          height: svgHeight,
          child: Row(
            children: [
              SizedBox(
                width: svgWidth,
                height: svgHeight,
                child: SvgPicture.string(
                  _modifiedFrontSvgData!,
                  semanticsLabel: 'Front muscle intensity diagram',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(
                width: svgWidth,
                height: svgHeight,
                child: SvgPicture.string(
                  _modifiedBackSvgData!,
                  semanticsLabel: 'Back muscle intensity diagram',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
