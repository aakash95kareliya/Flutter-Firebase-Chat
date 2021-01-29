import 'package:encrypt/encrypt.dart' as encryption;
import 'package:encrypt/encrypt.dart';

class CustomAESEncryption {
  Encrypter encrypter;
  var iv;

  CustomAESEncryption() {
    final key = encryption.Key.fromUtf8("dRgUkXp2s5v8y/B?");
    iv = encryption.IV.fromUtf8("WHFCYnRBOUU4NEk9");
    encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: "PKCS7"));
  }

  String encrypt(String input) {
    return encrypter.encrypt(input, iv: iv).base64;
  }

  String decrypt(encryption.Encrypted data) {
    return encrypter.decrypt(data, iv: iv);
  }
}
