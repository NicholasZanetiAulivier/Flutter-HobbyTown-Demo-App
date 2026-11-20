import 'package:intl/intl.dart';

final NUMBER_FORMAT = NumberFormat.currency(
  locale: "id",
  name: "Rp.",
  decimalDigits: 0,
);

String intToRupiah(int price) {
  return NUMBER_FORMAT.format(price);
}

String truncateStringDots(String string, int length) {
  if (string.length > length) {
    return "${string.substring(0, length - 1)}...";
  } else {
    return string;
  }
}

String shortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
