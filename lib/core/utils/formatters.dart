import 'package:intl/intl.dart';

class Formatters {
  // Transforma double (1500.5) em String ("R$ 1.500,50")
  static String formatMoney(double value) {
    final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return format.format(value);
  }
}