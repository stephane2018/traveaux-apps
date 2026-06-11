/// Formatage des montants à la française : 15000 → « 15 000 ».
String formatNumber(num n) {
  final digits = n.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// « 15 000 F CFA »
String formatFcfa(num n) => '${formatNumber(n)} F CFA';

const _joursFr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const _joursLongFr = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];
const _moisFr = [
  'jan',
  'fév',
  'mar',
  'avr',
  'mai',
  'juin',
  'juil',
  'août',
  'sep',
  'oct',
  'nov',
  'déc',
];
const _moisLongFr = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Abréviation du jour de la semaine (« Lun »).
String weekdayShortFr(DateTime d) => _joursFr[d.weekday - 1];

/// Mois abrégé (« juin »).
String monthShortFr(DateTime d) => _moisFr[d.month - 1];

/// Date longue en français : « Lundi 16 juin ».
String formatDateLongFr(DateTime d) =>
    '${_joursLongFr[d.weekday - 1]} ${d.day} ${_moisLongFr[d.month - 1]}';
