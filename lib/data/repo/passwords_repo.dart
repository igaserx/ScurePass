import 'package:scure_pass/data/db/sqlite.dart';
import 'package:scure_pass/data/services/crypto_service.dart';
import 'package:scure_pass/data/services/hash_service.dart';
import 'package:scure_pass/models/password_model.dart';
import 'package:sqflite/sqflite.dart';

class PasswordsRepo{
  final DBHelper _dbHelper = DBHelper.instance;
//! ---- Add Password record
  Future<int> addPassword(PasswordModel password) async {
    final Database db = await _dbHelper.database;
    
    
    return db.insert('passwords', password.toMap());
  }

  //! ---- Get all passwords
  Future<List<PasswordModel>> getPasswords(int userId) async {
    final Database db = await _dbHelper.database;
    List<Map<String, Object?>> result = await db.query(
      'passwords',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => PasswordModel.fromMap(e)).toList();
  }

  //! Delete Password 
  Future<int> deletePassword(int passwordId) async {
    final Database db = await _dbHelper.database;
    return db.delete('passwords', where: 'id = ?', whereArgs: [passwordId]);
  }


  // Update Password (takes PasswordModel object)
  Future<int> updatePassword(PasswordModel password) async {
    final Database db = await _dbHelper.database;
    final hashedpassword = HashService.hashPassword(password.encryptedPassword);
    return db.update(
      'passwords',
      {
        'title': password.title,
        'username': password.username,
        'password': hashedpassword,
        'url': password.url,
      },
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

   //! ---- Get Password by ID
  Future<PasswordModel?> getPasswordById(int id) async {
    final Database db = await _dbHelper.database;
    
    final result = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return PasswordModel.fromMap(result.first);
    }
    return null;
  }

  //! ---- Encrypt Password
  String encryptPassword(String plainPassword) {
    return CryptoService.encrypt(plainPassword);
  }

  //! ---- Decrypt Password
  String decryptPassword(String encryptedPassword) {
    return CryptoService.decrypt(encryptedPassword);
  }

}