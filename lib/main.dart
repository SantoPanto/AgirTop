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
      title: 'Ağır Top // Tactical Bracer',
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
            top: 24,
            right: 24,
            child: Text(
              isDesktopPlatform ? 'SYS.VER.2.4 [PC]' : 'SYS.VER.2.4 [MOB]',
              style: const TextStyle(
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

          // Alt Köşe Çizgileri
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Row(
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

  // Düşük gecikmeli ses oynatıcı
  late final AudioPlayer _audioPlayer;
  bool _isDisposed = false;
  bool _isAudioBusy = false;
  DateTime? _lastFeedbackTime;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    // Gecikmesiz ses çalabilmek için lowLatency moduna alıyoruz
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setSource(AssetSource('sounds/transition.wav'));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Telefon çerçevesine tıklandığında (veya PC'de Boşluk/Enter basıldığında) çalışan çekirdek işlem:
  /// 1. Titreşim (Mobil için - hızlı tıklamada IPC tıkanmaması için 80ms korumalı)
  /// 2. transition.wav sesi (Platform kanalını kilitlememek için throttle & busy korumalı)
  /// 3. isFirstScreen state'inin anında tersine çevrilmesi (Sonsuz döngü)
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

    // 3. Gecikmesiz ses çalma (Önceki native çağrı bitmediyse kuyruğu şişirmemek için atlanır)
    if (_isAudioBusy || _isDisposed) return;
    _isAudioBusy = true;
    _audioPlayer.play(AssetSource('sounds/transition.wav')).catchError((e) {
      debugPrint('Ses çalma uyarısı: $e');
    }).whenComplete(() {
      _isAudioBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isDesktop = isDesktopPlatform;

    // Cihaz boyutları (hem mobilde hem de PC'de en uygun en-boy oranını korur)
    final double deviceWidth = math.min(screenSize.width * 0.88, 360.0);
    final double deviceHeight = math.min(screenSize.height * 0.78, 580.0);

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

            // 2. Üst Taktiksel Bar (Geri dönüş butonu - AppBar kullanılmaz)
            Positioned(
              top: 20,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios, color: ValorantTheme.valorantRed, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                isDesktop ? 'MENÜ [ESC]' : 'MENÜ',
                                style: const TextStyle(
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
                  const SizedBox(width: 12),
                  // Cihaz Durum Bilgisi
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
                            ? const RepaintBoundary(
                                key: ValueKey('ScreenOne'),
                                child: TacticalScreenOne(),
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

            // 4. Alt Kısım: Kullanıcıyı yönlendiren taktiksel ipucu (Mobil/PC uyumlu)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDesktop ? Icons.mouse_outlined : Icons.touch_app_outlined,
                        color: ValorantTheme.textMuted.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDesktop
                            ? 'CIHAZA TIKLA VEYA [BOŞLUK] // [ESC] GERİ'
                            : 'CIHAZA DOKUN // MODU DEĞIŞTIR',
                        style: TextStyle(
                          color: ValorantTheme.textMuted.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAKTİKSEL TELEFON ÇERÇEVESİ (BRIMSTONE BRACER FRAME - RESPONSIVE)
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
    const double outerCut = 24.0;
    const double innerCut = 16.0;

    // Neon çerçeve rengi (Ekran 1 için Cyan, Ekran 2 için Valorant Kırmızısı/Turuncu)
    final Color currentNeonColor = isFirstScreen
        ? ValorantTheme.cyanNeon
        : ValorantTheme.valorantRed;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Kalın ve koyu renkli taktiksel dış kasa (RepaintBoundary ile statik katman izole edilir)
        RepaintBoundary(
          child: ClipPath(
            clipper: const ChamferClipper(cutSize: outerCut),
            child: Container(
              decoration: BoxDecoration(
                color: ValorantTheme.surfaceBezel,
                border: Border.all(
                  color: const Color(0xFF2C353D),
                  width: 2.0,
                ),
              ),
              child: Stack(
                children: [
                  // Dış kasada endüstriyel vida/köşe detayları
                  const Positioned(
                    top: 10,
                    left: 14,
                    child: HardwareRivet(),
                  ),
                  const Positioned(
                    top: 10,
                    right: 14,
                    child: HardwareRivet(),
                  ),
                  const Positioned(
                    bottom: 10,
                    left: 14,
                    child: HardwareRivet(),
                  ),
                  const Positioned(
                    bottom: 10,
                    right: 14,
                    child: HardwareRivet(),
                  ),

                  // Taktiksel Markalama
                  const Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'KINGDOM // BRACER-MK4',
                        style: TextStyle(
                          color: Color(0xFF4C5864),
                          fontSize: 9,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),

                  // Cihazın Alt Ortasındaki Küçük Sarı Üçgen Detayı
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CustomPaint(
                        size: const Size(18, 14),
                        painter: YellowTrianglePainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Cihazın İç Ekranı (İçeriği saran neon çerçeve ve ekran alanı)
        // FittedBox ile sarmalanarak her pencere/ekran boyutunda asla overflow vermez
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 28, left: 16, right: 16),
          child: ClipPath(
            clipper: const ChamferClipper(cutSize: innerCut),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1217),
                border: Border.all(
                  color: currentNeonColor,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 320,
                    height: 480,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// İÇERİK - EKRAN 1: BRIMSTONE PORTRESİ, "ME", VE SES DALGASI
// ============================================================================
class TacticalScreenOne extends StatelessWidget {
  const TacticalScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080D11),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Üst durum çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: ValorantTheme.cyanNeon.withValues(alpha: 0.15),
                child: const Text(
                  'CHAN 01 // COMMS',
                  style: TextStyle(
                    color: ValorantTheme.cyanNeon,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.wifi, color: ValorantTheme.cyanNeon, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: ValorantTheme.cyanNeon,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Üst Kısım: Brimstone Portresi (Asset Placeholder)
          const BrimstoneAvatarWidget(),

          // Altında "Me" metni
          Column(
            children: [
              const Text(
                'ME',
                style: TextStyle(
                  color: ValorantTheme.textWhite,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'COMMANDER // BRIMSTONE',
                style: TextStyle(
                  color: ValorantTheme.cyanNeon.withValues(alpha: 0.8),
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Animasyonlu Ses Dalgası (Waveform)
          const TacticalWaveformWidget(color: ValorantTheme.cyanNeon),

          // Alt teknik metin
          Text(
            'FREQUENCY ENCRYPTED // TACTICAL AUDIO STREAM',
            style: TextStyle(
              color: ValorantTheme.textMuted.withValues(alpha: 0.7),
              fontSize: 8,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// İÇERİK - EKRAN 2: FARKLI TAKTİKSEL VERİ ("BAĞLANTI KURULDU" / YÖRÜNGE SALDIRISI)
// ============================================================================
class TacticalScreenTwo extends StatelessWidget {
  const TacticalScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF11080A),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Üst durum çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: ValorantTheme.valorantRed.withValues(alpha: 0.2),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ORBITAL LINK',
                      style: TextStyle(
                        color: ValorantTheme.valorantRed,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, color: ValorantTheme.valorantRed, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'SYNCED',
                    style: TextStyle(
                      color: ValorantTheme.valorantRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Taktiksel Radar / Hedef Kilitleme Görseli
          const TacticalTargetReticleWidget(),

          // "Bağlantı Kuruldu" Başlığı ve Taktiksel Veri
          Column(
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'BAĞLANTI KURULDU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ValorantTheme.valorantRed,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ValorantTheme.valorantRed.withValues(alpha: 0.15),
                  border: Border.all(color: ValorantTheme.valorantRed.withValues(alpha: 0.5)),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'AĞIR TOP: YÖRÜNGE SALDIRISI HAZIR',
                    style: TextStyle(
                      color: ValorantTheme.textWhite,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Taktiksel Telemetri / Koordinat Tablosu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.black.withValues(alpha: 0.4),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TARGET:', style: TextStyle(color: ValorantTheme.textMuted, fontSize: 8, fontFamily: 'monospace')),
                    Text('34.05° N, 118.24° W', style: TextStyle(color: ValorantTheme.textWhite, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RADIUS:', style: TextStyle(color: ValorantTheme.textMuted, fontSize: 8, fontFamily: 'monospace')),
                    Text('850 METERS', style: TextStyle(color: ValorantTheme.valorantRed, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),

          // Alt teknik metin
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'SATELLITE BEAM ALIGNED // READY',
              style: TextStyle(
                color: ValorantTheme.textMuted,
                fontSize: 8,
                letterSpacing: 1.2,
                fontFamily: 'monospace',
              ),
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

/// Brimstone Ajan Portresi (Asset Placeholder & Taktiksel İkon Çerçevesi)
class BrimstoneAvatarWidget extends StatelessWidget {
  const BrimstoneAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const double cut = 14.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış neon çerçeve
        CustomPaint(
          size: const Size(120, 120),
          painter: ChamferBorderPainter(
            cutSize: cut,
            borderColor: ValorantTheme.cyanNeon,
            borderWidth: 1.5,
          ),
          child: ClipPath(
            clipper: const ChamferClipper(cutSize: cut),
            child: Container(
              width: 120,
              height: 120,
              color: const Color(0xFF142028),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Eğer gerçek görsel asset varsa yükler, yoksa taktiksel ikon portresi çizer
                  Image.asset(
                    'assets/images/brimstone.png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder Taktiksel Komutan Portresi
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.military_tech,
                            size: 48,
                            color: ValorantTheme.cyanNeon.withValues(alpha: 0.85),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: ValorantTheme.cyanNeon.withValues(alpha: 0.2),
                            child: const Text(
                              'BRIMSTONE',
                              style: TextStyle(
                                color: ValorantTheme.cyanNeon,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Köşe taktiksel çentikleri
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 8,
            height: 8,
            color: ValorantTheme.cyanNeon,
          ),
        ),
      ],
    );
  }
}

/// Animasyonlu Ses Dalgası (Tactical Waveform)
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
      duration: const Duration(milliseconds: 1200),
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
        width: 180,
        height: 38,
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
    const int barCount = 24;
    const double barWidth = 3.5;
    const double spacing = 3.6;
    const double totalWidth = barCount * barWidth + (barCount - 1) * spacing;
    final double startX = (size.width - totalWidth) / 2;
    final double centerY = size.height / 2;
    final double t = animation.value * 2 * math.pi;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int index = 0; index < barCount; index++) {
      final phase = (index / barCount) * 2 * math.pi;
      final wave = math.sin(t + phase) * 0.5 + 0.5;
      final norm = (index - 11.5) / 12.0;
      final centerWeight = 1.0 - (norm * norm * 0.6);
      final barHeight = math.max(6.0, 36.0 * wave * centerWeight);

      paint.color = color.withValues(alpha: 0.35 + (wave * 0.65));

      final x = startX + index * (barWidth + spacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, paint);
    }
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
