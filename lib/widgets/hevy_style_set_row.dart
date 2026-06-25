// lib/widgets/hevy_style_set_row.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../models/enums.dart';

class HevyStyleSetRow extends StatefulWidget {
  final PlannedSet plannedSet;
  final int setIndex;
  // 🟢 NEW: The visual number to display (e.g. "1" for the first non-warmup set)
  final int displayIndex;
  final bool isCompleted;
  final Function(PlannedSet) onChanged;
  final VoidCallback onCompleted;
  final Exercise exercise;
  final WeightMode weightMode;
  final Function(SetType) onTypeChanged;

  const HevyStyleSetRow({
    super.key,
    required this.plannedSet,
    required this.setIndex,
    required this.displayIndex, // 🟢 Add this
    required this.isCompleted,
    required this.onChanged,
    required this.onCompleted,
    required this.exercise,
    required this.weightMode,
    required this.onTypeChanged,
  });

  @override
  State<HevyStyleSetRow> createState() => _HevyStyleSetRowState();
}

class _HevyStyleSetRowState extends State<HevyStyleSetRow> {
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
    _distanceController = TextEditingController();
    _durationController = TextEditingController();

    _updateControllers();

    _weightFocusNode.addListener(_onFocusChange);
    _repsFocusNode.addListener(_onFocusChange);
    _distanceFocusNode.addListener(_onFocusChange);
    _durationFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant HevyStyleSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plannedSet != oldWidget.plannedSet) {
      if (!_weightFocusNode.hasFocus) {
        _weightController.text = _formatWeight(widget.plannedSet.targetWeight);
      }
      if (!_repsFocusNode.hasFocus) {
        _repsController.text = widget.plannedSet.targetReps ?? '';
      }
      if (!_distanceFocusNode.hasFocus) {
        _distanceController.text =
            widget.plannedSet.targetDistanceInMeters?.toString() ?? '';
      }
      if (!_durationFocusNode.hasFocus) {
        _durationController.text = _formatDuration(
          widget.plannedSet.targetDurationInSeconds,
        );
      }
    }
  }

  String _formatWeight(double? weight) {
    return weight?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') ?? '';
  }

  void _updateControllers() {
    _weightController.text = _formatWeight(widget.plannedSet.targetWeight);
    _repsController.text = widget.plannedSet.targetReps ?? '';
    _distanceController.text =
        widget.plannedSet.targetDistanceInMeters?.toString() ?? '';
    _durationController.text = _formatDuration(
      widget.plannedSet.targetDurationInSeconds,
    );
  }

  void _onFocusChange() {
    if (!_weightFocusNode.hasFocus &&
        !_repsFocusNode.hasFocus &&
        !_distanceFocusNode.hasFocus &&
        !_durationFocusNode.hasFocus) {
      _updatePlannedSet();
    }
  }

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

  void _showSetTypeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Set Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTypeOption(
                context,
                SetType.normal,
                'Normal',
                Colors.transparent,
              ),
              _buildTypeOption(
                context,
                SetType.warmup,
                'Warmup',
                Colors.orange,
              ),
              _buildTypeOption(context, SetType.failure, 'Failure', Colors.red),
              _buildTypeOption(
                context,
                SetType.dropset,
                'Drop Set',
                Colors.purple,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    SetType type,
    String label,
    Color color,
  ) {
    final isSelected = widget.plannedSet.setType == type;
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color == Colors.transparent ? Colors.grey[400] : color,
          shape: BoxShape.circle,
        ),
        child:
            isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
      title: Text(label),
      onTap: () {
        widget.onTypeChanged(type);
        Navigator.pop(context);
      },
    );
  }

  Color _getRowBackgroundColor(ThemeData theme) {
    if (widget.isCompleted)
      return theme.colorScheme.primaryContainer.withAlpha(255);

    switch (widget.plannedSet.setType) {
      case SetType.warmup:
        return Colors.orange.withAlpha(79);
      case SetType.failure:
        return Colors.red.withAlpha(79);
      case SetType.dropset:
        return Colors.purple.withAlpha(79);
      default:
        return Colors.grey.withAlpha(79);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarmup = widget.plannedSet.setType == SetType.warmup;
    final isFailure = widget.plannedSet.setType == SetType.failure;
    final isDrop = widget.plannedSet.setType == SetType.dropset;

    final activeColor =
        isWarmup
            ? Colors.orange
            : isFailure
            ? Colors.red
            : isDrop
            ? Colors.purple
            : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        color: _getRowBackgroundColor(theme),
      ),

      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
      child: Row(
        children: [
          _buildSetNumber(context, activeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "-", // Placeholder for Previous data
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ),
          ..._buildExerciseFields(),
          const SizedBox(width: 8),
          _buildCompletionButton(context),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseFields() {
    final exercise = widget.exercise;
    final isCompleted = widget.isCompleted;
    final isWeightEnabled =
        widget.weightMode != WeightMode.bodyweight && !isCompleted;
    final List<Widget> fields = [];

    if (exercise.supportsWeight ||
        exercise.supportsBodyweight ||
        exercise.supportsAssistance) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _weightController,
          _weightFocusNode,
          placeholder: '0',
          isEnabled: isWeightEnabled,
        ),
      );
    }

    if (exercise.tracksReps) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _repsController,
          _repsFocusNode,
          placeholder: '0',
          isEnabled: !isCompleted,
        ),
      );
    }

    if (exercise.tracksDistance) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _distanceController,
          _distanceFocusNode,
          placeholder: '0',
          isEnabled: !isCompleted,
          keyboardType: TextInputType.number,
        ),
      );
    }

    if (exercise.tracksDuration) {
      fields.add(const SizedBox(width: 8));
      fields.add(
        _buildEditableField(
          _durationController,
          _durationFocusNode,
          placeholder: '0:00',
          isEnabled: !isCompleted,
          keyboardType: TextInputType.datetime,
        ),
      );
    }

    return fields;
  }

  Widget _buildSetNumber(BuildContext context, Color activeColor) {
    String label;
    // 🟢 UPDATED LOGIC:
    switch (widget.plannedSet.setType) {
      case SetType.warmup:
        label = "W";
        break;
      case SetType.failure:
        label = "F";
        break;
      case SetType.dropset:
        label = "D";
        break;
      // Use the displayIndex we passed in, which accounts for skipping warmups
      default:
        label = widget.displayIndex.toString();
    }

    return SizedBox(
      width: 40,
      child: InkWell(
        onTap: () => _showSetTypeMenu(context),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isCompleted ? activeColor : activeColor.withAlpha(26),
            border: Border.all(
              color:
                  widget.isCompleted
                      ? Colors.transparent
                      : activeColor.withAlpha(127),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: widget.isCompleted ? Colors.white : activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant.withAlpha(128),
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

  Widget _buildEditableField(
    TextEditingController controller,
    FocusNode focusNode, {
    required String placeholder,
    bool isEnabled = true,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return SizedBox(
      width: 80,
      height: 40,
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
          filled: true,
          fillColor:
              isEnabled
                  ? Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.3),
          contentPadding: const EdgeInsets.only(bottom: 8.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds == 0) return '';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

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
