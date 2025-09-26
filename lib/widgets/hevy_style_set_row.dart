// lib/widgets/hevy_style_set_row.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class HevyStyleSetRow extends StatefulWidget {
  final PlannedSet plannedSet;
  final int setIndex;
  final bool isCompleted;
  final Function(PlannedSet) onChanged;
  final VoidCallback onCompleted;
  final Exercise exercise;
  final WeightMode weightMode;

  const HevyStyleSetRow({
    super.key,
    required this.plannedSet,
    required this.setIndex,
    required this.isCompleted,
    required this.onChanged,
    required this.onCompleted,
    required this.exercise,
    required this.weightMode,
  });

  @override
  State<HevyStyleSetRow> createState() => _HevyStyleSetRowState();
}

class _HevyStyleSetRowState extends State<HevyStyleSetRow> {
  // MODIFIED: Added controllers and focus nodes for new types
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _distanceController;
  late final TextEditingController _durationController;

  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _repsFocusNode = FocusNode();
  final FocusNode _distanceFocusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _repsController = TextEditingController();
    // NEW: Initialize new controllers
    _distanceController = TextEditingController();
    _durationController = TextEditingController();

    _updateControllers();

    _weightFocusNode.addListener(_onFocusChange);
    _repsFocusNode.addListener(_onFocusChange);
    // NEW: Add listeners for new focus nodes
    _distanceFocusNode.addListener(_onFocusChange);
    _durationFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant HevyStyleSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plannedSet != oldWidget.plannedSet) {
      _updateControllers();
    }
  }

  // MODIFIED: Updates all text fields based on the planned set
  void _updateControllers() {
    _weightController.text =
        widget.plannedSet.targetWeight
            ?.toStringAsFixed(1)
            .replaceAll(RegExp(r'\.0$'), '') ??
        '';
    _repsController.text = widget.plannedSet.targetReps ?? '';
    // NEW: Populate distance and duration fields
    _distanceController.text =
        widget.plannedSet.targetDistanceInMeters?.toString() ?? '';
    _durationController.text = _formatDuration(
      widget.plannedSet.targetDurationInSeconds,
    );
  }

  // MODIFIED: Checks all focus nodes before updating
  void _onFocusChange() {
    if (!_weightFocusNode.hasFocus &&
        !_repsFocusNode.hasFocus &&
        !_distanceFocusNode.hasFocus &&
        !_durationFocusNode.hasFocus) {
      _updatePlannedSet();
    }
  }

  // MODIFIED: Saves data from all possible fields
  void _updatePlannedSet() {
    final updatedSet = widget.plannedSet.copyWith(
      targetWeight: double.tryParse(_weightController.text),
      targetReps: _repsController.text.isNotEmpty ? _repsController.text : null,
      targetDistanceInMeters: int.tryParse(_distanceController.text),
      targetDurationInSeconds: _parseDuration(_durationController.text),
    );
    widget.onChanged(updatedSet);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _distanceController.dispose();
    _durationController.dispose();

    _weightFocusNode.removeListener(_onFocusChange);
    _repsFocusNode.removeListener(_onFocusChange);
    _distanceFocusNode.removeListener(_onFocusChange);
    _durationFocusNode.removeListener(_onFocusChange);

    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    _distanceFocusNode.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  // MODIFIED: The build method is now cleaner and uses a helper
  @override
  Widget build(BuildContext context) {
    final bool isWarmup = widget.plannedSet.setType == SetType.warmup;
    final Color activeColor =
        isWarmup ? Colors.orange : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          _buildSetNumber(context, activeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "--",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ),
          ..._buildExerciseFields(), // SPREAD OPERATOR to add dynamic fields
          const SizedBox(width: 8),
          _buildCompletionButton(context),
        ],
      ),
    );
  }

  // NEW: Helper method to dynamically generate the correct input fields
  List<Widget> _buildExerciseFields() {
    final exercise = widget.exercise;
    final isCompleted = widget.isCompleted;
    final isWeightEnabled =
        widget.weightMode != WeightMode.bodyweight && !isCompleted;
    final List<Widget> fields = [];

    // Weight Field
    if (exercise.supportsWeight ||
        exercise.supportsBodyweight ||
        exercise.supportsAssistance) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _weightController,
          _weightFocusNode,
          placeholder: '0',
          label: '',
          isEnabled: isWeightEnabled,
        ),
      );
    }

    // Reps Field
    if (exercise.tracksReps) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _repsController,
          _repsFocusNode,
          placeholder: '0',
          label: '',
          isEnabled: !isCompleted,
        ),
      );
    }

    // Distance Field
    if (exercise.tracksDistance) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _distanceController,
          _distanceFocusNode,
          placeholder: '0',
          label: '',
          isEnabled: !isCompleted,
          keyboardType: TextInputType.number,
        ),
      );
    }

    // Duration Field
    if (exercise.tracksDuration) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _durationController,
          _durationFocusNode,
          placeholder: '0:00',
          label: '',
          isEnabled: !isCompleted,
          keyboardType: TextInputType.datetime,
        ),
      );
    }

    return fields;
  }

  Widget _buildSetNumber(BuildContext context, Color activeColor) {
    // ... (This widget is unchanged)
    final isWarmup = widget.plannedSet.setType == SetType.warmup;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isCompleted ? activeColor : Colors.transparent,
        border: Border.all(
          color:
              widget.isCompleted
                  ? Colors.transparent
                  : Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          isWarmup ? 'W' : (widget.setIndex + 1).toString(),
          style: TextStyle(
            color:
                widget.isCompleted
                    ? Theme.of(context).colorScheme.onPrimary
                    : activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isCompleted) {
          _weightFocusNode.unfocus();
          _repsFocusNode.unfocus();
          _distanceFocusNode.unfocus();
          _durationFocusNode.unfocus();
        }
        widget.onCompleted();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              widget.isCompleted
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.onPrimary,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder:
              (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
          child:
              widget.isCompleted
                  ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    key: ValueKey('check'),
                  )
                  : const SizedBox(key: ValueKey('empty')),
        ),
      ),
    );
  }

  // MODIFIED: This widget is now more flexible
  Widget _buildEditableField(
    TextEditingController controller,
    FocusNode focusNode, {
    required String placeholder,
    String? label,
    bool isEnabled = true,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return SizedBox(
      width: 80,
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: isEnabled,
        textAlign: TextAlign.center,
        keyboardType: keyboardType,
        inputFormatters: [
          if (keyboardType == TextInputType.datetime)
            FilteringTextInputFormatter.allow(RegExp(r'[\d:]'))
          else
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: placeholder,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          filled: true,
          fillColor:
              isEnabled
                  ? Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          contentPadding: const EdgeInsets.only(top: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // NEW: Helper to format seconds into a mm:ss string
  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds == 0) return '';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // NEW: Helper to parse mm:ss string back to seconds
  int? _parseDuration(String text) {
    if (text.isEmpty) return null;
    int totalSeconds = 0;
    if (text.contains(':')) {
      final parts = text.split(':');
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      totalSeconds = (minutes * 60) + seconds;
    } else {
      totalSeconds = int.tryParse(text) ?? 0;
    }
    return totalSeconds > 0 ? totalSeconds : null;
  }
}
