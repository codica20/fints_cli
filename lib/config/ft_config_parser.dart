import 'package:config/config.dart';

enum FtOption<V> implements OptionDefinition<V> {
  help(FlagOption(argName: "help", argAbbrev: "h")),
  verbose(FlagOption(argName: "verbose", argAbbrev: "v", defaultsTo: false)),
  version(FlagOption(argName: "version", defaultsTo: false));

  const FtOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

Configuration<FtOption<dynamic>> parseArgs(List<String> args) {
  return Configuration.resolve(
    options: FtOption.values,
    args: args, 
  );
}
