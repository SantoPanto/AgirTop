import 'dart:io';
import 'dart:typed_data';

void main() {
  Directory('assets/sounds').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  // 44-byte standard PCM 16-bit mono 44100Hz WAV header + short sine beep
  const sampleRate = 44100;
  const numSamples = 2205; // 0.05 seconds
  final byteData = ByteData(44 + numSamples * 2);

  // "RIFF"
  byteData.setUint8(0, 0x52); byteData.setUint8(1, 0x49); byteData.setUint8(2, 0x46); byteData.setUint8(3, 0x46);
  byteData.setUint32(4, 36 + numSamples * 2, Endian.little);
  // "WAVE"
  byteData.setUint8(8, 0x57); byteData.setUint8(9, 0x41); byteData.setUint8(10, 0x56); byteData.setUint8(11, 0x45);
  // "fmt "
  byteData.setUint8(12, 0x66); byteData.setUint8(13, 0x6D); byteData.setUint8(14, 0x74); byteData.setUint8(15, 0x20);
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = mono)
  byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
  byteData.setUint16(32, 2, Endian.little);  // BlockAlign
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample
  // "data"
  byteData.setUint8(36, 0x64); byteData.setUint8(37, 0x61); byteData.setUint8(38, 0x74); byteData.setUint8(39, 0x61);
  byteData.setUint32(40, numSamples * 2, Endian.little);

  // Generate a pleasant tactile click / blip sound
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final decay = (1.0 - (i / numSamples));
    final sample = (decay * 16000 * (i % 20 < 10 ? 1 : -1)).toInt();
    byteData.setInt16(44 + i * 2, sample, Endian.little);
  }

  File('assets/sounds/transition.wav').writeAsBytesSync(byteData.buffer.asUint8List());
  print('transition.wav created successfully.');
}
