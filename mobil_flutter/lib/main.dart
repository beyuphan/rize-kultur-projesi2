import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobil_flutter/common/theme/app_themes.dart';
import 'package:mobil_flutter/presentation/features/home/widgets/auth_yonlendirici.dart';
import 'package:mobil_flutter/l10n/app_localizations.dart';
import 'dart:io';





// UYGULAMANIN GENEL DURUMUNU YÖNETEN PROVIDER'LAR
final themeProvider = StateProvider<AppTheme>((ref) => AppTheme.firtinaYesili);
final localeProvider = StateProvider<Locale>((ref) => const Locale('tr'));

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// ===== KODUN DOĞRU HALİ =====
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
  runApp(const ProviderScope(child: RizeKulturProjesi()));
}

class RizeKulturProjesi extends ConsumerWidget {
  const RizeKulturProjesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rize Kültür Projesi',

      // SİZİN MEVCUT L10N AYARLARINIZ OLDUĞU GİBİ KORUNUYOR
      theme: appThemeData[currentTheme],
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      home: const AuthYonlendirici(),
    );
  }
}
