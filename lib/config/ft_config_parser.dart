import 'package:config/config.dart';

enum FtOption<V> implements OptionDefinition<V> {
  help(FlagOption(argName: "help", argAbbrev: "h")),
  verbose(
    FlagOption(
      argName: "verbose",
      argAbbrev: "v",
      defaultsTo: false,
    ),
  ),
  version(
    FlagOption(argName: "version", defaultsTo: false),
  ),
  bankingUrl(
    _FtStringOption(
      argName: "banking_url",
      argAliases: ["url"],
      helpText: "Die FinTS/HBCI-URL der Bank",
      mandatory: true,
    ),
  ),
  bankCode(
    _FtStringOption(
      argName: "blz",
      argAliases: ["bankleitzahl"],
      helpText: "Die Bankleitzahl der Bank (üblicherweise ab der 3. Stelle der IBAN)",
    ),
  ),
  userId(_FtStringOption(argName: "user")),
  password(
    _FtStringOption(
      argName: "pin",
      argAliases: ["password"],
      helpText:
          "Die FinTS/HBCI-PIN (üblicherweise ein Passwort)",
    ),
  ),

  productID(
    _FtStringOption(
      argName: "product_id",
      helpText:
          "Die Product-ID wird von der DK bereitgestellt.",
    ),
  ),
  productVersion(
    _FtStringOption(argName: "product_version"),
  ),

  configFile(
    FileOption(
      argName: "config_file",
      helpText: "Pfad zu einem Konfigurationsdatei (Standard: config.yaml)",
      // defaultsTo does not work here, because File() is not a const constructor
    ),
  );

  const FtOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

Configuration<FtOption<dynamic>> parseArgs(
  List<String> args,
) {
  return Configuration.resolve(
    options: FtOption.values,
    args: args,
    configBroker: _FtFileConfigBroker(),
  );
}

class _FtStringOption extends StringOption {
  const new({
    required String super.argName,
    String? envName,
    super.mandatory = true,
    super.argAliases,
    super.helpText,
  }) : super(
         envName: envName ?? "ft_$argName",
         configKey: "/$argName",
       );
}

class _FtFileConfigBroker implements ConfigurationBroker {
  ConfigurationSource? _configSource;

  @override
  String? valueOrNull(String key, Configuration cfg) {
    // By lazy-loading the config, the file path can depend on another option
    _configSource ??= ConfigurationParser.fromFile(
      //      cfg.optionalValue(FtOption.configFile)?.path ??
      "config.yaml",
    );
    final value = _configSource?.valueOrNull(key);
    return value is String ? value : null;
  }
}
