import 'package:config/config.dart';
import 'package:fints/fints.dart';

const _verbosityGroup = MutuallyExclusive(
  "Umfang der Ausgabe",
  mode: .allowDefaults,
);

enum FtOption<V> implements OptionDefinition<V> {
  help(
    _FtFlagOption(
      argName: "help",
      argAbbrev: "h",
      defaultsTo: false,
      helpText: "Zeigt Hilfe an",
    ),
  ),

  quiet(
    _FtFlagOption(
      argName: "quiet",
      defaultsTo: false,
      helpText: "Begrenzt Ausgabe auf Minimum.",
      group: _verbosityGroup,
    ),
  ),
  verbose(
    _FtFlagOption(
      argName: "verbose",
      argAbbrev: "v",
      defaultsTo: false,
      helpText: "Zeigt mehr Infos",
      group: _verbosityGroup,
    ),
  ),
  debug(
    _FtFlagOption(
      argName: "debug",
      defaultsTo: false,
      helpText:
          "Erleichtert Debugging durch viele Ausgaben",
      group: _verbosityGroup,
    ),
  ),

  version(
    _FtFlagOption(
      argName: "version",
      defaultsTo: false,
      helpText: "Zeigt Version an",
    ),
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
  tanMethod(
    _FtStringOption(
      argName: "tan_method",
      mandatory: false,
      helpText: "Tan-Methode, z.B. \"BestSign\"",
    ),
  ),
  tanMedium(
    _FtStringOption(
      argName: "tan_medium",
      mandatory: false,
      helpText: "Tan-Medium, z.B. \"MySmartPhone\"",
    ),
  ),
  account(
    _FtStringOption(
      argName: "account",
      argAbbrev: "a",
      mandatory: false,
      helpText: "Konto",
    ),
  ),
  lastDays(
    _FtIntOption(
      argName: "last_days",
      helpText: "Wieviel Tage zurück sollen Transaktionen abgeholt werden?",
    ),
  ),
  transactionFormat(
    _FtEnumOption<TransactionFormat>(
      argName: "transaction_format",
      enumParser: EnumParser(TransactionFormat.values),
      helpText: "Welches Format soll vom Server angefordert werden?",
      defaultsTo: .auto,
    ),
  ),
  get(
    _FtEnumOption<GetTarget>(
      argName: "get",
      enumParser: EnumParser(GetTarget.values),
      helpText: "Welche Liste soll abgeholt werden?",
      defaultsTo: .transactions
    ),
  )
  // configFile(
  //   FileOption(
  //     argName: "config_file",
  //     helpText: "Pfad zu einem Konfigurationsdatei (Standard: config.yaml)",
  //     // defaultsTo does not work here, because File() is not a const constructor
  //   ),
  //)
  ;

  const FtOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum GetTarget {
  accounts,
  balance,
  transactions,
  holdings,
  tanMedia,
  tanMethods,
}

/// parses cli args
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
    super.argAbbrev,
  }) : super(
         envName: envName ?? "ft_$argName",
         configKey: "/$argName",
       );
}

class _FtIntOption extends IntOption {
  const new({
    required String super.argName,
    String? envName,
    // ignore: unused_element_parameter
    super.mandatory = false,
    // ignore: unused_element_parameter
    super.argAliases,
    super.helpText,
    // ignore: unused_element_parameter
    super.argAbbrev,
  }) : super(
         envName: envName ?? "ft_$argName",
         configKey: "/$argName",
       );
}

class _FtFlagOption extends FlagOption {
  const new({
    required String super.argName,
    String? envName,
    // ignore: unused_element_parameter
    super.mandatory = false,
    // ignore: unused_element_parameter
    super.argAliases,
    super.helpText,
    // ignore: unused_element_parameter
    super.argAbbrev,
    super.defaultsTo,
    super.group,
  }) : super(
         envName: envName ?? "ft_$argName",
         configKey: "/$argName",
       );
}

class _FtEnumOption<E extends Enum> extends EnumOption<E> {
  const new({
    required String super.argName,
    required super.enumParser,
    String? envName,
    // ignore: unused_element_parameter
    super.mandatory = false,
    // ignore: unused_element_parameter
    super.argAliases,
    super.helpText,
    // ignore: unused_element_parameter
    super.argAbbrev,
    super.defaultsTo,
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
