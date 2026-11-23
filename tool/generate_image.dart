import 'dart:io';
import 'dart:typed_data';

void main() {
  const width = 128;
  const height = 128;

  // Build raw uncompressed RGBA pixel data with filter byte 0 at start of each scanline
  final rawData = BytesBuilder();
  for (int y = 0; y < height; y++) {
    rawData.addByte(0); // filter: None
    for (int x = 0; x < width; x++) {
      // Create a nice tactical geometric pattern
      final dx = x - 64;
      final dy = y - 64;
      final dist2 = dx * dx + dy * dy;

      if (dist2 < 48 * 48 && dist2 > 44 * 44) {
        // Cyan outer ring
        rawData.add([0x00, 0xF5, 0xD4, 0xFF]);
      } else if (dist2 <= 44 * 44 && dist2 >= 40 * 40) {
        // Dark ring
        rawData.add([0x0F, 0x19, 0x23, 0xFF]);
      } else if (x >= 40 && x <= 88 && y >= 50 && y <= 60) {
        // Tactical chevron / bar
        rawData.add([0xFF, 0x46, 0x55, 0xFF]);
      } else if ((x - 64).abs() + (y - 70).abs() < 24) {
        // Central tactical diamond (Brimstone insignia)
        rawData.add([0x00, 0xF5, 0xD4, 0xDD]);
      } else if (x > 10 && x < 118 && y > 10 && y < 118) {
        // Background dark slate
        rawData.add([0x14, 0x1E, 0x26, 0xFF]);
      } else {
        // Outer dark
        rawData.add([0x0A, 0x0E, 0x13, 0xFF]);
      }
    }
  }

  final compressed = zlib.encode(rawData.toBytes());

  // Build PNG chunks
  final png = BytesBuilder();
  // PNG signature
  png.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR chunk
  final ihdr = ByteData(13);
  ihdr.setUint32(0, width);
  ihdr.setUint32(4, height);
  ihdr.setUint8(8, 8); // 8-bit depth
  ihdr.setUint8(9, 6); // color type 6: RGBA
  ihdr.setUint8(10, 0); // compression
  ihdr.setUint8(11, 0); // filter
  ihdr.setUint8(12, 0); // interlace
  writeChunk(png, 'IHDR', ihdr.buffer.asUint8List());

  // IDAT chunk
  writeChunk(png, 'IDAT', Uint8List.fromList(compressed));

  // IEND chunk
  writeChunk(png, 'IEND', Uint8List(0));

  File('assets/images/brimstone.png').writeAsBytesSync(png.toBytes());
  stdout.writeln('assets/images/brimstone.png created successfully!');
}

void writeChunk(BytesBuilder builder, String type, Uint8List data) {
  final length = data.length;
  final lengthBytes = ByteData(4)..setUint32(0, length);
  builder.add(lengthBytes.buffer.asUint8List());

  final typeBytes = Uint8List.fromList(type.codeUnits);
  builder.add(typeBytes);

  if (data.isNotEmpty) {
    builder.add(data);
  }

  // Calculate CRC32 over type + data
  final crcData = Uint8List(4 + data.length);
  crcData.setRange(0, 4, typeBytes);
  if (data.isNotEmpty) {
    crcData.setRange(4, 4 + data.length, data);
  }
  final crc = getCrc32(crcData);
  final crcBytes = ByteData(4)..setUint32(0, crc);
  builder.add(crcBytes.buffer.asUint8List());
}

int getCrc32(Uint8List bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (int k = 0; k < 8; k++) {
      if ((crc & 1) != 0) {
        crc = (crc >>> 1) ^ 0xEDB88320;
      } else {
        crc = crc >>> 1;
      }
    }
  }
  return (~crc) & 0xFFFFFFFF;
}
