// lib/widgets/performed_set_row.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class PerformedSetRow extends StatefulWidget {
  final PlannedSet plannedSet; // The "target" set from the routine
  final int setIndex;
  final bool isCompleted;
  final Function(double weight, int reps) onUpdate; // Callback to save input
  final VoidCallback onCompleted; // Callback for when the checkmark is tapped

  const PerformedSetRow({
    super.key,
    required this.plannedSet,
    required this.setIndex,
    required this.isCompleted,
    required this.onUpdate,
    required this.onCompleted,
  });

  @override
  State<PerformedSetRow> createState() => _PerformedSetRowState();
}

class _PerformedSetRowState extends State<PerformedSetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the planned values as placeholders
    _weightController = TextEditingController(
      text: widget.plannedSet.targetWeight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.plannedSet.targetReps?.toString() ?? '',
    );

    // Add listeners to call the onUpdate callback whenever the user types
    _weightController.addListener(() {
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final reps = int.tryParse(_repsController.text) ?? 0;
      widget.onUpdate(weight, reps);
    });
    _repsController.addListener(() {
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final reps = int.tryParse(_repsController.text) ?? 0;
      widget.onUpdate(weight, reps);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Greys out the row if it's completed
    final Color inactiveColor = Colors.grey.shade400;
    final bool isEnabled = !widget.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Set Label (e.g., "1", "2", "W")
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                (widget.setIndex + 1).toString(), // Simple set number
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // "Previous" column
          Expanded(child: _buildPreviousColumn()),
          const SizedBox(width: 8),
          // Weight Input
          Expanded(
            child: _buildTextField(
              _weightController,
              'kg',
              isEnabled,
              inactiveColor,
            ),
          ),
          const SizedBox(width: 8),
          // Reps Input
          Expanded(
            child: _buildTextField(
              _repsController,
              'reps',
              isEnabled,
              inactiveColor,
            ),
          ),
          const SizedBox(width: 8),
          // Completion Button
          _buildCompletionButton(),
        ],
      ),
    );
  }

  Widget _buildPreviousColumn() {
    final weight = widget.plannedSet.targetWeight?.toString() ?? '-';
    final reps = widget.plannedSet.targetReps?.toString() ?? '-';
    final text = '$weight kg x $reps reps';

    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isEnabled,
    Color inactiveColor,
  ) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          filled: !isEnabled,
          fillColor: inactiveColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildCompletionButton() {
    return InkWell(
      onTap: widget.onCompleted,
      customBorder: const CircleBorder(),
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
        child:
            widget.isCompleted
                ? const Icon(Icons.check, color: Colors.green, size: 30)
                : null,
      ),
    );
  }
}
