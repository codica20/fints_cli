import 'package:fints/fints.dart';

class FtNoSuchAccountException([
  final String? account,
  final List<Account>? accounts,
]) implements Exception {
  @override
  String toString() => "No such account: $account";
}
