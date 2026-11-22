import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

import 'features/presentation/screens/generator_screen.dart';

const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('zh'),
  Locale('hi'),
  Locale('ar'),
  Locale('tn'),
];

/// Flutter does not ship Material translations for Setswana. Keep the app's
/// selected locale as `tn`, while using English strings for framework widgets.
class TnMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const TnMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tn';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(TnMaterialLocalizationsDelegate old) => false;
}

class TnCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const TnCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tn';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(TnCupertinoLocalizationsDelegate old) => false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: appSupportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useFallbackTranslations: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isSetswana = context.locale.languageCode == 'tn';
    final appDelegates = context.localizationDelegates.where((delegate) {
      if (!isSetswana) return true;
      // These stock delegates reject `tn`; our fallback delegates below
      // load their English resources without changing Easy Localization's locale.
      return !identical(delegate, GlobalMaterialLocalizations.delegate) &&
          !identical(delegate, GlobalCupertinoLocalizations.delegate);
    }).toList();

    return MaterialApp(
      onGenerateTitle: (context) => 'random word generator'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        if (isSetswana) ...[
          const TnMaterialLocalizationsDelegate(),
          const TnCupertinoLocalizationsDelegate(),
        ],
        ...appDelegates,
      ],
      supportedLocales: appSupportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const GeneratorScreen(),
    );
  }
}
