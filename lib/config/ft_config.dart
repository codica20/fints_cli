import 'package:config/config.dart';
import 'package:fints_cli/config/ft_config_parser.dart';
import 'package:logging/logging.dart';

class FtConfig {
  final String bankingUrl;
  final String bankCode;
  final String userId;
  final String pin;
  final String productId;
  final String productVersion;

  static final logger = Logger("FtConfig");
  new(List<String> args)
    : bankingUrl = _load(args, .bankingUrl),
      bankCode = _load(args, .bankCode),
      userId = _load(args, .userId),
      pin = _load(args, .password),
      productId = _load(args, .productID),
      productVersion = _load(args, .productVersion);

  // throws an Exception if env var for key is not defined.
  static String _load(
    List<String> args,
    FtOption<String> option,
  ) {
    final value = _getConfig(args).value(option);
    return value;
  }

  /// Do NOT use this variable! Use _dotenv instead!
  static Configuration<FtOption<dynamic>>? _parsedConfig;

  static Configuration<FtOption<dynamic>> _getConfig(
    List<String> args,
  ) {
    _parsedConfig ??= parseArgs(args);
    return _parsedConfig!;
  }
}
