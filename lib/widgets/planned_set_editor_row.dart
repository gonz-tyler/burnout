// lib/widgets/planned_set_editor_row.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../models/enums.dart';

class PlannedSetEditorRow extends StatefulWidget {
  final EditorMode mode;
  final PlannedSet plannedSet;
  final Exercise exercise;
  final int setIndex;
  final List<PlannedSet> allSets;
  final Function(PlannedSet) onChanged;
  final WeightMode weightMode;
  final bool isCompleted;
  final VoidCallback onCompleted;
  final VoidCallback onDelete;

  const PlannedSetEditorRow({
    super.key,
    required this.mode,
    required this.plannedSet,
    required this.exercise,
    required this.setIndex,
    required this.allSets,
    required this.onChanged,
    required this.weightMode,
    required this.isCompleted,
    required this.onCompleted,
    required this.onDelete,
  });

  @override
  State<PlannedSetEditorRow> createState() => _PlannedSetEditorRowState();
}

class _PlannedSetEditorRowState extends State<PlannedSetEditorRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _repsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _repsController = TextEditingController();
    _updateControllers();

    _weightFocusNode.addListener(_onWeightFocusChange);
    _repsFocusNode.addListener(_onRepsFocusChange);
  }

  @override
  void didUpdateWidget(covariant PlannedSetEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plannedSet != oldWidget.plannedSet ||
        widget.weightMode != oldWidget.weightMode) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    final weight = widget.plannedSet.targetWeight ?? 0;
    final displayWeight = weight.abs();
    final weightText =
        displayWeight > 0
            ? displayWeight
                .toStringAsFixed(2)
                .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '')
            : '';
    if (!_weightFocusNode.hasFocus) {
      _weightController.text = weightText;
    }
    if (!_repsFocusNode.hasFocus) {
      _repsController.text = widget.plannedSet.targetReps ?? '';
    }
  }

  void _onWeightFocusChange() {
    if (!_weightFocusNode.hasFocus) {
      final newWeightValue = double.tryParse(_weightController.text) ?? 0.0;
      double finalWeight;
      switch (widget.weightMode) {
        case WeightMode.weighted:
          finalWeight = newWeightValue.abs();
          break;
        case WeightMode.bodyweight:
          finalWeight = 0;
          break;
        case WeightMode.assisted:
          finalWeight = -newWeightValue.abs();
          break;
      }
      widget.onChanged(widget.plannedSet.copyWith(targetWeight: finalWeight));
    }
  }

  void _onRepsFocusChange() {
    if (!_repsFocusNode.hasFocus) {
      widget.onChanged(
        widget.plannedSet.copyWith(targetReps: _repsController.text),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocusNode.removeListener(_onWeightFocusChange);
    _repsFocusNode.removeListener(_onRepsFocusChange);
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _weightFocusNode.hasFocus || _repsFocusNode.hasFocus;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color:
            widget.isCompleted
                ? Colors.green.withOpacity(0.1)
                : (isEditing ? Colors.blue.withOpacity(0.05) : null),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSetLabel(),
          const SizedBox(width: 8),
          if (widget.mode == EditorMode.logging)
            Expanded(child: _buildInfoColumn('--')),
          if (widget.mode == EditorMode.logging) const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildPrimaryField()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSecondaryField()),
          const SizedBox(width: 8),
          _buildRightAction(), // **MODIFIED HERE**
        ],
      ),
    );
  }

  Widget _buildPrimaryField() {
    if (widget.exercise.supportsWeight ||
        widget.exercise.supportsBodyweight ||
        widget.exercise.supportsAssistance) {
      final bool isEnabled =
          widget.weightMode != WeightMode.bodyweight && !widget.isCompleted;
      return _buildEditableField(
        controller: _weightController,
        focusNode: _weightFocusNode,
        isEnabled: isEnabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSecondaryField() {
    if (widget.exercise.tracksReps) {
      return _buildEditableField(
        controller: _repsController,
        focusNode: _repsFocusNode,
        isEnabled: !widget.isCompleted,
        keyboardType: TextInputType.number,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isEnabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: isEnabled,
        textAlign: TextAlign.center,
        keyboardType: keyboardType,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: widget.isCompleted ? Colors.grey.shade600 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSetLabel() {
    return SizedBox(
      width: 50,
      child: Center(child: Text((widget.setIndex + 1).toString())),
    );
  }

  Widget _buildInfoColumn(String value) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // **NEW METHOD** to choose between completion button and delete button
  Widget _buildRightAction() {
    if (widget.mode == EditorMode.planning) {
      // Show delete button in the routine editor
      return SizedBox(
        width: 50,
        height: 50,
        child: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
          onPressed: widget.onDelete,
        ),
      );
    } else {
      // Show completion circle in the active workout
      return GestureDetector(
        onTap: widget.onCompleted,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isCompleted ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder:
                  (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
              child:
                  widget.isCompleted
                      ? const Icon(
                        Icons.check,
                        key: ValueKey('check'),
                        color: Colors.green,
                        size: 30,
                      )
                      : const SizedBox(key: ValueKey('empty')),
            ),
          ),
        ),
      );
    }
  }
}
