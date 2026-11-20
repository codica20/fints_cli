import 'dart:async';

import 'package:cli_menu/cli_menu.dart';
import 'package:fints/fints.dart';
import 'package:fints_cli/config/ft_config.dart';
import 'package:logging/logging.dart';

class MyFinTs(final FtConfig config) {
  final Logger l = Logger("MyFinTs");
  void _info(String msg) {
    l.info(msg);
  }

  void _fine(String msg) {
    l.fine(msg);
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
        logger: (MessageDirection direction, message) {
          _fine(" ${direction.name} - Msg: $message");
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
      final account = Menu(accounts).choose().value;
      final balance = await client.getBalance(account);
      _info("balance: $balance");
      _info(
        "balance-details: ${balance.booked} ${balance.pending} ${balance.bookedAsOf} ${balance.available} ${balance.creditLine} ${balance.overdraft} ${balance.used} ${balance.bookedAsOfTime} ${balance.productName}",
      );

      const daysMenu = [1, 5, 10, 30, 90, 180];
      final int days =
          daysMenu[Menu(
            daysMenu.map((count) => "Letzte $count Tage"),
          ).choose().index];
      final transactions = await client.getTransactions(
        account,
        from: DateTime.now().subtract(Duration(days: days)),
      );
      _info("transactions: $transactions");
      for (final Transaction transaction in transactions) {
        _info(
          "${transaction.bookingDate} ${transaction.amount} ${transaction.bookingText} ${transaction.counterpartyName} ${transaction.counterpartyIban} ${transaction.originalAmount} ${transaction.isPending ? "Pending" : "-"} ${transaction.purpose} ${transaction.purposeCodes} ${transaction.valueDate}",
        );
      }
      final depot = accounts
          .where(
            (a) => a.category == AccountCategory.securities,
          )
          .firstOrNull;
      if (depot != null) {
        _info("Checking depot: $depot");
        final HoldingsStatement(:holdings, :total) =
            await client.getHoldings(depot);
        _info("depot total: $total - holdings: $holdings");
        for (final holding in holdings) {
          _info(
            "${holding.name} ${holding.marketValue} ${holding.marketValue} ${holding.acquisitionPrice} ${holding.quantity} ${holding.wkn} ${holding.isin} ${holding.priceDate} ${holding.priceTime} ${holding.priceKind}",
          );
        }
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
        _fine(
          "Client state at end of run: ${client.state}",
        );
        // savedState = client.state; // persist after close, whose answers may change it
      }
    }
  }

  FutureOr<TanMethod> showMethodPicker(
    List<TanMethod> methods,
  ) async {
    final tanMethod = config.tanMethod;
    if (tanMethod != null) {
      final RegExp re = RegExp(tanMethod);
      return methods.firstWhere((m) => re.hasMatch(m.name));
    }
    _fine("method picker: $methods");
    final userinput = Menu(methods).choose();
    print("");
    _fine("Picked: $userinput");
    final result = userinput.value;
    return result;
  }

  FutureOr<TanMedium> showMediumPicker(
    List<TanMedium> media,
  ) async {
    _fine("medium picker: $media");
    for (final medium in media) {
      _fine(
        "$medium - ${medium.name} ${medium.isActive} ${medium.validFrom} ${medium.securityFunction}  ${medium.cardSequenceNumber} ${medium.status} ${medium.mobileNumber} ${medium.lastUsed} ${medium.cardNumber}",
      );
    }
    final mediumNames = media.map((m) => m.name);
    final userinput = Menu(mediumNames).choose();
    _info(
      "Picked: ${userinput.value} - ${userinput.index} - ${media[userinput.index]}",
    );
    return media[userinput.index];
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
