// lib/widgets/hevy_style_set_row.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../models/enums.dart';

class HevyStyleSetRow extends StatefulWidget {
  final PlannedSet plannedSet;
  final Exercise exercise;
  final int setIndex;
  final Function(PlannedSet) onChanged;
  final WeightMode weightMode;
  final bool isCompleted;
  final VoidCallback onCompleted;

  const HevyStyleSetRow({
    super.key,
    required this.plannedSet,
    required this.exercise,
    required this.setIndex,
    required this.onChanged,
    required this.weightMode,
    required this.isCompleted,
    required this.onCompleted,
  });

  @override
  State<HevyStyleSetRow> createState() => _HevyStyleSetRowState();
}

class _HevyStyleSetRowState extends State<HevyStyleSetRow> {
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
  void didUpdateWidget(covariant HevyStyleSetRow oldWidget) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSetNumber(),
          Text(
            "--",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          _buildEditableField(
            controller: _weightController,
            focusNode: _weightFocusNode,
            hint: '0',
            isEnabled:
                widget.weightMode != WeightMode.bodyweight &&
                !widget.isCompleted,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (widget.exercise.tracksReps)
            _buildEditableField(
              controller: _repsController,
              focusNode: _repsFocusNode,
              hint: '0',
              isEnabled: !widget.isCompleted,
              keyboardType: TextInputType.number,
            ),
          _buildCompletionButton(),
        ],
      ),
    );
  }

  Widget _buildSetNumber() {
    final bool isWarmup = widget.plannedSet.setType == SetType.warmup;
    final bool isFailure = widget.plannedSet.setType == SetType.failure;
    final Color color =
        isWarmup ? Colors.orange : (isFailure ? Colors.red : Colors.blue);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              widget.isCompleted ? Colors.transparent : color.withOpacity(0.5),
          width: 2,
        ),
        color: widget.isCompleted ? color : Colors.transparent,
      ),
      child: Center(
        child: Text(
          isWarmup ? 'W' : (widget.setIndex + 1).toString(),
          style: TextStyle(
            color: widget.isCompleted ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton() {
    return GestureDetector(
      onTap: widget.onCompleted,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isCompleted ? Colors.green : Colors.grey.shade200,
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

  Widget _buildEditableField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    bool isEnabled = true,
    TextInputType keyboardType = TextInputType.text,
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: isEnabled ? Colors.grey.shade100 : Colors.grey.shade50,
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
