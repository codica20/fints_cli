import 'package:config/config.dart';
import 'package:fints_cli/config/ft_config.dart';
import 'package:fints_cli/engine/fints_client.dart';
import 'package:logging/logging.dart';

// Please, set it to the same value as in pubspec.yaml
const String version = '0.0.2';

ConfigParser buildParser() {
  return ConfigParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ConfigParser argParser) {
  print('Usage: fints_cli <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.message}',
    );
  });
  final logger = Logger("main");
  final ConfigParser configParser = buildParser();
  try {
    final  results = configParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(configParser);
      return;
    }
    if (results.flag('version')) {
      print('fints_cli version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    Logger.root.level = verbose ? Level.ALL : .INFO;

    logger.log(.FINE, "running fints ...");
    await MyFinTs(FtConfig()).run();
    logger.log(.FINE, "done");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(configParser);
  } catch (e, s) {
    logger.severe("In main: $e !!!", e, s);
  }
}
