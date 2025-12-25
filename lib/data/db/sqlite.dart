import "dart:convert";
import "package:crypto/crypto.dart";
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
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
