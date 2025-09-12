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
  final WeightMode weightMode; // <-- ADDED THIS

  const HevyStyleSetRow({
    super.key,
    required this.plannedSet,
    required this.setIndex,
    required this.isCompleted,
    required this.onChanged,
    required this.onCompleted,
    required this.exercise,
    required this.weightMode, // <-- ADDED THIS
  });

  @override
  State<HevyStyleSetRow> createState() => _HevyStyleSetRowState();
}

class _HevyStyleSetRowState extends State<HevyStyleSetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _repsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _repsController = TextEditingController();
    _updateControllers();

    _weightFocusNode.addListener(_onFocusChange);
    _repsFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant HevyStyleSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the planned set data changes from the parent, update the text fields
    if (widget.plannedSet != oldWidget.plannedSet) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    _weightController.text =
        widget.plannedSet.targetWeight
            ?.toStringAsFixed(1)
            .replaceAll(RegExp(r'\.0$'), '') ??
        '';
    _repsController.text = widget.plannedSet.targetReps ?? '';
  }

  void _onFocusChange() {
    if (!_weightFocusNode.hasFocus && !_repsFocusNode.hasFocus) {
      _updatePlannedSet();
    }
  }

  void _updatePlannedSet() {
    final updatedSet = widget.plannedSet.copyWith(
      targetWeight: double.tryParse(_weightController.text),
      targetReps: _repsController.text,
    );
    widget.onChanged(updatedSet);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocusNode.removeListener(_onFocusChange);
    _repsFocusNode.removeListener(_onFocusChange);
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWarmup = widget.plannedSet.setType == SetType.warmup;
    final Color activeColor =
        isWarmup ? Colors.orange : Theme.of(context).colorScheme.primary;
    final bool isWeightEnabled =
        widget.weightMode != WeightMode.bodyweight && !widget.isCompleted;

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
          const SizedBox(width: 8),
          if (widget.exercise.supportsWeight ||
              widget.exercise.supportsBodyweight ||
              widget.exercise.supportsAssistance)
            _buildEditableField(
              _weightController,
              _weightFocusNode,
              '0',
              isEnabled: isWeightEnabled,
            ),
          if ((widget.exercise.supportsWeight ||
                  widget.exercise.supportsBodyweight ||
                  widget.exercise.supportsAssistance) &&
              widget.exercise.tracksReps)
            const SizedBox(width: 8),
          if (widget.exercise.tracksReps)
            _buildEditableField(
              _repsController,
              _repsFocusNode,
              '0',
              isEnabled: !widget.isCompleted,
            ),
          const SizedBox(width: 8),
          _buildCompletionButton(context),
        ],
      ),
    );
  }

  Widget _buildSetNumber(BuildContext context, Color activeColor) {
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
                  ? Colors.green
                  : Theme.of(context).colorScheme.surfaceVariant,
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
    FocusNode focusNode,
    String hint, {
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: 80,
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: isEnabled,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor:
              isEnabled
                  ? Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
