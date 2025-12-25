import "dart:convert";
import "package:crypto/crypto.dart";
import "package:scure_pass/models/user_model.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class DBHelper {
  //! ---- Name
  final databaseName = "scure_pass.db";

  //! ---- Tables
  final String userTable = '''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''';
  final String passwordsTable = '''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        url TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''';

  //! ---- Init
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // User Table should execute first
        await db.execute(userTable);
        await db.execute(passwordsTable);
      },
    );
  }

  //! ---- Hashing Passwords
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //! ---- Sign in
  Future<bool> login(User user) async {
    final Database db = await initDB();

    final username = user.username;
    final hashedPassword = user.hashedPassword;

    final userRow = await db.rawQuery(
      "SELECT * FROM users WHERE username = ? AND password = ?",
      [username, hashedPassword],
    );

    if (userRow.isNotEmpty) {
      // Sign in success
      return true;
    } else {
      return false;
    }
  }

  //! ---- Sign Up
  Future<int> signup(User user) async {
    final Database db = await initDB();

    // Ensure username doesn"t exist
    final userRow = await db.rawQuery(
      "SELECT * FROM users WHERE username = ?",
      [user.username],
    );
    if (userRow.isNotEmpty) {
      return -1;
    }
    
    // add new user 
    return await db.insert('users', user.toMap());
  }
}
