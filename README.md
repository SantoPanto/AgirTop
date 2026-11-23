# Ağır Top (`AgırTop Ver0.1`)

**Ağır Top**, **Valorant** oyununun taktiksel arayüz (HUD) tasarım dilinden ve özellikle **Brimstone**'un oyun içi taktiksel telefonundan ilham alınarak **Flutter** ile geliştirilmiş çok platformlu (Mobil & PC) bir eğlence ve arayüz simülasyonu uygulamasıdır.

---

## Özellikler

### 1. Taktiksel Ana Menü (`AnaMenuEkrani`)
- **Valorant Estetiği:** Koyu gece mavisi arka plan (`#0F1923`), taktiksel arka plan grid dokusu ve özel kesik köşeli (`ChamferClipper` / `ChamferBorderPainter`) butonlar.
- **Butonlar:**
  - **Hafif Top** & **Orta Top:** Tıklandığında özel Valorant temalı `SnackBar` ile `"Şu anlık aktif değil"` bildirimi gösterir.
  - **Ağır Top:** Taktiksel telefon ekranına (`TelefonEkrani`) geçiş yapar.

### 2. Birebir Valorant Telefon Arayüzü (`TelefonEkrani`)
- **Özel Poligon Gövde & Ekran:** Dikdörtgen yerine Brimstone'un cihazına birebir benzeyen kesik omuzlu, üst orta çentikli (notch), V-tabanlı kalkan formunda gövde (`ValorantPhoneBodyClipper` & `_ValorantPhoneShellPainter`) ve ekranın hemen altında yer alan ikonik **sarı ters üçgen** detayı.
- **Sonsuz Ekran Döngüsü (Zero Stack Bloat):** `Navigator` kullanılmadan tek bir `StatefulWidget` içinde `_isFirstScreen` durumu ile **Ön Sayfa $\leftrightarrow$ Arka Sayfa** arasında hızlı `AnimatedSwitcher` geçişi sağlanır.
- **Ekran 1 (Ön Sayfa):**
  - Üst durum çubuğu (Sinyal, Wi-Fi ve Batarya göstergeleri).
  - Seçili Valorant ajanının stüdyo tarzı portresi (Varsayılan: **Brimstone**).
  - İsim bandı (Varsayılan: **"Ben"**, ayarlardan özelleştirilebilir).
  - `00` sayacı ve **120 FPS çift sinüs ses dalgası** (`CustomPaint` + `RepaintBoundary`).
- **Ekran 2 (Arka Sayfa):**
  - **Celestial_Card** oyuncu kartı (`assets/images/celestial_card.jpg`).
  - **"AĞIR TOP"** oyuncu ünvanı bandı.
  - Sağ kenar seviye çubukları, ses dalgası ve paralelkenar durum göstergeleri.

### 3. Telefon Ayarları Menüsü
Sağ üst köşedeki **TELEFON AYARLARI** butonuna tıklandığında 3 seçenekli taktiksel pop-up açılır:
1. **Ajanı Değiştir:** **26 Valorant ajanının** tamamı (Brimstone, Jett, Reyna, Sage, Sova, Omen, Phoenix, Viper, Cypher, Breach, Killjoy, Raze, Skye, Yoru, Astra, KAY/O, Chamber, Neon, Fade, Harbor, Gekko, Deadlock, Iso, Clove, Vyse, Tejo) kendi yüksek kaliteli portreleri, rolleri ve renk kodlarıyla listelenir. Seçilen ajan anında telefonun 1. ekranına uygulanır.
2. **İsim Değiştir:** Telefonun 1. ekranındaki `"Ben"` yazısını değiştirmek için **20 karakter sınırına** sahip (`maxLength: 20` + taşma korumalı `FittedBox`) metin giriş penceresi açılır.
3. **Varsayılana Geri Dön:** Ajanı tekrar **Brimstone**, ismi ise **"Ben"** olarak sıfırlar.

### 4. Ses, Titreşim ve Yüksek Performans
- **Gecikmesiz Ses & Titreşim:** Her dokunuş/tıklamada `HapticFeedback.lightImpact()` ve `audioplayers` (`PlayerMode.lowLatency`) ile `assets/sounds/transition.wav` çalınır.
- **Kasma Koruması (Anti-Jank):**
  - Çok hızlı ardışık tıklamalarda platform kanalının boğulmaması için ses ve titreşim çağrılarında **80ms throttle** ve `_isAudioBusy` kilidi bulunur.
  - Statik telefon gövdesi, arka planlar, ses dalgası (`CustomPaint(repaint: _controller)`) ve ekranlar `RepaintBoundary` ile izole edilmiştir; animasyonlar **sıfır widget rebuild** ile çalışır.

### 5. Çapraz Platform Desteği (Mobil & PC)
- **Mobil (Android & iOS):** Tam ekran (`SystemUiMode.immersiveSticky`), dikey yön kilidi, güvenli çentik/ekran boşlukları (`MediaQuery.paddingOf`), dokunma ve titreşim desteği.
- **PC / Masaüstü (Windows, macOS, Linux, Web):**
  - Fare imleci (`SystemMouseCursors.click`) ve buton hover animasyonları.
  - Klavye kısayolları: `Space` / `Enter` ile telefon ekranını değiştirme, `Escape (ESC)` ile ana menüye dönme.
  - Her pencere boyutuna (`360x640` – `1920x1080+`) uyum sağlayan `FittedBox` tabanlı responsive ölçeklendirme.

---

## Kurulum ve Çalıştırma

### Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.x`)
- Dart SDK (`^3.12.2`)

### Adımlar

```bash
# 1. Repoyu klonlayın
git clone https://github.com/SantoPanto/AgirTop.git
cd AgirTop

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Uygulamayı çalıştırın (Mobil cihaz veya Windows PC)
flutter run
# veya Windows için:
flutter run -d windows
```

---

## Test ve Doğrulama

Projede navigasyon, PC klavye kısayolları, responsive layout, hızlı tıklama stres testi (31 ardışık tıklama) ve Telefon Ayarları akışlarını doğrulayan otomatik widget testleri yer almaktadır:

```bash
# Statik kod analizi
dart analyze lib/main.dart test/widget_test.dart

# Widget ve stres testlerini çalıştırma
flutter test test/widget_test.dart
```

---

## Proje Yapısı

```text
AgirTop/
├── assets/
│   ├── images/
│   │   ├── brimstone_portrait.jpg
│   │   ├── celestial_card.jpg
│   │   └── agents/          # 25 Valorant ajanının yüksek kaliteli portreleri
│   └── sounds/
│       └── transition.wav   # Düşük gecikmeli geçiş ses efekti
├── lib/
│   └── main.dart            # Uygulama mimarisi, tema, özel clipper/painter ve ekranlar
├── test/
│   └── widget_test.dart     # Otomatik UI, klavye, responsive ve stres testleri
└── pubspec.yaml             # Paketler ve asset tanımları
```

---

**By SantoPanto**
