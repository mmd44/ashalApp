import 'package:intl/intl.dart';

String formatAmountWithCurrency(num amount) {
  if (amount == null) {
    return null;
  }

  NumberFormat formatter = NumberFormat.currency(
    decimalDigits: 2,
    name: 'LBP',
  );
  return formatter.format(amount);
}