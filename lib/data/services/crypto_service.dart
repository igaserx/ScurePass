

  import "package:encrypt/encrypt.dart";

class CryptoService {
  
  // خلي الـ Key والـ IV ثابتين
  static final Key _key = Key.fromUtf8('12345678901234567890123456789012');
  static final IV _iv = IV.fromUtf8('1234567890123456');

  /// Encrypt plain text
  static String encrypt(String pass) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(pass, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt encrypted text
  static String decrypt(String encryptedPass) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.decrypt64(encryptedPass, iv: _iv);
  }
}