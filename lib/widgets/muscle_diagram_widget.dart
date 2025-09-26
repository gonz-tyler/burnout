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
  Color? _primaryColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _primaryColor = Theme.of(context).colorScheme.primaryFixedDim;
        _loadAndModifySvg();
      }
    });
  }

  @override
  void didUpdateWidget(MuscleDiagramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the intensity map has changed (e.g., user changed the time period),
    // re-process the SVG to show the new data.
    if (widget.muscleIntensity != oldWidget.muscleIntensity) {
      _loadAndModifySvg();
    }
  }

  String _standardizeMuscleId(String muscleName) {
    return muscleName
        .replaceAllMapped(
          RegExp(r' \(.+\)'),
          (match) => '',
        ) // Removes details like (Upper), (General)
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  Future<void> _loadAndModifySvg() async {
    if (_primaryColor == null || !mounted) return;

    // Standardize the keys of the intensity map to match our expected SVG ID format.
    final standardizedIntensityMap = widget.muscleIntensity.map(
      (key, value) => MapEntry(_standardizeMuscleId(key), value),
    );

    const assetName = 'assets/data/images/male_front_muscle.svg';
    final svgString = await rootBundle.loadString(assetName);
    final document = XmlDocument.parse(svgString);

    String colorToHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
    }

    final muscleColorHex = colorToHex(_primaryColor!);
    final paths = document.findAllElements('path');

    for (var element in paths) {
      final id = element.getAttribute('id');
      if (id == null) continue;

      // Skip non-muscle parts of the diagram
      if (id == 'body' || id == 'head') {
        continue;
      }

      // Get the calculated intensity for the current muscle path. Default to 0.0 if not found.
      final double intensity = standardizedIntensityMap[id] ?? 0.0;

      final style = element.getAttribute('style');
      if (style != null) {
        // Dynamically set the fill color and the fill-opacity based on workout intensity.
        final newStyle =
            'fill:$muscleColorHex;fill-opacity:$intensity;stroke:#000000;stroke-opacity:1';
        element.setAttribute('style', newStyle);
      }
    }

    if (mounted) {
      setState(() {
        _modifiedSvgData = document.toXmlString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_modifiedSvgData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SvgPicture.string(
      _modifiedSvgData!,
      semanticsLabel:
          'Anatomy of the male body, front view, with muscle intensity highlights',
      width: 300,
    );
  }
}
