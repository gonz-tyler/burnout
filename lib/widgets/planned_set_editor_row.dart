// lib/widgets/planned_set_editor_row.dart

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/user_settings_provider.dart';
import '../models/enums.dart';

// The WeightMode enum can be kept here or moved to a central models file
// if it's used in many places.
// enum WeightMode { weighted, bodyweight, assisted }

class PlannedSetEditorRow extends StatefulWidget {
  final PlannedSet plannedSet;
  final Exercise exercise;
  final int setIndex;
  final List<PlannedSet> allSets;
  final Function(PlannedSet) onChanged;
  final VoidCallback onDelete;
  final WeightMode weightMode; // <-- ADD THIS

  const PlannedSetEditorRow({
    Key? key,
    required this.plannedSet,
    required this.exercise,
    required this.setIndex,
    required this.allSets,
    required this.onChanged,
    required this.onDelete,
    required this.weightMode, // <-- ADD THIS
  }) : super(key: key);

  @override
  State<PlannedSetEditorRow> createState() => _PlannedSetEditorRowState();
}

class _PlannedSetEditorRowState extends State<PlannedSetEditorRow> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllersFromWidget();
  }

  @override
  void didUpdateWidget(covariant PlannedSetEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync controllers if the underlying data object changes
    if (widget.plannedSet != oldWidget.plannedSet) {
      _updateControllersFromWidget();
    }
  }

  void _updateControllersFromWidget() {
    // Sync the weight controller
    final weight = widget.plannedSet.targetWeight ?? 0;
    final modelWeightAbs = weight.abs();
    final controllerValue = double.tryParse(_weightController.text);

    if (controllerValue != modelWeightAbs ||
        (modelWeightAbs == 0 && _weightController.text.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          String newText =
              modelWeightAbs > 0
                  ? modelWeightAbs
                      .toStringAsFixed(2)
                      .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '')
                  : '';
          if (_weightController.text != newText) {
            _weightController.text = newText;
          }
        }
      });
    }

    // Sync the reps controller
    final repsText = widget.plannedSet.targetReps ?? '';
    if (_repsController.text != repsText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _repsController.text = repsText;
        }
      });
    }
  }

  void _applyWeightFromInput() {
    final inputWeight = double.tryParse(_weightController.text) ?? 0;
    double finalWeight;

    // Use the mode passed from the parent widget
    switch (widget.weightMode) {
      case WeightMode.weighted:
        finalWeight = inputWeight.abs();
        break;
      case WeightMode.bodyweight:
        finalWeight = 0;
        break;
      case WeightMode.assisted:
        finalWeight = -inputWeight.abs();
        break;
    }

    widget.onChanged(widget.plannedSet.copyWith(targetWeight: finalWeight));
  }

  String _getWeightModeLabel() {
    switch (widget.weightMode) {
      case WeightMode.weighted:
        final settings = context.read<UserSettingsProvider>();
        return settings.weightUnit.name.toUpperCase();
      case WeightMode.bodyweight:
        return 'BODY';
      case WeightMode.assisted:
        return 'ASSIST';
    }
  }

  Color _getWeightModeColor() {
    switch (widget.weightMode) {
      case WeightMode.weighted:
        return Colors.blue;
      case WeightMode.bodyweight:
        return Colors.green;
      case WeightMode.assisted:
        return Colors.orange;
    }
  }

  // --- The rest of the file remains largely the same, but for completeness ---
  // --- it's provided below with the necessary modifications in _buildWeightField ---

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSetLabel(),
          const SizedBox(width: 8),
          Expanded(child: _buildInfoColumn('PREV', '--')),
          const SizedBox(width: 8),
          Expanded(child: _buildPrimaryField()),
          const SizedBox(width: 8),
          Expanded(child: _buildSecondaryField()),
          const SizedBox(width: 8),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildPrimaryField() {
    if (widget.exercise.tracksDistance) {
      return _InputColumn(
        label:
            context
                .watch<UserSettingsProvider>()
                .distanceUnit
                .name, // Updated to match parent header
        child: _buildTextField(
          controller: null,
          hint: '',
          initialValue:
              widget.plannedSet.targetDistanceInMeters?.toString() ?? '',
          onChanged: (val) {
            widget.onChanged(
              widget.plannedSet.copyWith(
                targetDistanceInMeters: int.tryParse(val),
              ),
            );
          },
        ),
      );
    }

    if (widget.exercise.supportsWeight ||
        widget.exercise.supportsBodyweight ||
        widget.exercise.supportsAssistance) {
      return _buildWeightField();
    }

    return const SizedBox.shrink();
  }

  Widget _buildWeightField() {
    final weightModeLabel = _getWeightModeLabel();
    final weightModeColor = _getWeightModeColor();
    // Enable/disable based on the mode passed from the parent
    final isEnabled = widget.weightMode != WeightMode.bodyweight;

    return _InputColumn(
      label: '', // The header in the parent screen now shows the label
      child: _buildTextField(
        controller: _weightController,
        isEnabled: isEnabled,
        hint: '',
        onChanged: (value) {
          _applyWeightFromInput();
        },
      ),
    );
  }

  Widget _buildSecondaryField() {
    if (widget.exercise.tracksDuration) {
      return _InputColumn(
        label: '',
        child: _buildTextField(
          controller: null,
          hint: '',
          initialValue: _formatDuration(
            widget.plannedSet.targetDurationInSeconds ?? 0,
          ),
          onChanged: (val) {},
          isTimeField: true,
          onTap: _showDurationPicker,
        ),
      );
    }

    if (widget.exercise.tracksReps) {
      return _InputColumn(
        label: '',
        child: _buildTextField(
          controller: _repsController,
          hint: '',
          onChanged: (val) {
            widget.onChanged(widget.plannedSet.copyWith(targetReps: val));
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // The rest of the helper methods (_showSetTypePicker, _showDurationPicker, etc.)
  // and widgets (_InputColumn, _DurationPickerColumn, etc.) do not need changes.
  // For brevity, I will omit them, but you should keep them in your file.
  // The provided code includes stubs for them.

  void _showSetTypePicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children:
                  SetType.values
                      .map(
                        (type) => ListTile(
                          leading: CircleAvatar(child: Text(type.abbreviation)),
                          title: Text(
                            type.name[0].toUpperCase() + type.name.substring(1),
                          ),
                          onTap: () {
                            widget.onChanged(
                              widget.plannedSet.copyWith(setType: type),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  Future<void> _showDurationPicker() async {
    int currentDuration = widget.plannedSet.targetDurationInSeconds ?? 0;
    int h = currentDuration ~/ 3600;
    int m = (currentDuration % 3600) ~/ 60;
    int s = currentDuration % 60;

    final newTotalSeconds = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempH = h, tempM = m, tempS = s;
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Set Duration'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DurationPickerColumn(
                    label: 'H',
                    value: tempH,
                    onChanged: (value) => setStateInDialog(() => tempH = value),
                  ),
                  _DurationPickerColumn(
                    label: 'M',
                    value: tempM,
                    onChanged: (value) => setStateInDialog(() => tempM = value),
                  ),
                  _DurationPickerColumn(
                    label: 'S',
                    value: tempS,
                    onChanged: (value) => setStateInDialog(() => tempS = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final totalSeconds = (tempH * 3600) + (tempM * 60) + tempS;
                    Navigator.of(context).pop(totalSeconds);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newTotalSeconds != null) {
      widget.onChanged(
        widget.plannedSet.copyWith(targetDurationInSeconds: newTotalSeconds),
      );
    }
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  Widget _buildSetLabel() {
    final setType = widget.plannedSet.setType;
    final Color setLabelColor;
    switch (setType) {
      case SetType.warmup:
        setLabelColor = Colors.orange;
        break;
      case SetType.failure:
        setLabelColor = Colors.red;
        break;
      case SetType.dropset:
        setLabelColor = Colors.blue;
        break;
      default:
        setLabelColor = Theme.of(context).colorScheme.primary;
    }

    return SizedBox(
      width: 50,
      child: SizedBox(
        height: 40,
        child: TextButton(
          onPressed: _showSetTypePicker,
          child: Text(getSetLabel(widget.setIndex, widget.allSets)),
          style: TextButton.styleFrom(
            foregroundColor: setLabelColor,
            side: BorderSide(color: setLabelColor.withOpacity(0.5)),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return _InputColumn(
      label: '', // Label is in the parent header
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required Function(String) onChanged,
    String hint = '',
    bool isEnabled = true,
    String? initialValue,
    bool isTimeField = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        initialValue: controller == null ? initialValue : null,
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: isTimeField,
        keyboardType:
            isTimeField
                ? null
                : const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        enabled: isEnabled,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          filled: !isEnabled,
          fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: widget.onDelete,
      customBorder: const CircleBorder(),
      child: const SizedBox(
        height: 50,
        width: 50,
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Icon(Icons.remove_circle_outline, color: Colors.grey),
        ),
      ),
    );
  }
}

class _DurationPickerColumn extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const _DurationPickerColumn({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        NumberPicker(
          minValue: 0,
          maxValue: label == 'H' ? 23 : 59,
          value: value,
          onChanged: onChanged,
          itemHeight: 40,
          itemWidth: 50,
          selectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _InputColumn extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onLabelTap;
  final double? width;
  final Color? labelColor;

  const _InputColumn({
    required this.label,
    required this.child,
    this.onLabelTap,
    this.width,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClickable = onLabelTap != null;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          // The labels are now in the parent header, so this is not needed for each row
          // to avoid visual clutter.
          // You can add it back if you prefer.
          // SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

String getSetLabel(int setIndex, List<PlannedSet> allSets) {
  final set = allSets[setIndex];
  switch (set.setType) {
    case SetType.warmup:
      return 'W';
    case SetType.failure:
      return 'F';
    case SetType.dropset:
      return 'D';
    case SetType.normal:
      int workingSetCounter = 0;
      for (int i = 0; i <= setIndex; i++) {
        if (allSets[i].setType == SetType.normal ||
            allSets[i].setType == SetType.failure) {
          workingSetCounter++;
        }
      }
      return workingSetCounter.toString();
  }
}
