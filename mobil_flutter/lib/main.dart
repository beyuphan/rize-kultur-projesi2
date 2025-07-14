import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
// YENİ YÖNLENDİRİCİ WIDGET'INI IMPORT EDİYORUZ
import 'package:mobil_flutter/presentation/widgets/auth_yonlendirici.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';

// UYGULAMANIN GENEL DURUMUNU YÖNETEN PROVIDER'LAR
final themeProvider = StateProvider<AppTheme>((ref) => AppTheme.firtinaYesili);
final localeProvider = StateProvider<Locale>((ref) => const Locale('tr'));

void main() {
  // Uygulamayı, tüm widget'ların provider'lara erişebilmesi için ProviderScope ile sarmalıyoruz.
  runApp(const ProviderScope(child: RizeKulturProjesi()));
}

class RizeKulturProjesi extends ConsumerWidget {
  const RizeKulturProjesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mevcut tema ve dil durumunu dinliyoruz.
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rize Kültür Projesi',

      // Tema ve Dil Konfigürasyonu
      theme: appThemeData[currentTheme],
      locale: currentLocale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // DEĞİŞİKLİK: Uygulama artık doğrudan ana ekrana değil,
      // kullanıcının giriş durumunu kontrol eden AuthYonlendirici'ye gidiyor.
      home: const AuthYonlendirici(),
    );
  }
}
