import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Exercise {
  final String id;
  final String name;
  final String? description;
  final int? durationExpected; // in seconds
  final int? durationActual; // in seconds
  final int? repetitionsExpected;
  final int? repetitionsActual;
  final String? imagePath;
  final DateTime? startTimestamp;
  final DateTime? endTimestamp;
  final bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.durationExpected,
    this.durationActual,
    this.repetitionsExpected,
    this.repetitionsActual,
    this.imagePath,
    this.startTimestamp,
    this.endTimestamp,
    this.isCompleted = false,
  });

  factory Exercise.create({
    required String name,
    String? description,
    int? durationExpected,
    int? repetitionsExpected,
    String? imagePath,
  }) {
    return Exercise(
      id: const Uuid().v4(),
      name: name,
      description: description,
      durationExpected: durationExpected,
      repetitionsExpected: repetitionsExpected,
      imagePath: imagePath,
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    int? durationExpected,
    int? durationActual,
    int? repetitionsExpected,
    int? repetitionsActual,
    String? imagePath,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
    bool? isCompleted,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationExpected: durationExpected ?? this.durationExpected,
      durationActual: durationActual ?? this.durationActual,
      repetitionsExpected: repetitionsExpected ?? this.repetitionsExpected,
      repetitionsActual: repetitionsActual ?? this.repetitionsActual,
      imagePath: imagePath ?? this.imagePath,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.read();
    final durationExpected = reader.read();
    final durationActual = reader.read();
    final repetitionsExpected = reader.read();
    final repetitionsActual = reader.read();
    final imagePath = reader.read();
    final startMillis = reader.read();
    final endMillis = reader.read();
    final isCompleted = reader.readBool();

    return Exercise(
      id: id,
      name: name,
      description: description,
      durationExpected: durationExpected,
      durationActual: durationActual,
      repetitionsExpected: repetitionsExpected,
      repetitionsActual: repetitionsActual,
      imagePath: imagePath,
      startTimestamp: startMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(startMillis)
          : null,
      endTimestamp: endMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(endMillis)
          : null,
      isCompleted: isCompleted,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.write(obj.description);
    writer.write(obj.durationExpected);
    writer.write(obj.durationActual);
    writer.write(obj.repetitionsExpected);
    writer.write(obj.repetitionsActual);
    writer.write(obj.imagePath);
    writer.write(obj.startTimestamp?.millisecondsSinceEpoch);
    writer.write(obj.endTimestamp?.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
  }
}
