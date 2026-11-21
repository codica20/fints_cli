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
  final String? tanMethod;
  /// an RegEx matching the tan medium
  final String? tanMedium;
  /// an RegEx matching the account name or the account number
  final String? account;

  static final logger = Logger("FtConfig");
  new(List<String> args)
    : bankingUrl = _loadString(args, .bankingUrl),
      bankCode = _loadString(args, .bankCode),
      userId = _loadString(args, .userId),
      pin = _loadString(args, .password),
      productId = _loadString(args, .productID),
      productVersion = _loadString(args, .productVersion),
      tanMethod = _loadOptionalString(args, .tanMethod),
      tanMedium = _loadOptionalString(args, .tanMedium),
      account = _loadOptionalString(args, .account);

  /// throws an Exception if value for option is not defined.
  static String _loadString(
    List<String> args,
    FtOption<String> option,
  ) {
    final value = _getConfig(args).value(option);
    return value;
  }

  /// loads an optional string value or null
  static String? _loadOptionalString(
    List<String> args,
    FtOption<String> option,
  ) {
    final value = _getConfig(args).optionalValue(option);
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
