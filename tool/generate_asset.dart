import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  Directory('assets/sounds').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  // 44-byte standard PCM 16-bit mono 44100Hz WAV header + 75ms crisp high-pitched Valorant UI click
  const sampleRate = 44100;
  const numSamples = 3308; // ~0.075 seconds (keskin ve tiz)
  final byteData = ByteData(44 + numSamples * 2);

  // "RIFF"
  byteData.setUint8(0, 0x52);
  byteData.setUint8(1, 0x49);
  byteData.setUint8(2, 0x46);
  byteData.setUint8(3, 0x46);
  byteData.setUint32(4, 36 + numSamples * 2, Endian.little);
  // "WAVE"
  byteData.setUint8(8, 0x57);
  byteData.setUint8(9, 0x41);
  byteData.setUint8(10, 0x56);
  byteData.setUint8(11, 0x45);
  // "fmt "
  byteData.setUint8(12, 0x66);
  byteData.setUint8(13, 0x6D);
  byteData.setUint8(14, 0x74);
  byteData.setUint8(15, 0x20);
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
  byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = mono)
  byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
  byteData.setUint16(32, 2, Endian.little); // BlockAlign
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample
  // "data"
  byteData.setUint8(36, 0x64);
  byteData.setUint8(37, 0x61);
  byteData.setUint8(38, 0x74);
  byteData.setUint8(39, 0x61);
  byteData.setUint32(40, numSamples * 2, Endian.little);

  // Orijinal Valorant Brimstone cihazına uygun tiz, keskin dijital klik/bip (2350 Hz -> 3100 Hz)
  double phase = 0.0;
  for (int i = 0; i < numSamples; i++) {
    final progress = i / numSamples;
    final freq = 2350.0 + progress * 750.0;
    phase += 2.0 * math.pi * freq / sampleRate;

    final decay = math.pow(1.0 - progress, 1.8);
    // Keskin dijital tını için temel sinüs + hafif kare harmonik karışımı
    final squareSign = math.sin(phase) >= 0 ? 1.0 : -1.0;
    final wave = 0.55 * math.sin(phase) + 0.45 * squareSign;
    final sample = (decay * 28000.0 * wave).round().clamp(-32767, 32767);
    byteData.setInt16(44 + i * 2, sample, Endian.little);
  }

  File('assets/sounds/transition.wav').writeAsBytesSync(byteData.buffer.asUint8List());
  stdout.writeln('transition.wav created successfully.');
}
