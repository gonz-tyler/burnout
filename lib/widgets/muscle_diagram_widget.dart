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
  String? _modifiedSvgData;
  XmlDocument? _cachedDocument;
  Color? _primaryColor;

  @override
  void initState() {
    super.initState();
    // Start loading the SVG data immediately
    _initSvg();
  }

  // 🟢 FIX: Listen to Theme changes here
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current primary color from the context
    final newColor = Theme.of(context).colorScheme.primary;

    // If the color has changed (or it's the first time), update it
    if (_primaryColor != newColor) {
      _primaryColor = newColor;

      // If the SVG is already parsed, re-paint it immediately with the new color
      if (_cachedDocument != null) {
        _updateSvgVisuals();
      }
    }
  }

  @override
  void didUpdateWidget(MuscleDiagramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the workout data changes, update the visuals
    if (widget.muscleIntensity != oldWidget.muscleIntensity) {
      _updateSvgVisuals();
    }
  }

  Future<void> _initSvg() async {
    const assetName = 'assets/data/images/male_front_muscle.svg';
    try {
      final svgString = await rootBundle.loadString(assetName);
      _cachedDocument = XmlDocument.parse(svgString);

      // Once loaded, apply the color (which we grabbed in didChangeDependencies)
      if (mounted) {
        _updateSvgVisuals();
      }
    } catch (e) {
      debugPrint("Error loading muscle SVG: $e");
    }
  }

  String _standardizeMuscleId(String muscleName) {
    return muscleName
        .replaceAllMapped(RegExp(r' \(.+\)'), (match) => '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  void _updateSvgVisuals() {
    if (_primaryColor == null || _cachedDocument == null || !mounted) return;

    final standardizedIntensityMap = widget.muscleIntensity.map(
      (key, value) => MapEntry(_standardizeMuscleId(key), value),
    );

    String colorToHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
    }

    final muscleColorHex = colorToHex(_primaryColor!);
    final paths = _cachedDocument!.findAllElements('path');

    for (var element in paths) {
      final id = element.getAttribute('id');
      if (id == null) continue;

      if (id == 'body' || id == 'head') continue;

      final lookupId = id.replaceAll(' ', '_').toLowerCase();
      final double intensity = standardizedIntensityMap[lookupId] ?? 0.0;

      final style = element.getAttribute('style');
      if (style != null) {
        final opacity = intensity > 0 ? intensity : 0.1;
        final newStyle =
            'fill:$muscleColorHex;fill-opacity:$opacity;stroke:#000000;stroke-opacity:1';
        element.setAttribute('style', newStyle);
      }
    }

    setState(() {
      _modifiedSvgData = _cachedDocument!.toXmlString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_modifiedSvgData == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SvgPicture.string(
      _modifiedSvgData!,
      semanticsLabel: 'Muscle intensity diagram',
      width: 300,
    );
  }
}
