import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agir_top/main.dart';

void main() {
  testWidgets('Agir Top app navigation and tactical phone cycle test (Mobile & PC touch/click)', (WidgetTester tester) async {
    // 1. Uygulama başlatılır
    await tester.pumpWidget(const AgirTopApp());
    await tester.pump(const Duration(milliseconds: 100));

    // 2. Ana menü butonları ekranda olmalıdır
    final hafifBtn = find.widgetWithText(ValorantMenuButton, 'Hafif Top'.toUpperCase());
    final ortaBtn = find.widgetWithText(ValorantMenuButton, 'Orta Top'.toUpperCase());
    final agirBtn = find.widgetWithText(ValorantMenuButton, 'Ağır Top'.toUpperCase());

    expect(hafifBtn, findsOneWidget);
    expect(ortaBtn, findsOneWidget);
    expect(agirBtn, findsOneWidget);
    expect(find.text('AgırTop Ver0.1'), findsOneWidget);
    expect(find.text('By SantoPanto'), findsOneWidget);

    // 3. Hafif Top butonuna tıklandığında SnackBar çıkmalı ("Şu anlık aktif değil")
    await tester.tap(hafifBtn);
    await tester.pump();
    expect(find.text('Şu anlık aktif değil'), findsOneWidget);

    // 4. Ağır Top butonuna tıklandığında TelefonEkrani'na geçilmeli
    await tester.tap(agirBtn);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 5. TelefonEkrani üzerinde Ekran 1 ("Ben") ve "Menü" butonu görüntülenmeli
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Menü'), findsOneWidget);
    expect(find.byType(TacticalScreenTwo), findsNothing);

    // 6. Taktiksel cihaza tıklandığında (onTap) Ekran 2'ye geçmeli ("AĞIR TOP" ünvanı)
    final deviceContainer = find.byType(TacticalDeviceContainer);
    expect(deviceContainer, findsOneWidget);

    await tester.tap(deviceContainer);
    await tester.pump();
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(TacticalScreenTwo), findsOneWidget);
    expect(find.descendant(of: find.byType(TacticalScreenTwo), matching: find.text('AĞIR TOP')), findsOneWidget);
    expect(find.text('Ben'), findsNothing);

    // 7. Tekrar tıklandığında sonsuz döngü gereği Ekran 1'e geri dönmeli ("Ben")
    await tester.tap(deviceContainer);
    await tester.pump();
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Ben'), findsOneWidget);
    expect(find.byType(TacticalScreenTwo), findsNothing);
  });

  testWidgets('Agir Top PC keyboard shortcuts test (Space bar toggle and ESC back)', (WidgetTester tester) async {
    await tester.pumpWidget(const AgirTopApp());
    await tester.pump(const Duration(milliseconds: 100));

    final agirBtn = find.widgetWithText(ValorantMenuButton, 'Ağır Top'.toUpperCase());
    await tester.tap(agirBtn);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Ben'), findsOneWidget);

    // PC: Boşluk (Space) tuşuna basıldığında döngü tetiklenip Ekran 2'ye geçmeli
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(TacticalScreenTwo), findsOneWidget);
    expect(find.descendant(of: find.byType(TacticalScreenTwo), matching: find.text('AĞIR TOP')), findsOneWidget);
    expect(find.text('Ben'), findsNothing);

    // PC: Escape (ESC) tuşuna basıldığında Ana Menü'ye dönmeli
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Ana Menü tekrar görünür olmalı
    expect(find.text('AĞIR TOP'), findsWidgets);
    expect(find.byType(AnaMenuEkrani), findsOneWidget);
  });

  testWidgets('Agir Top responsive test (small screen and widescreen without overflow)', (WidgetTester tester) async {
    // 1. Küçük mobil ekran simülasyonu
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AgirTopApp());
    await tester.pump(const Duration(milliseconds: 100));

    final agirBtn = find.widgetWithText(ValorantMenuButton, 'Ağır Top'.toUpperCase());
    await tester.tap(agirBtn);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Ben'), findsOneWidget);

    // 2. Widescreen PC 1080p simülasyonu
    tester.view.physicalSize = const Size(1920, 1080);
    await tester.pump();
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final deviceContainer = find.byType(TacticalDeviceContainer);
    await tester.tap(deviceContainer);
    await tester.pump();
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(TacticalScreenTwo), findsOneWidget);
  });

  testWidgets('Agir Top rapid tap stress test (30 consecutive fast taps)', (WidgetTester tester) async {
    await tester.pumpWidget(const AgirTopApp());
    await tester.pump(const Duration(milliseconds: 100));

    final agirBtn = find.widgetWithText(ValorantMenuButton, 'Ağır Top'.toUpperCase());
    await tester.tap(agirBtn);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final deviceContainer = find.byType(TacticalDeviceContainer);
    // 31 kez çok hızlı (16ms aralıklarla) ardışık tıklama yapılır
    for (int i = 0; i < 31; i++) {
      await tester.tap(deviceContainer);
      await tester.pump(const Duration(milliseconds: 16));
    }

    // Geçiş animasyonunun tamamlanması beklenir
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 31 (tek sayı) tıklama sonrası Ekran 2 ("AĞIR TOP") temiz şekilde görünmelidir
    expect(find.byType(TacticalScreenTwo), findsOneWidget);
    expect(find.text('Ben'), findsNothing);
  });

  testWidgets('Phone settings popup: change agent, change name (max 20 chars), and reset to default', (WidgetTester tester) async {
    await tester.pumpWidget(const AgirTopApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Ağır Top ekranına gir
    final agirBtn = find.widgetWithText(ValorantMenuButton, 'Ağır Top'.toUpperCase());
    await tester.tap(agirBtn);
    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Sağ üstteki "TELEFON AYARLARI" butonuna tıkla
    final settingsBtn = find.text('TELEFON AYARLARI');
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Pop-up içindeki 3 seçenek görünmeli
    expect(find.text('Ajanı Değiştir'), findsOneWidget);
    expect(find.text('İsim Değiştir'), findsOneWidget);
    expect(find.text('Varsayılana Geri Dön'), findsOneWidget);

    // 1. Ajanı Değiştir -> JETT seç
    await tester.tap(find.text('Ajanı Değiştir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('JETT'));
    await tester.pump();
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.widget<TacticalScreenOne>(find.byType(TacticalScreenOne)).agentName, 'Jett');

    // 2. İsim Değiştir -> 20 karakter sınırı testi
    await tester.tap(settingsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('İsim Değiştir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 25 karakter giriyoruz; 20 karaktere kırpılmalı
    await tester.enterText(find.byType(TextField), '1234567890123456789012345');
    await tester.pump();
    await tester.tap(find.text('KAYDET'));
    await tester.pump();
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('12345678901234567890'), findsOneWidget);
    expect(find.text('Ben'), findsNothing);

    // 3. Varsayılana Geri Dön -> Tekrar "Ben" ve Brimstone
    await tester.tap(settingsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Varsayılana Geri Dön'));
    await tester.pump();
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Ben'), findsOneWidget);
    expect(tester.widget<TacticalScreenOne>(find.byType(TacticalScreenOne)).agentName, 'Brimstone');
  });
}
