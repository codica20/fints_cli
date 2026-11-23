import 'dart:convert';

import 'package:fints_cli/output/table_data_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

void main() {
  test("first test", () {
    expect("hello", "hello");
  });
  test("test1", () {
    final TableData table = TableData(
      headers: [
        TableColumn("first"),
        TableColumn("Second"),
      ],
      rows: [
        TableRow([
          TableStringValue("a string"),
          TableNumValue(3.0),
        ]),
      ],
    );

    expect(table.rows.length, 1);
    final jsoned = table.toJson();
    expect(
      jsoned.runtimeType.toString(),
      "List<Map<String, dynamic>>",
    );
    expect(
      jsonEncode(jsoned),
      "[{\"first\":\"a string\",\"Second\":3.0}]",
    );
  });

  test("Date is printed 1.11.2026", () async {
    await initializeDateFormatting("de");
    final formatted = TableDateValue(DateTime(2040, 1, 3))
        .toJson();
    expect(formatted, "3.1.2040");
  });
}
