import 'dart:async';

import 'package:fints/fints.dart';
import 'package:fints_cli/config/ft_config.dart';
import 'package:logging/logging.dart';

class MyFinTs(final FtConfig config) {
  final Logger l = Logger("MyFinTs");
  void _info(String msg) {
    l.info(msg);
  }

  /// rethrows the exception
  void _error(Exception e, StackTrace? s) {
    l.severe("Exception wurde ausgelöst.", e, s);
  }

  Future<void> run() async {
    final client = FinTs3Client(
      config: FinTsConfig(
        url: Uri.parse(config.bankingUrl),
        bankCode: config.bankCode,
        userId: config.userId,
        productId: config.productId,
        productVersion: config.productVersion,
      ),
      pin: config.pin,
      options: FinTsClientOptions(
        logger: (direction, message) {
          _info("Direction: $direction - Msg: $message");
        },
        state: null, //savedState, // from a previous session, or null
        tanMethodSelector: (methods) =>
            showMethodPicker(methods),
        tanMediumSelector: (media) =>
            showMediumPicker(media),
        onBankMessage: (message) =>
            showNotice(message.subject, message.text),
        onWarning: (warning) =>
            showNotice(warning.code, warning.text),
        tanCallback: (challenge) async {
          if (challenge.isDecoupled) {
            // Close once challenge.resolved completes; offer "approved" only if challenge.manualConfirmation.
            final confirmed = await showApprovalDialog(
              challenge,
            );
            return confirmed
                ? TanAnswer.approved
                : TanAnswer.cancelled;
          }
          // Show challenge.plainMessage, image or flickerCode; accept at most method.maxTanLength chars, digits only if
          // method.numericTan.
          final tan = await askUserForTan(challenge);
          return tan == null
              ? TanAnswer.cancelled
              : TanAnswer.tan(tan);
        },
      ),
    );

    try {
      final accounts = await client.getAccounts();
      final balance = await client.getBalance(
        accounts.first,
      );
      _info("balance: $balance");
      final transactions = await client.getTransactions(
        accounts.first,
        from: DateTime.now().subtract(
          const Duration(days: 90),
        ),
      );
      _info("transactions: $transactions");
      final depot = accounts
          .where(
            (a) => a.category == AccountCategory.securities,
          )
          .firstOrNull;
      if (depot != null) {
        final HoldingsStatement(:holdings, :total) =
            await client.getHoldings(depot);
        _info("depot total: $total - holdings: $holdings");
      }
    } on FinTsLoginDataChangedException catch (e, s) {
      _error(e, s);
      // Store e.userId, e.customerId or e.loginName and build a new client with them.
    } on FinTsLoginRefusedException catch (e) {
      // The bank's errors, or why the client stopped by itself. A FinTsPinException is a wrong or blocked PIN, or an
      // access the bank has locked for now (3931, 3938), which the user lifts as the bank's text tells.
      showNotice('Login refused', e.message);
      // Then ask for the PIN anew and call client.clearLoginRefusal(pin).
    } on FinTsTanException catch (e, s) {
      // A rejected or expired TAN, or one the TAN method rules out.
      _error(e, s);
    } on FinTsBankException catch (e, s) {
      // e.feedback holds all bank return codes.
      _info("Feedback codes: ${e.feedback}");
      _error(e, s);
    } finally {
      try {
        await client.close();
      } finally {
        _info(
          "Client state at end of run: ${client.state}",
        );
        // savedState = client.state; // persist after close, whose answers may change it
      }
    }
  }

  FutureOr<TanMethod> showMethodPicker(
    List<TanMethod> methods,
  ) async {
    _info("method picker: $methods");
    throw UnimplementedError();
  }

  FutureOr<TanMedium> showMediumPicker(
    List<TanMedium> media,
  ) async {
    _info("medium picker: $media");
    throw UnimplementedError();
  }

  void showNotice(String subject, String text) {
    _info("Subject: $subject Text: $text");
  }

  Future<bool> showApprovalDialog(
    TanChallenge challenge,
  ) async {
    _info("approval dialog: $challenge");
    throw UnimplementedError();
  }

  Future<String?> askUserForTan(
    TanChallenge challenge,
  ) async {
    _info("askUserForTan: $challenge");
    throw UnimplementedError();
  }
}
