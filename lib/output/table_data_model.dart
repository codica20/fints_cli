import 'package:intl/intl.dart';

class TableData {
  final List<TableColumn> headers;
  final List<TableRow> rows;

  new({
    List<TableColumn> headers = const [],
    List<TableRow> rows = const [],
  }) : headers = List.of(headers),
       rows = List.of(rows);
  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> res = [];
    for (final row in rows) {
      Map<String, dynamic> map = {};
      for (var i = 0; i < headers.length; i++) {
        final key = headers[i].name;
        final value = row.values[i].toJson();
        map[key] = value;
      }
      res.add(map);
    }
    return res;
  }
}

class const TableColumn(final String name);

class TableRow {
  List<TableValue> values;
  new([List<TableValue> values = const []])
    : values = List.of(values);
}

sealed class TableValue {
  TableValueType get type;
  dynamic toJson();
}

class TableStringValue(final String? value)
    extends TableValue {
  @override
  TableValueType get type => .string;

  @override
  toJson() {
    return value;
  }
}

class TableNumValue(final num? value) extends TableValue {
  @override
  TableValueType get type => .number;

  @override
  toJson() {
    return value;
  }
}

class TableDateValue(final DateTime? value)
    extends TableValue {
  @override
  TableValueType get type => .date;

  @override
  toJson() {
    final date = value;
    return date != null
        ? DateFormat("d.M.y").format(date)
        : null;
  }
}

enum TableValueType { number, string, date }
