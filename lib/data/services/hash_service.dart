import "dart:convert";
import "package:crypto/crypto.dart";

class HashService {
//! ---- Hashing Passwords
static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  static bool isCorrect(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }
}