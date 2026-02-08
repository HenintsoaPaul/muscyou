import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise.dart';

class SessionTemplate {
  final String id;
  final String name;
  final String? description;
  final List<Exercise> exercises; // These act as templates

  SessionTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
  });

  factory SessionTemplate.create({
    required String name,
    String? description,
    List<Exercise>? exercises,
  }) {
    return SessionTemplate(
      id: const Uuid().v4(),
      name: name,
      description: description,
      exercises: exercises ?? [],
    );
  }
}

class SessionTemplateAdapter extends TypeAdapter<SessionTemplate> {
  @override
  final int typeId = 2; // Unique ID

  @override
  SessionTemplate read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.read();
    final exercises = (reader.read() as List).cast<Exercise>().toList();

    return SessionTemplate(
      id: id,
      name: name,
      description: description,
      exercises: exercises,
    );
  }

  @override
  void write(BinaryWriter writer, SessionTemplate obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.write(obj.description);
    writer.write(obj.exercises);
  }
}
