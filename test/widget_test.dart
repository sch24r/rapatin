import 'package:flutter_test/flutter_test.dart';

import 'package:rapatin/core/format.dart';

void main() {
  test('format rupiah sesuai rincian RPT-0427', () {
    expect(rupiah(1027573), 'Rp1.027.573');
    expect(rupiah(150000 + 875000 + 3000 - 427), 'Rp1.027.573');
    expect(rupiahShort(75000), 'Rp75rb');
    expect(rupiahShort(3490000), 'Rp3,5 jt');
  });
}
