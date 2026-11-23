/// Format angka ke Rupiah: 1027573 -> "Rp1.027.573".
String rupiah(int value, {bool withPrefix = true}) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${negative ? '−' : ''}${withPrefix ? 'Rp' : ''}$buf';
}

/// Format ringkas: 75000 -> "Rp75rb", 3490000 -> "Rp3,5 jt".
String rupiahShort(int value) {
  if (value >= 1000000) {
    final jt = value / 1000000;
    final s = jt
        .toStringAsFixed(jt.truncateToDouble() == jt ? 0 : 1)
        .replaceAll('.', ',');
    return 'Rp$s jt';
  }
  if (value >= 1000) return 'Rp${value ~/ 1000}rb';
  return 'Rp$value';
}

const namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// "Sab, 21 Nov"
String tanggalPendek(DateTime d) =>
    '${namaHari[d.weekday - 1]}, ${d.day} ${namaBulan[d.month - 1].substring(0, 3)}';

/// "19.00"
String jam(int h) => '${h.toString().padLeft(2, '0')}.00';

/// "09.05"
String jamMenit(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';
