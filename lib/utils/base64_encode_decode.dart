import 'dart:convert';

class Base64EncodeDecode {
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  encode(String data) {
    return stringToBase64.encode(data);
  }

  decode(String encodedData) {
    return stringToBase64.decode(encodedData);
  }
}