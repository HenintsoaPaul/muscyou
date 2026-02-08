import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../models/session_template.dart';

class HiveService {
  static const String exerciseBoxName = 'exercises';
  static const String sessionBoxName = 'sessions';
  static const String templateBoxName = 'templates';

  Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(SessionTemplateAdapter());

    await Hive.openBox<Exercise>(exerciseBoxName);
    await Hive.openBox<Session>(sessionBoxName);
    await Hive.openBox<SessionTemplate>(templateBoxName);
  }
  
  Box<Exercise> get exerciseBox => Hive.box<Exercise>(exerciseBoxName);
  Box<Session> get sessionBox => Hive.box<Session>(sessionBoxName);
  Box<SessionTemplate> get templateBox => Hive.box<SessionTemplate>(templateBoxName);
}
