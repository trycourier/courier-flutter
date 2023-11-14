import 'dart:math';

String getUUID() {

  final Random random = Random();

  final List<int> bytes = List.generate(16, (i) => random.nextInt(256));

  // Set the version (4) and variant (10) bits
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  final List<String> hexChars = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).toList();

  return '${hexChars.sublist(0, 4).join('')}-${hexChars.sublist(4, 6).join('')}-${hexChars.sublist(6, 8).join('')}-${hexChars.sublist(8, 10).join('')}-${hexChars.sublist(10).join('')}';

}