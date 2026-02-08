import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise.dart';

class Session {
  final String id;
  final String name;
  final String? description;
  final List<Exercise> exercises;
  final DateTime? startTimestamp;
  final DateTime? endTimestamp;
  final bool isCompleted;

  Session({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    this.startTimestamp,
    this.endTimestamp,
    this.isCompleted = false,
  });

  factory Session.create({
    required String name,
    String? description,
    List<Exercise>? exercises,
  }) {
    return Session(
      id: const Uuid().v4(),
      name: name,
      description: description,
      exercises: exercises ?? [],
      startTimestamp: null,
      // MVP: Let's assume creation != start, but prompt says "A session must be created before being executed".
      // So startTimestamp might be null initially.
    );
  }

  Session copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
    bool? isCompleted,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Duration get duration {
    if (startTimestamp == null) return Duration.zero;
    final end = endTimestamp ?? DateTime.now();
    return end.difference(startTimestamp!);
  }
}

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 1;

  @override
  Session read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.read();
    final exercises = (reader.read() as List).cast<Exercise>().toList();
    final startMillis = reader.read();
    final endMillis = reader.read();
    final isCompleted = reader.readBool();

    return Session(
      id: id,
      name: name,
      description: description,
      exercises: exercises,
      startTimestamp: startMillis != null ? DateTime.fromMillisecondsSinceEpoch(startMillis) : null,
      endTimestamp: endMillis != null ? DateTime.fromMillisecondsSinceEpoch(endMillis) : null,
      isCompleted: isCompleted,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.write(obj.description);
    writer.write(obj.exercises);
    writer.write(obj.startTimestamp?.millisecondsSinceEpoch);
    writer.write(obj.endTimestamp?.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
  }
}
