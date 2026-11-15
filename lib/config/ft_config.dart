import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

class FtConfig {
  static const _bankingUrlKey = "FT_URL";
  static const _bankCodeKey = "FT_BLZ";
  static const _userIdKey = "FT_USER";
  static const _pinKey = "FT_PIN";
  static const _productIdKey = "FT_PRODUCT_ID";
  static const _productVersionKey = "FT_PRODUCT_VERSION";

  final String bankingUrl;
  final String bankCode;
  final String userId;
  final String pin;
  final String productId;
  final String productVersion;

  static final logger = Logger("FtConfig");
  new()
    : bankingUrl = _loadKey(_bankingUrlKey),
      bankCode = _loadKey(_bankCodeKey),
      userId = _loadKey(_userIdKey),
      pin = _loadKey(_pinKey),
      productId = _loadKey(_productIdKey),
      productVersion = _loadKey(_productVersionKey);

  // throws an Exception if env var for key is not defined.
  static String _loadKey(String envKey) {
    final value = _dotenv[envKey];
    switch (value) {
      case String():
        return value;
      case _:
        final msg = "Please, set environment var $envKey";
        logger.severe(msg);
        throw Exception(msg);
    }
  }

  static DotEnv get _dotenv {
    // TODO: use singleton pattern
    final env = DotEnv(includePlatformEnvironment: true)
      ..load();
    return env;
  }
}
