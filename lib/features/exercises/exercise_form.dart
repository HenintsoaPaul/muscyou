import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';

class ExerciseForm extends StatefulWidget {
  final Exercise? initialExercise;
  final Function(String name, String? description) onSave;

  const ExerciseForm({super.key, this.initialExercise, required this.onSave});

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialExercise?.name);
    _descController = TextEditingController(
      text: widget.initialExercise?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExercise != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit Exercise' : 'New Exercise',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            autofocus: !isEditing,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                widget.onSave(_nameController.text, _descController.text);
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update Exercise' : 'Save Exercise'),
          ),
        ],
      ),
    );
  }
}
