import 'package:config/config.dart';
import 'package:fints_cli/config/ft_config.dart';
import 'package:fints_cli/config/ft_config_parser.dart';
import 'package:fints_cli/engine/fints_client.dart';
import 'package:fints_cli/engine/ft_no_such_account_exception.dart';
import 'package:logging/logging.dart';

// Please, set it to the same value as in pubspec.yaml
const String version = '0.1.0';

void printUsage() {
  print('Aufruf: fints_cli <optionen> ');
  print(parseArgs([]).usage);
}

void main(List<String> arguments) async {
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.message}',
    );
  });
  final logger = Logger("main");

  try {
    final Configuration<FtOption<dynamic>> config =
        parseArgs(arguments);

    // Process the parsed arguments.
    if (config.optionalValue(FtOption.help) ?? false) {
      printUsage();
      return;
    }
    if (config.value(FtOption.version)) {
      print('fints_cli version: $version');
      return;
    }

    final ftConfig = FtConfig(arguments);
    Logger.root.level = ftConfig.logLevel;

    logger.log(.FINER, "running fints ...");
    await MyFinTs(ftConfig).run();
    logger.log(.FINER, "done");
  } on UsageException catch (e) {
    // Print usage information if an invalid argument was provided.

    printUsage();
    print('');
    print("FEHLER: ${e.message}");
  } on FtNoSuchAccountException catch (e) {
    print(
      "Leider kein passendes Konto für ${e.account} gefunden.",
    );
    final accounts = e.accounts;
    if (accounts != null) {
      print("Folgende Konten sind vorhanden:");
      for (final a in accounts) {
        print("${a.accountNumber} (${a.productName})");
      }
    }
  } catch (e, s) {
    logger.severe(
      "In main: $e (${e.runtimeType})!!!",
      e,
      s,
    );
  }
}
