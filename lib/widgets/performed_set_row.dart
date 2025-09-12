// lib/widgets/performed_set_row.dart

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/user_settings_provider.dart';
import '../models/enums.dart';

class PerformedSetRow extends StatefulWidget {
  final PlannedSet plannedSet;
  final Exercise exercise;
  final int setIndex;
  final List<PlannedSet> allSets;
  final Function(PlannedSet) onChanged;
  final WeightMode weightMode;
  final bool isCompleted;
  final VoidCallback onCompleted;

  const PerformedSetRow({
    Key? key,
    required this.plannedSet,
    required this.exercise,
    required this.setIndex,
    required this.allSets,
    required this.onChanged,
    required this.weightMode,
    required this.isCompleted,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<PerformedSetRow> createState() => _PerformedSetRowState();
}

class _PerformedSetRowState extends State<PerformedSetRow> {
  String? _weightText;
  String? _repsText;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _updateDisplayValues();
  }

  @override
  void didUpdateWidget(covariant PerformedSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plannedSet != oldWidget.plannedSet ||
        widget.weightMode != oldWidget.weightMode) {
      _updateDisplayValues();
    }
  }

  void _updateDisplayValues() {
    // Update weight display
    final weight = widget.plannedSet.targetWeight ?? 0;
    final displayWeight = weight.abs();
    _weightText =
        displayWeight > 0
            ? displayWeight
                .toStringAsFixed(2)
                .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '')
            : '';

    // Update reps display
    _repsText = widget.plannedSet.targetReps ?? '';
  }

  void _handleWeightTap() {
    if (widget.isCompleted) return;

    setState(() => _isEditing = true);

    showDialog(
      context: context,
      builder:
          (context) => _WeightDialog(
            initialWeight: _weightText ?? '',
            onChanged: (newWeight) {
              double finalWeight;
              switch (widget.weightMode) {
                case WeightMode.weighted:
                  finalWeight = newWeight.abs();
                  break;
                case WeightMode.bodyweight:
                  finalWeight = 0;
                  break;
                case WeightMode.assisted:
                  finalWeight = -newWeight.abs();
                  break;
              }
              widget.onChanged(
                widget.plannedSet.copyWith(targetWeight: finalWeight),
              );
            },
          ),
    ).then((_) {
      if (mounted) {
        setState(() => _isEditing = false);
      }
    });
  }

  void _handleRepsTap() {
    if (widget.isCompleted) return;

    setState(() => _isEditing = true);

    showDialog(
      context: context,
      builder:
          (context) => _RepsDialog(
            initialReps: _repsText ?? '',
            onChanged: (newReps) {
              widget.onChanged(widget.plannedSet.copyWith(targetReps: newReps));
            },
          ),
    ).then((_) {
      if (mounted) {
        setState(() => _isEditing = false);
      }
    });
  }

  void _handleDurationTap() {
    if (widget.isCompleted) return;

    setState(() => _isEditing = true);
    _showDurationPicker().then((_) {
      if (mounted) {
        setState(() => _isEditing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color:
            widget.isCompleted
                ? Colors.green.withOpacity(0.1)
                : (_isEditing ? Colors.blue.withOpacity(0.05) : null),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSetLabel(),
          const SizedBox(width: 8),
          Expanded(child: _buildInfoColumn('--')),
          const SizedBox(width: 8),
          Expanded(child: _buildPrimaryField()),
          const SizedBox(width: 8),
          Expanded(child: _buildSecondaryField()),
          const SizedBox(width: 8),
          _buildCompletionButton(),
        ],
      ),
    );
  }

  Widget _buildPrimaryField() {
    if (widget.exercise.tracksDistance) {
      final distance =
          widget.plannedSet.targetDistanceInMeters?.toString() ?? '';
      return _buildTappableField(distance, null);
    }

    if (widget.exercise.supportsWeight ||
        widget.exercise.supportsBodyweight ||
        widget.exercise.supportsAssistance) {
      return _buildWeightField();
    }

    return const SizedBox.shrink();
  }

  Widget _buildWeightField() {
    final isEnabled =
        widget.weightMode != WeightMode.bodyweight && !widget.isCompleted;
    return _buildTappableField(
      _weightText ?? '',
      isEnabled ? _handleWeightTap : null,
    );
  }

  Widget _buildSecondaryField() {
    if (widget.exercise.tracksDuration) {
      final durationText = _formatDuration(
        widget.plannedSet.targetDurationInSeconds ?? 0,
      );
      return _buildTappableField(
        durationText,
        !widget.isCompleted ? _handleDurationTap : null,
      );
    }

    if (widget.exercise.tracksReps) {
      return _buildTappableField(
        _repsText ?? '',
        !widget.isCompleted ? _handleRepsTap : null,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTappableField(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          color:
              widget.isCompleted
                  ? Colors.grey.shade100
                  : (onTap != null ? Colors.white : Colors.grey.shade50),
        ),
        child: Center(
          child: Text(
            text.isEmpty ? '' : text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: widget.isCompleted ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
        ),
      ),
    );
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
      child: GestureDetector(
        onTap: !widget.isCompleted ? _showSetTypePicker : null,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: setLabelColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              _getSetLabel(widget.setIndex, widget.allSets),
              style: TextStyle(
                color: setLabelColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value) {
    return Container(
      height: 40,
      child: Center(
        child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }

  Widget _buildCompletionButton() {
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
        child:
            widget.isCompleted
                ? const Icon(Icons.check, color: Colors.green, size: 30)
                : null,
      ),
    );
  }

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

  String _getSetLabel(int setIndex, List<PlannedSet> allSets) {
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
}

class _WeightDialog extends StatefulWidget {
  final String initialWeight;
  final Function(double) onChanged;

  const _WeightDialog({required this.initialWeight, required this.onChanged});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWeight);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Weight'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final weight = double.tryParse(_controller.text) ?? 0;
            widget.onChanged(weight);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _RepsDialog extends StatefulWidget {
  final String initialReps;
  final Function(String) onChanged;

  const _RepsDialog({required this.initialReps, required this.onChanged});

  @override
  State<_RepsDialog> createState() => _RepsDialogState();
}

class _RepsDialogState extends State<_RepsDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReps);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Reps'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onChanged(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
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
