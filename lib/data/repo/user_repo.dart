import 'package:scure_pass/data/db/sqlite.dart';
import 'package:scure_pass/data/services/hash_service.dart';
import 'package:scure_pass/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserRepo {
    final DBHelper _dbHelper = DBHelper.instance;
  //! ---- Sign in
  Future<User?> login({
    required String username,
    required String password,
  }) async {
    
    final Database db = await _dbHelper.database;

    final hashedPassword = HashService.hashPassword(password);
    
    final userRow = await db.rawQuery(
      "SELECT * FROM users WHERE username = ? AND password = ?",
      [username, hashedPassword],
    );

    if (userRow.isNotEmpty) {
      return User.fromMap(userRow.first);
    } else {
      return null;
    }
  }

  //! ---- Sign Up
  Future<User?> signup(User user) async {
    
    final Database db = await _dbHelper.database;  

    // Ensure username doesn"t exist
    final userRow = await db.rawQuery(
      "SELECT * FROM users WHERE username = ?",
      [user.username],
    );
    
    // username is taken
    if (userRow.isNotEmpty) return null;

    // hashing the password
    final hashedPassword = HashService.hashPassword(user.password);

    // User with hashing password
    final newUser = User(
      name: user.name,
      username: user.username,
      password: hashedPassword,
      createdAt: user.createdAt,
    );
    // add new user
    await db.insert('users', newUser.toMap());
    return newUser;
  }

  // Update User (name, username, password)
  Future<int> updateUser(
    int id,
    String name,
    String username,
    String password,
  ) async {
    final Database db = await _dbHelper.database;  
    return db.update(
      'users',
      {'name': name, 'username': username, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get User by ID
  Future<User?> getUserById(int id) async {
    final Database db = await _dbHelper.database;  
    List<Map<String, Object?>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

   /// Delete User
  Future<int> deleteUser(int id) async {
    final Database db = await _dbHelper.database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}