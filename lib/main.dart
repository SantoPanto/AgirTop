import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobil cihazlarda (Android & iOS) tam ekran (Immersive Mode) ve dikey yönlendirme.
  // PC / Masaüstü ortamında pencere esnekliğini bozmamak için yalnızca mobilde kısıtlanır.
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const AgirTopApp());
}

/// Masaüstü / PC platform kontrolü
bool get isDesktopPlatform {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

// ============================================================================
// VALORANT TEMA RENK PALETİ VE SABİTLERİ
// ============================================================================
class ValorantTheme {
  static const Color darkBg = Color(0xFF0F1923); // Valorant gece mavisi/koyu arka plan
  static const Color surfaceDark = Color(0xFF1B2228); // Taktiksel panel rengi
  static const Color surfaceBezel = Color(0xFF141A20); // Cihaz kalın çerçeve rengi
  static const Color valorantRed = Color(0xFFFF4655); // İkonik Valorant kırmızısı
  static const Color cyanNeon = Color(0xFF00F5D4); // Brimstone telsiz / camgöbeği neon
  static const Color alertOrange = Color(0xFFFF5E00); // 2. Ekran uyarı/bağlantı rengi
  static const Color yellowAccent = Color(0xFFFFCE22); // Taktiksel sarı üçgen detayı
  static const Color textWhite = Color(0xFFECE8E1); // Taktiksel kirli beyaz yazı
  static const Color textMuted = Color(0xFF768079); // Yardımcı gri teknik yazı
}

// ============================================================================
// ANA UYGULAMA WIDGET'I (MOBİL VE PC DESTEKLİ)
// ============================================================================
class AgirTopApp extends StatelessWidget {
  const AgirTopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgirTop',
      debugShowCheckedModeBanner: false,
      // Hem fare hem dokunmatik girişleri destekleyen kaydırma davranışı
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: ValorantTheme.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: ValorantTheme.valorantRed,
          secondary: ValorantTheme.cyanNeon,
          surface: ValorantTheme.surfaceDark,
        ),
      ),
      home: const AnaMenuEkrani(),
    );
  }
}

// ============================================================================
// VALORANT KESİK KÖŞELİ (CHAMFERED/BEVELED) CUSTOM CLIPPER VE BORDER PAINTER
// ============================================================================
class ChamferClipper extends CustomClipper<Path> {
  final double cutSize;
  final bool cutTopLeft;
  final bool cutTopRight;
  final bool cutBottomRight;
  final bool cutBottomLeft;

  const ChamferClipper({
    this.cutSize = 14.0,
    this.cutTopLeft = true,
    this.cutTopRight = true,
    this.cutBottomRight = true,
    this.cutBottomLeft = true,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final c = cutSize;

    // Başlangıç: Sol üst
    if (cutTopLeft) {
      path.moveTo(0, c);
      path.lineTo(c, 0);
    } else {
      path.moveTo(0, 0);
    }

    // Sağ üst
    if (cutTopRight) {
      path.lineTo(w - c, 0);
      path.lineTo(w, c);
    } else {
      path.lineTo(w, 0);
    }

    // Sağ alt
    if (cutBottomRight) {
      path.lineTo(w, h - c);
      path.lineTo(w - c, h);
    } else {
      path.lineTo(w, h);
    }

    // Sol alt
    if (cutBottomLeft) {
      path.lineTo(c, h);
      path.lineTo(0, h - c);
    } else {
      path.lineTo(0, h);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ChamferClipper oldClipper) {
    return oldClipper.cutSize != cutSize ||
        oldClipper.cutTopLeft != cutTopLeft ||
        oldClipper.cutTopRight != cutTopRight ||
        oldClipper.cutBottomRight != cutBottomRight ||
        oldClipper.cutBottomLeft != cutBottomLeft;
  }
}

/// Kesik köşeli kenarlık (border) çizmek için özel CustomPainter
class ChamferBorderPainter extends CustomPainter {
  final double cutSize;
  final Color borderColor;
  final double borderWidth;

  ChamferBorderPainter({
    this.cutSize = 14.0,
    required this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final clipper = ChamferClipper(cutSize: cutSize);
    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChamferBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cutSize != cutSize;
  }
}

// ============================================================================
// VALORANT TARZI BUTON BİLEŞENİ (MOBİL DOKUNMA + PC FARE HOVER DESTEKLİ)
// ============================================================================
class ValorantMenuButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool isPrimary;
  final String subLabel;

  const ValorantMenuButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isPrimary = false,
    this.subLabel = 'TACTICAL PROTOCOL',
  });

  @override
  State<ValorantMenuButton> createState() => _ValorantMenuButtonState();
}

class _ValorantMenuButtonState extends State<ValorantMenuButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double cut = 16.0;
    final primaryColor = widget.isPrimary ? ValorantTheme.valorantRed : ValorantTheme.textWhite;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 280,
            height: 64,
            child: CustomPaint(
              painter: ChamferBorderPainter(
                cutSize: cut,
                borderColor: widget.isPrimary
                    ? ValorantTheme.valorantRed
                    : (_isHovered ? Colors.white : Colors.white.withValues(alpha: 0.25)),
                borderWidth: widget.isPrimary ? (_isHovered ? 2.5 : 2.0) : (_isHovered ? 2.0 : 1.2),
              ),
              child: ClipPath(
                clipper: const ChamferClipper(cutSize: cut),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: widget.isPrimary
                      ? ValorantTheme.valorantRed.withValues(alpha: _isHovered ? 0.22 : 0.12)
                      : ValorantTheme.surfaceDark.withValues(alpha: _isHovered ? 0.95 : 0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Sol taktiksel kare işaretçi
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _isHovered ? 8 : 6,
                        height: 24,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 14),
                      // Başlık ve alt başlık
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title.toUpperCase(),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subLabel,
                              style: TextStyle(
                                color: _isHovered
                                    ? ValorantTheme.textWhite.withValues(alpha: 0.9)
                                    : ValorantTheme.textMuted.withValues(alpha: 0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sağ ok ikonu
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 150),
                        offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                        child: Icon(
                          Icons.chevron_right,
                          color: primaryColor.withValues(alpha: _isHovered ? 1.0 : 0.8),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. ROUTE: ANA MENÜ EKRANI (MOBİL VE PC DESTEKLİ)
// ============================================================================
class AnaMenuEkrani extends StatelessWidget {
  const AnaMenuEkrani({super.key});

  void _showInactiveSnackBar(BuildContext context) {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        content: Center(
          child: SizedBox(
            width: 320,
            child: CustomPaint(
              painter: ChamferBorderPainter(
                cutSize: 10,
                borderColor: ValorantTheme.valorantRed,
                borderWidth: 1.5,
              ),
              child: ClipPath(
                clipper: const ChamferClipper(cutSize: 10),
                child: Container(
                  color: const Color(0xFF12171E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, color: ValorantTheme.valorantRed, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Şu anlık aktif değil',
                          style: TextStyle(
                            color: ValorantTheme.textWhite,
                            fontSize: 14,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Text(
                        '// KİLİTLİ',
                        style: TextStyle(
                          color: ValorantTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: ValorantTheme.darkBg,
      body: Stack(
        children: [
          // Arka plan taktiksel grid ve çizgiler
          Positioned.fill(
            child: CustomPaint(
              painter: TacticalGridBackgroundPainter(),
            ),
          ),

          // Sol üst köşe HUD detayı
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROTOCOL // RADIANITE',
                  style: TextStyle(
                    color: ValorantTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 8, height: 8, color: ValorantTheme.valorantRed),
                    const SizedBox(width: 6),
                    Text(
                      isDesktopPlatform ? 'BRM // PC CLIENT' : 'BRM // MOBILE 084',
                      style: const TextStyle(
                        color: ValorantTheme.textWhite,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sağ üst köşe versiyon bilgisi
          Positioned(
            top: 24 + MediaQuery.paddingOf(context).top,
            right: 24,
            child: const Text(
              'AgırTop Ver0.1',
              style: TextStyle(
                color: ValorantTheme.textMuted,
                fontSize: 10,
                letterSpacing: 2.0,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Merkez İçerik: Başlık ve Butonlar
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Valorant V logosu ve Başlık
                  Container(
                    width: 50,
                    height: 5,
                    color: ValorantTheme.valorantRed,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AĞIR TOP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ValorantTheme.textWhite,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TACTICAL BRACER INTERFACE',
                    style: TextStyle(
                      color: ValorantTheme.textMuted.withValues(alpha: 0.9),
                      fontSize: 11,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 1. Buton: Hafif Top
                  ValorantMenuButton(
                    title: 'Hafif Top',
                    subLabel: 'STANDBY // DORMANT',
                    onTap: () => _showInactiveSnackBar(context),
                  ),
                  const SizedBox(height: 18),

                  // 2. Buton: Orta Top
                  ValorantMenuButton(
                    title: 'Orta Top',
                    subLabel: 'STANDBY // DORMANT',
                    onTap: () => _showInactiveSnackBar(context),
                  ),
                  const SizedBox(height: 18),

                  // 3. Buton: Ağır Top (Aktif / Primary)
                  ValorantMenuButton(
                    title: 'Ağır Top',
                    isPrimary: true,
                    subLabel: 'ARMED // AUTHORIZED',
                    onTap: () {
                      try {
                        HapticFeedback.mediumImpact();
                      } catch (_) {}
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelefonEkrani(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Alt Köşe Çizgileri ve Alt Orta İmza
          Positioned(
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        isDesktopPlatform ? 'VAL // PC' : 'VAL // MOB',
                        style: const TextStyle(color: ValorantTheme.textMuted, fontSize: 10, letterSpacing: 1.5),
                      ),
                    ),
                    Container(
                      width: math.min(size.width * 0.2, 120.0),
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const Flexible(
                      child: Text(
                        'TACTICAL HUD',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: ValorantTheme.textMuted, fontSize: 10, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'By SantoPanto',
                  style: TextStyle(
                    color: ValorantTheme.textMuted.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. ROUTE: AĞIR TOP EKRANI (TELEFON ARAYÜZÜ VE ÇEKİRDEK DÖNGÜ)
// ============================================================================
class TelefonEkrani extends StatefulWidget {
  const TelefonEkrani({super.key});

  @override
  State<TelefonEkrani> createState() => _TelefonEkraniState();
}

class _TelefonEkraniState extends State<TelefonEkrani> {
  // Ekran 1 ve Ekran 2 durum takibi (Navigator kullanılmaz, döngü bu state ile sağlanır)
  bool _isFirstScreen = true;

  // Özelleştirilebilir telefon ayarları
  String _selectedAgent = 'Brimstone';
  String _displayName = 'Ben';

  // Çoklu platform (Mobil & PC) uyumlu ön-yüklemeli ses havuzu
  AudioPool? _audioPool;
  bool _isDisposed = false;
  DateTime? _lastFeedbackTime;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // PlayerMode.mediaPlayer + AudioPool: Android'de SoundPool'un completion
      // göndermeme hatasını (1 kez çalıp susma) önler, tüm platformlarda önceden
      // yüklü player havuzu ile sıfır gecikmeli ve tekrarlanabilir ses sağlar.
      final pool = await AudioPool.createFromAsset(
        path: 'sounds/transition.wav',
        minPlayers: 2,
        maxPlayers: 4,
        playerMode: PlayerMode.mediaPlayer,
      );
      if (_isDisposed) {
        await pool.dispose();
        return;
      }
      _audioPool = pool;
    } catch (e) {
      debugPrint('Ses havuzu başlatma uyarısı: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioPool?.dispose();
    super.dispose();
  }

  /// Telefon çerçevesine tıklandığında (veya PC'de Boşluk/Enter basıldığında) çalışan çekirdek işlem:
  /// 1. isFirstScreen state'inin anında tersine çevrilmesi (Sonsuz döngü)
  /// 2. Titreşim (Mobil için - hızlı tıklamada IPC tıkanmaması için 80ms korumalı)
  /// 3. transition.wav sesi (AudioPool ile her tıklamada kesintisiz çalma)
  void _handleDeviceTap() {
    // 1. UI durumunu anında güncelle (sıfır gecikme)
    if (mounted) {
      setState(() {
        _isFirstScreen = !_isFirstScreen;
      });
    }

    // Hızlı ardışık tıklamalarda native ses/titreşim kanallarını boğmamak için throttle (80ms)
    final now = DateTime.now();
    if (_lastFeedbackTime != null &&
        now.difference(_lastFeedbackTime!).inMilliseconds < 80) {
      return;
    }
    _lastFeedbackTime = now;

    // 2. Titreşim (Desteklenmeyen masaüstü sistemlerde sessizce yutulur)
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // 3. Havuzdan hazır bir player ile sesi başlat (her dokunuşta sıfırdan ve net çalar)
    if (_isDisposed) return;
    _audioPool?.start(volume: 1.0).catchError((Object e) {
      debugPrint('Ses çalma uyarısı: $e');
      return () async {};
    });
  }

  /// "Telefon Ayarları" ana pop-up menüsünü açar
  void _showPhoneSettingsDialog() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: CustomPaint(
              painter: ChamferBorderPainter(
                cutSize: 16,
                borderColor: ValorantTheme.cyanNeon,
                borderWidth: 1.8,
              ),
              child: ClipPath(
                clipper: const ChamferClipper(cutSize: 16),
                child: Container(
                  color: const Color(0xFF101820),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık ve Kapat Butonu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.settings, color: ValorantTheme.cyanNeon, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'TELEFON AYARLARI',
                                    style: TextStyle(
                                      color: ValorantTheme.textWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.6,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(dialogContext),
                              child: const Icon(Icons.close, color: ValorantTheme.textMuted, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                      const SizedBox(height: 16),

                      // Seçenek 1: Ajanı Değiştir
                      _SettingsOptionTile(
                        icon: Icons.person_search_outlined,
                        title: 'Ajanı Değiştir',
                        subtitle: 'Aktif Ajan: $_selectedAgent',
                        accentColor: ValorantTheme.cyanNeon,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showAgentPickerDialog();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Seçenek 2: İsim Değiştir
                      _SettingsOptionTile(
                        icon: Icons.edit_outlined,
                        title: 'İsim Değiştir',
                        subtitle: 'Görünür İsim: $_displayName',
                        accentColor: ValorantTheme.cyanNeon,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showNameEditorDialog();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Seçenek 3: Varsayılana Geri Dön
                      _SettingsOptionTile(
                        icon: Icons.restart_alt,
                        title: 'Varsayılana Geri Dön',
                        subtitle: 'Brimstone // "Ben"',
                        accentColor: ValorantTheme.valorantRed,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          if (mounted) {
                            setState(() {
                              _selectedAgent = 'Brimstone';
                              _displayName = 'Ben';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 1- "Ajanı Değiştir" seçim ekranı
  void _showAgentPickerDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
            child: CustomPaint(
              painter: ChamferBorderPainter(
                cutSize: 16,
                borderColor: ValorantTheme.cyanNeon,
                borderWidth: 1.8,
              ),
              child: ClipPath(
                clipper: const ChamferClipper(cutSize: 16),
                child: Container(
                  color: const Color(0xFF101820),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AJANI DEĞİŞTİR',
                            style: TextStyle(
                              color: ValorantTheme.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              fontFamily: 'monospace',
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(dialogContext),
                              child: const Icon(Icons.close, color: ValorantTheme.textMuted, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'VALORANT AJAN PROTOKOLÜ // ${valorantAgents.length} AJAN',
                        style: const TextStyle(
                          color: ValorantTheme.textMuted,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: valorantAgents.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final agent = valorantAgents[index];
                            final isSelected = agent.name == _selectedAgent;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      _selectedAgent = agent.name;
                                    });
                                  }
                                  Navigator.pop(dialogContext);
                                },
                                child: ClipPath(
                                  clipper: const ChamferClipper(cutSize: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? agent.accentColor.withValues(alpha: 0.22)
                                          : ValorantTheme.surfaceDark.withValues(alpha: 0.85),
                                      border: Border.all(
                                        color: isSelected
                                            ? agent.accentColor
                                            : Colors.white.withValues(alpha: 0.12),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: agent.accentColor.withValues(alpha: 0.2),
                                            border: Border.all(color: agent.accentColor.withValues(alpha: 0.7)),
                                          ),
                                          child: agent.portraitAsset != null
                                              ? Image.asset(
                                                  agent.portraitAsset!,
                                                  width: 38,
                                                  height: 38,
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.topCenter,
                                                )
                                              : Text(
                                                  agent.name.substring(0, 1),
                                                  style: TextStyle(
                                                    color: agent.accentColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                agent.name.toUpperCase(),
                                                style: const TextStyle(
                                                  color: ValorantTheme.textWhite,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.4,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              Text(
                                                agent.role,
                                                style: TextStyle(
                                                  color: agent.accentColor.withValues(alpha: 0.9),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle, color: agent.accentColor, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 2- "İsim Değiştir" metin giriş penceresi (Maksimum 20 karakter)
  void _showNameEditorDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (dialogContext) {
        return _NameEditorDialog(
          initialName: _displayName,
          onSave: (newName) {
            if (mounted) {
              setState(() {
                _displayName = newName;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isDesktop = isDesktopPlatform;

    // Fotoğraftaki Valorant telefonunun gerçek oranına (~0.56) uygun boyutlandırma
    final double maxH = math.min(screenSize.height * 0.80, 620.0);
    final double deviceWidth = math.min(screenSize.width * 0.86, maxH * 0.57);
    final double deviceHeight = deviceWidth / 0.57;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // PC Klavye Desteği: ESC tuşu menüye döndürür, Space / Enter cihaza tıklar
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            try {
              HapticFeedback.selectionClick();
            } catch (_) {}
            Navigator.pop(context);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _handleDeviceTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Arka Plan: Valorant oyun içi harita/duvar hissi veren doku (RepaintBoundary ile izole)
            const Positioned.fill(
              child: RepaintBoundary(
                child: TacticalMapBlurBackground(),
              ),
            ),

            // 2. Üst Taktiksel Bar (Sol üst: Menü, Sağ üst: Telefon Ayarları)
            Positioned(
              top: 16 + MediaQuery.paddingOf(context).top,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geri Dön Butonu (Fare ve dokunma için)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                        Navigator.pop(context);
                      },
                      child: ClipPath(
                        clipper: const ChamferClipper(cutSize: 8),
                        child: Container(
                          color: ValorantTheme.surfaceDark.withValues(alpha: 0.85),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios, color: ValorantTheme.valorantRed, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Menü',
                                style: TextStyle(
                                  color: ValorantTheme.textWhite,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sağ Üst: Telefon Ayarları Butonu
                  Flexible(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showPhoneSettingsDialog,
                        child: CustomPaint(
                          painter: ChamferBorderPainter(
                            cutSize: 8,
                            borderColor: ValorantTheme.cyanNeon.withValues(alpha: 0.7),
                            borderWidth: 1.2,
                          ),
                          child: ClipPath(
                            clipper: const ChamferClipper(cutSize: 8),
                            child: Container(
                              color: ValorantTheme.surfaceDark.withValues(alpha: 0.9),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.settings, color: ValorantTheme.cyanNeon, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'TELEFON AYARLARI',
                                      style: TextStyle(
                                        color: ValorantTheme.textWhite,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Merkez: Brimstone Telefon/Bileklik Taktiksel Cihaz Çerçevesi
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _handleDeviceTap,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: deviceWidth,
                    height: deviceHeight,
                    child: TacticalDeviceContainer(
                      isFirstScreen: _isFirstScreen,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 140),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Temaya uygun hızlı ve hafif Fade + dikey kayma efekti
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.03),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _isFirstScreen
                            ? RepaintBoundary(
                                key: ValueKey('ScreenOne_${_selectedAgent}_$_displayName'),
                                child: TacticalScreenOne(
                                  agentName: _selectedAgent,
                                  displayName: _displayName,
                                ),
                              )
                            : const RepaintBoundary(
                                key: ValueKey('ScreenTwo'),
                                child: TacticalScreenTwo(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Alt Bar: Sol altta LINKED göstergesi, sağ/ortada yönlendirme ipucu
            Positioned(
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol Alt: Cihaz Durum (LINKED) Göstergesi
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ValorantTheme.yellowAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isDesktop ? 'LINKED // PC' : 'LINKED // MOB',
                              style: const TextStyle(
                                color: ValorantTheme.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sağ Alt: Kullanıcıyı yönlendiren taktiksel ipucu
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDesktop ? Icons.mouse_outlined : Icons.touch_app_outlined,
                            color: ValorantTheme.textMuted.withValues(alpha: 0.8),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDesktop
                                ? 'TIKLA / [BOŞLUK] // [ESC] GERİ'
                                : 'CIHAZA DOKUN // MODU DEĞIŞTIR',
                            style: TextStyle(
                              color: ValorantTheme.textMuted.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VALORANT TELEFON POLİGON CLIPPER'LARI (FOTOĞRAFA BİREBİR KALKAN FORMU)
// ============================================================================
class ValorantPhoneBodyClipper extends CustomClipper<Path> {
  const ValorantPhoneBodyClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.14, 0)
      ..lineTo(w * 0.86, 0)
      ..lineTo(w * 0.97, h * 0.055)
      ..lineTo(w * 0.985, h * 0.12)
      ..lineTo(w * 0.95, h * 0.68)
      ..lineTo(w * 0.76, h * 0.79)
      ..lineTo(w * 0.71, h * 0.95)
      ..lineTo(w * 0.62, h)
      ..lineTo(w * 0.38, h)
      ..lineTo(w * 0.29, h * 0.95)
      ..lineTo(w * 0.24, h * 0.79)
      ..lineTo(w * 0.05, h * 0.68)
      ..lineTo(w * 0.015, h * 0.12)
      ..lineTo(w * 0.03, h * 0.055)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ValorantPhoneScreenClipper extends CustomClipper<Path> {
  const ValorantPhoneScreenClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.12, 0)
      ..lineTo(w * 0.35, 0)
      // Tam ortadan aşağıya doğru gelen dikdörtgensel/trapez çentik (Notch)
      ..lineTo(w * 0.375, h * 0.058)
      ..lineTo(w * 0.625, h * 0.058)
      ..lineTo(w * 0.65, 0)
      ..lineTo(w * 0.88, 0)
      // Sağ ve sol köşeler wifi/batarya ikonlarını kapatmayacak şekilde hafif eğimli
      ..lineTo(w * 0.985, h * 0.062)
      ..lineTo(w * 0.965, h * 0.855)
      ..lineTo(w * 0.56, h * 0.995)
      ..lineTo(w * 0.44, h * 0.995)
      ..lineTo(w * 0.035, h * 0.855)
      ..lineTo(w * 0.015, h * 0.062)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ValorantScreenBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ValorantScreenBorderPainter({
    required this.color,
    this.strokeWidth = 2.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = const ValorantPhoneScreenClipper().getClip(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ValorantScreenBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Fotoğraftaki Brimstone telefonunun dış kasasını, katmanlarını ve sarı üçgen butonunu çizer
class _ValorantPhoneShellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPath = const ValorantPhoneBodyClipper().getClip(size);

    // 1. Ana Kasa Gradyanı (Koyu antrasit / metalik gri)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF393E46),
          Color(0xFF23272D),
          Color(0xFF15181C),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(bodyPath, bodyPaint);

    // 2. Dış Kenar Aydınlık Bevel Çizgisi
    final bevelPaint = Paint()
      ..color = const Color(0xFF555C66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(bodyPath, bevelPaint);

    // 3. İç Kasa Çerçeve Basamağı (Koyu recessed bezel + üst orta notch uzantısı)
    final innerBezelPath = Path()
      ..moveTo(w * 0.16, h * 0.025)
      ..lineTo(w * 0.84, h * 0.025)
      ..lineTo(w * 0.925, h * 0.075)
      ..lineTo(w * 0.905, h * 0.665)
      ..lineTo(w * 0.71, h * 0.76)
      ..lineTo(w * 0.29, h * 0.76)
      ..lineTo(w * 0.095, h * 0.665)
      ..lineTo(w * 0.075, h * 0.075)
      ..close();
    canvas.drawPath(innerBezelPath, Paint()..color = const Color(0xFF101317));
    canvas.drawPath(
      innerBezelPath,
      Paint()
        ..color = const Color(0xFF424852)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 4. Üst Orta Aşağıya Doğru Gelen Dikdörtgensel/Trapez Çentik (Notch) & Hoparlör
    final centerNotchPath = Path()
      ..moveTo(w * 0.36, 0)
      ..lineTo(w * 0.64, 0)
      ..lineTo(w * 0.615, h * 0.082)
      ..lineTo(w * 0.385, h * 0.082)
      ..close();
    canvas.drawPath(centerNotchPath, Paint()..color = const Color(0xFF22262C));
    canvas.drawPath(
      centerNotchPath,
      Paint()
        ..color = const Color(0xFF4C535E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final notchRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.035), width: w * 0.14, height: h * 0.010),
      const Radius.circular(2),
    );
    canvas.drawRRect(notchRect, Paint()..color = const Color(0xFF0E1014));

    // 5. Sağ Üst-Orta Yan Buton Çıkıntısı
    final sideBtnRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.955, h * 0.25, w * 0.035, h * 0.11),
      const Radius.circular(2),
    );
    canvas.drawRRect(sideBtnRect, Paint()..color = const Color(0xFF484F59));

    // 6. Alt V-Yuvası ve Alt Çene Katman Çizgisi
    final chinLinePath = Path()
      ..moveTo(w * 0.24, h * 0.79)
      ..lineTo(w * 0.42, h * 0.855)
      ..lineTo(w * 0.58, h * 0.855)
      ..lineTo(w * 0.76, h * 0.79);
    canvas.drawPath(
      chinLinePath,
      Paint()
        ..color = const Color(0xFF0C0E11)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    canvas.drawPath(
      chinLinePath.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0xFF3E444D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 7. Alt Çene Koyu Tutamaç Girintisi
    final gripPath = Path()
      ..moveTo(w * 0.34, h * 0.895)
      ..lineTo(w * 0.66, h * 0.895)
      ..lineTo(w * 0.61, h * 0.965)
      ..lineTo(w * 0.39, h * 0.965)
      ..close();
    canvas.drawPath(gripPath, Paint()..color = const Color(0xFF101316));
    canvas.drawLine(
      Offset(w * 0.41, h * 0.93),
      Offset(w * 0.59, h * 0.93),
      Paint()
        ..color = const Color(0xFF3B4048)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // 8. Alt Ortadaki İkonik Parlak Sarı Üçgen Detayı
    final triCenterX = w * 0.50;
    final triTopY = h * 0.742;
    final triBottomY = h * 0.818;
    final triHalfW = w * 0.082;

    // Sarı üçgenin koyu çerçeve yuvası
    final triSocket = Path()
      ..moveTo(triCenterX - triHalfW - 4, triTopY - 3)
      ..lineTo(triCenterX + triHalfW + 4, triTopY - 3)
      ..lineTo(triCenterX, triBottomY + 5)
      ..close();
    canvas.drawPath(triSocket, Paint()..color = const Color(0xFF0B0D10));

    // Parlak sarı / kehribar üçgen
    final triPath = Path()
      ..moveTo(triCenterX - triHalfW, triTopY)
      ..lineTo(triCenterX + triHalfW, triTopY)
      ..lineTo(triCenterX, triBottomY)
      ..close();

    final triPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFE45C),
          Color(0xFFFFC814),
          Color(0xFFE59200),
        ],
      ).createShader(Rect.fromLTWH(triCenterX - triHalfW, triTopY, triHalfW * 2, triBottomY - triTopY));
    canvas.drawPath(triPath, triPaint);

    // Sarı üçgen üst parlama çizgisi
    canvas.drawLine(
      Offset(triCenterX - triHalfW + 3, triTopY + 1.5),
      Offset(triCenterX + triHalfW - 3, triTopY + 1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// TAKTİKSEL TELEFON ÇERÇEVESİ (VALORANT BİREBİR CİHAZ GÖVDESİ)
// ============================================================================
class TacticalDeviceContainer extends StatelessWidget {
  final Widget child;
  final bool isFirstScreen;

  const TacticalDeviceContainer({
    super.key,
    required this.child,
    required this.isFirstScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Fotoğraftaki telefonda hem ön hem arka sayfa parlak turkuaz çerçeve kullanır
    const Color currentNeonColor = Color(0xFF5BF5F5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Dış Telefon Gövdesi (RepaintBoundary ile izole statik katman)
            RepaintBoundary(
              child: CustomPaint(
                size: Size(w, h),
                painter: _ValorantPhoneShellPainter(),
              ),
            ),

            // 2. İç Ekran Poligonu (Fotoğraftaki kalkan/V-tabanlı ekran alanı)
            Positioned(
              top: h * 0.042,
              left: w * 0.105,
              right: w * 0.105,
              bottom: h * 0.275,
              child: ClipPath(
                clipper: const ValorantPhoneScreenClipper(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ekran içeriği (FittedBox ile taşma korumalı)
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: 260,
                          height: 390,
                          child: child,
                        ),
                      ),
                    ),
                    // Parlak poligon kenarlığı
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _ValorantScreenBorderPainter(
                          color: currentNeonColor,
                          strokeWidth: 2.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// İÇERİK - EKRAN 1: FOTOĞRAFA BİREBİR AJAN PORTRESİ + İSİM + ÇİFT SES DALGASI
// ============================================================================
class TacticalScreenOne extends StatelessWidget {
  final String agentName;
  final String displayName;

  const TacticalScreenOne({
    super.key,
    this.agentName = 'Brimstone',
    this.displayName = 'Ben',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF104F5B),
            Color(0xFF1B7B8C),
            Color(0xFF0E4652),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // İnce yatay scanline ve kenar cetvel detayları
          IgnorePointer(
            child: CustomPaint(
              painter: _ScreenScanlinesPainter(),
            ),
          ),

          // Ana İçerik Sütunu (Üstte sinyal/wifi ve batarya göstergeleri + çentik boşluğu)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              children: [
                const _PhoneTopStatusBar(),
                const SizedBox(height: 10),

                // 1. Üst Kısım: Seçili Ajan Portre Penceresi
                Expanded(
                  flex: 52,
                  child: BrimstoneAvatarWidget(agentName: agentName),
                ),
                const SizedBox(height: 8),

                // 2. Orta Kısım: İsim Bandı (Varsayılan: "Ben", Maksimum 20 karakter korumalı)
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF092B33).withValues(alpha: 0.65),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: const Color(0xFF6CF7F7).withValues(alpha: 0.45),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTechDots(),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayName,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildTechDots(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Alt-Orta Kısım: "00" + Çift Sinüs Ses Dalgası Paneli
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 3),
                      child: Text(
                        '00',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      height: 46,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08252C).withValues(alpha: 0.65),
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: const Color(0xFF6CF7F7).withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const TacticalWaveformWidget(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. En Alt Kısım: Fotoğraftaki ince segment göstergeleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: i == 1 ? 34 : 22,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: i == 1 ? 0.55 : 0.25),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 1.5, color: const Color(0xFF6CF7F7).withValues(alpha: 0.55)),
        const SizedBox(width: 3),
        Container(width: 3, height: 1.5, color: const Color(0xFF6CF7F7).withValues(alpha: 0.75)),
      ],
    );
  }
}

/// Ekran içi yatay tarama çizgileri ve kenar cetvel işaretleri
class _ScreenScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    // Sol ve sağ kenar küçük tick çizgileri
    final tickPaint = Paint()
      ..color = const Color(0xFF74FAFA).withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    for (double y = size.height * 0.52; y < size.height * 0.78; y += 8) {
      canvas.drawLine(Offset(8, y), Offset(13, y), tickPaint);
      canvas.drawLine(Offset(size.width - 13, y), Offset(size.width - 8, y), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Telefonun her iki ekranında da kullanılan ortak üst durum çubuğu (Wifi & Batarya)
class _PhoneTopStatusBar extends StatelessWidget {
  const _PhoneTopStatusBar();

  @override
  Widget build(BuildContext context) {
    final iconColor = const Color(0xFF84FCFC).withValues(alpha: 0.9);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.signal_cellular_alt, color: iconColor, size: 13),
              const SizedBox(width: 4),
              Icon(Icons.wifi, color: iconColor, size: 13),
            ],
          ),
          Icon(Icons.battery_charging_full, color: iconColor, size: 15),
        ],
      ),
    );
  }
}

// ============================================================================
// İÇERİK - EKRAN 2: ARKA SAYFA (CELESTIAL_CARD OYUNCU KARTI + "AĞIR TOP" ÜNVANI)
// ============================================================================
class TacticalScreenTwo extends StatelessWidget {
  const TacticalScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF104F5B),
            Color(0xFF1B7B8C),
            Color(0xFF0E4652),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // İnce yatay scanline arka plan efekti
          IgnorePointer(
            child: CustomPaint(
              painter: _ScreenScanlinesPainter(),
            ),
          ),

          // Ana İçerik Sütunu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 14),
            child: Column(
              children: [
                // 1. Üst Durum Çubuğu (Çentiğin solunda Wifi, sağında Batarya tam görünür)
                const _PhoneTopStatusBar(),
                const SizedBox(height: 12),

                // 2. Oyuncu Kartı Bölmesi (Celestial_Card - Boğa kafası & dolunay tam görünür)
                Expanded(
                  flex: 54,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF7BFBFB).withValues(alpha: 0.85),
                        width: 1.5,
                      ),
                      color: const Color(0xFF0A333C).withValues(alpha: 0.45),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE6C88B).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/celestial_card.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.white54),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Oyuncu Ünvanı Bölmesi ("AĞIR TOP" - fotoğraftaki "SIRILSIKLAM" bandı)
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: const Color(0xFF84FCFC).withValues(alpha: 0.65),
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'AĞIR TOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Orta-Alt Kısım: Sol çift ikon + Sinüs Ses Dalgası + Sağ dikey seviye çubukları
                SizedBox(
                  height: 44,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sol taraftaki çift açık turkuaz kutu ikonu
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9DFDFD).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Container(
                            width: 7,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9DFDFD).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Akıcı Sinüs Ses Dalgası
                      const Expanded(
                        child: TacticalWaveformWidget(color: Colors.white),
                      ),
                      const SizedBox(width: 8),

                      // Sağ kenardaki merdiven/seviye çubukları
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          return Container(
                            width: 12,
                            height: 2.2,
                            margin: const EdgeInsets.symmetric(vertical: 1.5),
                            color: const Color(0xFF84FCFC).withValues(
                              alpha: i < 5 ? 0.75 : 0.35,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 5. En Alt Kısım: İki eğimli paralelkenar gösterge (Sol turkuaz, Sağ beyaz)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      transform: Matrix4.skewX(-0.35),
                      child: Container(
                        width: 34,
                        height: 8,
                        color: const Color(0xFF56C9D4).withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform(
                      transform: Matrix4.skewX(-0.35),
                      child: Container(
                        width: 34,
                        height: 8,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ÖZEL GRAFİK VE YARDIMCI WIDGET'LAR
// ============================================================================

// ============================================================================
// VALORANT AJAN LİSTESİ VE AYARLAR YARDIMCI BİLEŞENLERİ
// ============================================================================
class ValorantAgent {
  final String name;
  final String role;
  final Color accentColor;
  final String? portraitAsset;

  const ValorantAgent({
    required this.name,
    required this.role,
    required this.accentColor,
    this.portraitAsset,
  });
}

const List<ValorantAgent> valorantAgents = [
  ValorantAgent(
    name: 'Brimstone',
    role: 'CONTROLLER',
    accentColor: Color(0xFFFF7A2F),
    portraitAsset: 'assets/images/brimstone_portrait.jpg',
  ),
  ValorantAgent(
    name: 'Jett',
    role: 'DUELIST',
    accentColor: Color(0xFF66E2FF),
    portraitAsset: 'assets/images/agents/jett.jpg',
  ),
  ValorantAgent(
    name: 'Reyna',
    role: 'DUELIST',
    accentColor: Color(0xFFD95BFF),
    portraitAsset: 'assets/images/agents/reyna.jpg',
  ),
  ValorantAgent(
    name: 'Sage',
    role: 'SENTINEL',
    accentColor: Color(0xFF3BF0C5),
    portraitAsset: 'assets/images/agents/sage.jpg',
  ),
  ValorantAgent(
    name: 'Sova',
    role: 'INITIATOR',
    accentColor: Color(0xFF4CA6FF),
    portraitAsset: 'assets/images/agents/sova.jpg',
  ),
  ValorantAgent(
    name: 'Omen',
    role: 'CONTROLLER',
    accentColor: Color(0xFF7B68EE),
    portraitAsset: 'assets/images/agents/omen.jpg',
  ),
  ValorantAgent(
    name: 'Phoenix',
    role: 'DUELIST',
    accentColor: Color(0xFFFF6B35),
    portraitAsset: 'assets/images/agents/phoenix.jpg',
  ),
  ValorantAgent(
    name: 'Viper',
    role: 'CONTROLLER',
    accentColor: Color(0xFF38E54D),
    portraitAsset: 'assets/images/agents/viper.jpg',
  ),
  ValorantAgent(
    name: 'Cypher',
    role: 'SENTINEL',
    accentColor: Color(0xFF9EC5FF),
    portraitAsset: 'assets/images/agents/cypher.jpg',
  ),
  ValorantAgent(
    name: 'Breach',
    role: 'INITIATOR',
    accentColor: Color(0xFFE07A2E),
    portraitAsset: 'assets/images/agents/breach.jpg',
  ),
  ValorantAgent(
    name: 'Killjoy',
    role: 'SENTINEL',
    accentColor: Color(0xFFFFD426),
    portraitAsset: 'assets/images/agents/killjoy.jpg',
  ),
  ValorantAgent(
    name: 'Raze',
    role: 'DUELIST',
    accentColor: Color(0xFFFF8C42),
    portraitAsset: 'assets/images/agents/raze.jpg',
  ),
  ValorantAgent(
    name: 'Skye',
    role: 'INITIATOR',
    accentColor: Color(0xFF5DE2A5),
    portraitAsset: 'assets/images/agents/skye.jpg',
  ),
  ValorantAgent(
    name: 'Yoru',
    role: 'DUELIST',
    accentColor: Color(0xFF4361EE),
    portraitAsset: 'assets/images/agents/yoru.jpg',
  ),
  ValorantAgent(
    name: 'Astra',
    role: 'CONTROLLER',
    accentColor: Color(0xFFA855F7),
    portraitAsset: 'assets/images/agents/astra.jpg',
  ),
  ValorantAgent(
    name: 'KAY/O',
    role: 'INITIATOR',
    accentColor: Color(0xFF4EA8DE),
    portraitAsset: 'assets/images/agents/kayo.jpg',
  ),
  ValorantAgent(
    name: 'Chamber',
    role: 'SENTINEL',
    accentColor: Color(0xFFE9C46A),
    portraitAsset: 'assets/images/agents/chamber.jpg',
  ),
  ValorantAgent(
    name: 'Neon',
    role: 'DUELIST',
    accentColor: Color(0xFF00D2FF),
    portraitAsset: 'assets/images/agents/neon.jpg',
  ),
  ValorantAgent(
    name: 'Fade',
    role: 'INITIATOR',
    accentColor: Color(0xFF9D4EDD),
    portraitAsset: 'assets/images/agents/fade.jpg',
  ),
  ValorantAgent(
    name: 'Harbor',
    role: 'CONTROLLER',
    accentColor: Color(0xFF2EC4B6),
    portraitAsset: 'assets/images/agents/harbor.jpg',
  ),
  ValorantAgent(
    name: 'Gekko',
    role: 'INITIATOR',
    accentColor: Color(0xFFAACC00),
    portraitAsset: 'assets/images/agents/gekko.jpg',
  ),
  ValorantAgent(
    name: 'Deadlock',
    role: 'SENTINEL',
    accentColor: Color(0xFFBDB2FF),
    portraitAsset: 'assets/images/agents/deadlock.jpg',
  ),
  ValorantAgent(
    name: 'Iso',
    role: 'DUELIST',
    accentColor: Color(0xFF7209B7),
    portraitAsset: 'assets/images/agents/iso.jpg',
  ),
  ValorantAgent(
    name: 'Clove',
    role: 'CONTROLLER',
    accentColor: Color(0xFFFF66B3),
    portraitAsset: 'assets/images/agents/clove.jpg',
  ),
  ValorantAgent(
    name: 'Vyse',
    role: 'SENTINEL',
    accentColor: Color(0xFFC77DFF),
    portraitAsset: 'assets/images/agents/vyse.jpg',
  ),
  ValorantAgent(
    name: 'Tejo',
    role: 'INITIATOR',
    accentColor: Color(0xFFF4A261),
    portraitAsset: 'assets/images/agents/tejo.jpg',
  ),
];

class _SettingsOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _SettingsOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: const ChamferClipper(cutSize: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ValorantTheme.surfaceDark,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ValorantTheme.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ValorantTheme.textMuted.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: accentColor.withValues(alpha: 0.8), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NameEditorDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _NameEditorDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<_NameEditorDialog> createState() => _NameEditorDialogState();
}

class _NameEditorDialogState extends State<_NameEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) {
      widget.onSave(trimmed.length > 20 ? trimmed.substring(0, 20) : trimmed);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: CustomPaint(
          painter: ChamferBorderPainter(
            cutSize: 16,
            borderColor: ValorantTheme.cyanNeon,
            borderWidth: 1.8,
          ),
          child: ClipPath(
            clipper: const ChamferClipper(cutSize: 16),
            child: Container(
              color: const Color(0xFF101820),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'İSİM DEĞİŞTİR',
                        style: TextStyle(
                          color: ValorantTheme.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: ValorantTheme.textMuted, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: 20,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                      color: ValorantTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Yeni isim (maks. 20 karakter)',
                      hintStyle: TextStyle(
                        color: ValorantTheme.textMuted.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: ValorantTheme.surfaceDark,
                      counterStyle: const TextStyle(
                        color: ValorantTheme.cyanNeon,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: ValorantTheme.cyanNeon.withValues(alpha: 0.45),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: ValorantTheme.cyanNeon,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ValorantTheme.surfaceDark,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Text(
                                'İPTAL',
                                style: TextStyle(
                                  color: ValorantTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _submit,
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ValorantTheme.cyanNeon.withValues(alpha: 0.2),
                                border: Border.all(color: ValorantTheme.cyanNeon),
                              ),
                              child: const Text(
                                'KAYDET',
                                style: TextStyle(
                                  color: ValorantTheme.cyanNeon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Seçili Ajan Portresi (Varsayılan Brimstone iken fotoğrafını, diğer ajanlarda taktiksel ajan kartını gösterir)
class BrimstoneAvatarWidget extends StatelessWidget {
  final String agentName;

  const BrimstoneAvatarWidget({
    super.key,
    this.agentName = 'Brimstone',
  });

  @override
  Widget build(BuildContext context) {
    final agentInfo = valorantAgents.firstWhere(
      (a) => a.name == agentName,
      orElse: () => valorantAgents.first,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF103F49),
        border: Border.all(
          color: const Color(0xFF72FAFA).withValues(alpha: 0.75),
          width: 1.5,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (agentInfo.portraitAsset != null)
            Image.asset(
              agentInfo.portraitAsset!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/brimstone.png',
                  fit: BoxFit.cover,
                );
              },
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    agentInfo.accentColor.withValues(alpha: 0.30),
                    const Color(0xFF0E3E48),
                    const Color(0xFF092A32),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: agentInfo.accentColor.withValues(alpha: 0.18),
                      border: Border.all(color: agentInfo.accentColor, width: 2.0),
                    ),
                    child: Text(
                      agentInfo.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: agentInfo.accentColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    agentInfo.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    color: agentInfo.accentColor.withValues(alpha: 0.25),
                    child: Text(
                      agentInfo.role,
                      style: TextStyle(
                        color: agentInfo.accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Fotoğraftaki gibi alt kısımda ekranla bütünleşen hafif turkuaz gölge geçişi
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.65, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0E4B57).withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animasyonlu Çift Sinüs Ses Dalgası (Fotoğraftaki akıcı beyaz/turkuaz ses dalgaları)
class TacticalWaveformWidget extends StatefulWidget {
  final Color color;

  const TacticalWaveformWidget({
    super.key,
    required this.color,
  });

  @override
  State<TacticalWaveformWidget> createState() => _TacticalWaveformWidgetState();
}

class _TacticalWaveformWidgetState extends State<TacticalWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary + CustomPaint(repaint: _controller) ile sıfır widget rebuild (120 FPS akıcılık)
    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: CustomPaint(
          painter: _WaveformPainter(
            animation: _controller,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _WaveformPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerY = h / 2;
    final t = animation.value * 2 * math.pi;

    // Ortadaki ince yatay referans çizgisi
    canvas.drawLine(
      Offset(0, centerY),
      Offset(w, centerY),
      Paint()
        ..color = const Color(0xFF72FAFA).withValues(alpha: 0.3)
        ..strokeWidth = 1.0,
    );

    // 1. Birincil parlak beyaz sinüs dalgası
    final primaryPath = Path();
    // 2. İkincil kesişen ince yarı saydam dalga
    final secondaryPath = Path();

    const int steps = 60;
    for (int i = 0; i <= steps; i++) {
      final normX = i / steps;
      final x = normX * w;
      // Uçlara doğru yumuşak sönümleme (envelope)
      final envelope = math.sin(normX * math.pi);

      final y1 = centerY +
          math.sin(normX * 4.5 * math.pi + t) * (h * 0.38) * envelope;
      final y2 = centerY +
          math.sin(normX * 3.8 * math.pi - t * 1.2 + 1.1) * (h * 0.28) * envelope;

      if (i == 0) {
        primaryPath.moveTo(x, y1);
        secondaryPath.moveTo(x, y2);
      } else {
        primaryPath.lineTo(x, y1);
        secondaryPath.lineTo(x, y2);
      }
    }

    canvas.drawPath(
      secondaryPath,
      Paint()
        ..color = const Color(0xFF9DFDFD).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      primaryPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 2. Ekrandaki Hedefleme Radarı (Tactical Reticle)
class TacticalTargetReticleWidget extends StatefulWidget {
  const TacticalTargetReticleWidget({super.key});

  @override
  State<TacticalTargetReticleWidget> createState() => _TacticalTargetReticleWidgetState();
}

class _TacticalTargetReticleWidgetState extends State<TacticalTargetReticleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RotationTransition doğrudan GPU transform katmanını günceller, widget ağacını yeniden kurmaz
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _rotationController,
            child: CustomPaint(
              size: const Size(120, 120),
              painter: TacticalReticlePainter(color: ValorantTheme.valorantRed),
            ),
          ),
          const Icon(
            Icons.gps_fixed,
            color: ValorantTheme.valorantRed,
            size: 42,
          ),
        ],
      ),
    );
  }
}

/// Nişan halkasını çizen CustomPainter
class TacticalReticlePainter extends CustomPainter {
  final Color color;

  TacticalReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Kesikli yaylar (taktiksel radar bölümleri)
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + 0.15;
      const sweepAngle = (math.pi / 2) - 0.3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    // Taktiksel dış köşe işaretleri
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    canvas.drawLine(center + Offset(-radius - 4, 0), center + Offset(-radius + 4, 0), tickPaint);
    canvas.drawLine(center + Offset(radius - 4, 0), center + Offset(radius + 4, 0), tickPaint);
    canvas.drawLine(center + Offset(0, -radius - 4), center + Offset(0, -radius + 4), tickPaint);
    canvas.drawLine(center + Offset(0, radius - 4), center + Offset(0, radius + 4), tickPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cihazın Alt Ortasındaki Sarı Üçgen Detayı
class YellowTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ValorantTheme.yellowAccent
      ..style = PaintingStyle.fill;

    // Aşağı bakan taktiksel sarı üçgen
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // İnce siyah iç çizgi
    final innerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cihaz Köşelerindeki Endüstriyel Perçin/Vida Detayı
class HardwareRivet extends StatelessWidget {
  const HardwareRivet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFF3B444C),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1B2228),
          width: 1.0,
        ),
      ),
    );
  }
}

/// Ana Menü Arka Plan Taktiksel Grid Çizici
class TacticalGridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Taktiksel diyagonal çizgiler
    final accentPaint = Paint()
      ..color = ValorantTheme.valorantRed.withValues(alpha: 0.04)
      ..strokeWidth = 30.0;

    canvas.drawLine(
      Offset(-100, size.height * 0.7),
      Offset(size.width + 100, size.height * 0.2),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Telefon Ekranı Arka Planı (Bulanık Harita/Taktiksel Grid Dokusu)
class TacticalMapBlurBackground extends StatelessWidget {
  const TacticalMapBlurBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Koyu taktiksel harita alt katmanı
        Container(
          color: const Color(0xFF090E13),
        ),
        // Harita kontur çizgileri simülasyonu
        CustomPaint(
          size: Size.infinite,
          painter: TacticalMapLinesPainter(),
        ),
        // Karanlık vignette katmanı
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Harita konturlarını ve gridini çizen Painter
class TacticalMapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF18232C).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Harita bölge kontur çizgileri
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.35);
    path.lineTo(size.width * 0.6, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.4);

    path.moveTo(0, size.height * 0.65);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.58);
    path.lineTo(size.width, size.height * 0.75);

    canvas.drawPath(path, paint);

    // Hedefleme artıları (crosshairs)
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    void drawCross(double x, double y) {
      canvas.drawLine(Offset(x - 6, y), Offset(x + 6, y), crossPaint);
      canvas.drawLine(Offset(x, y - 6), Offset(x, y + 6), crossPaint);
    }

    drawCross(size.width * 0.25, size.height * 0.2);
    drawCross(size.width * 0.75, size.height * 0.22);
    drawCross(size.width * 0.2, size.height * 0.82);
    drawCross(size.width * 0.8, size.height * 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
