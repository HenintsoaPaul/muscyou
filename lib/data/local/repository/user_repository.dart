import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:muscyou/data/local/local_db_helper.dart';
import 'package:muscyou/data/local/model/user.dart';

/// Provider
final userRepositoryProvider = Provider((_) => UserRepository());

/// Repository
class UserRepository {
  static const _table = 'users';

  /// Returns ID of last inserted row
  Future<int> insertUser(User user) async {
    final db = await LocalDbHelper.instance.database;
    return await db.insert(_table, user.toMap());
  }

  Future<User?> authenticateUser(String username, String password) async {
    final db = await LocalDbHelper.instance.database;
    final maps = await db.query(
      _table,
      columns: ['id', 'username', 'password'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }
}
