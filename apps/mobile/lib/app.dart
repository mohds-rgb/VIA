import 'package:flutter/material.dart';
import 'core/localization/app_strings.dart';
import 'features/booking/data/demo_booking_repository.dart';
import 'features/booking/presentation/booking_page.dart';

class ViaApp extends StatefulWidget {
  const ViaApp({super.key});

  @override
  State<ViaApp> createState() => _ViaAppState();
}

class _ViaAppState extends State<ViaApp> {
  Locale locale = const Locale('en');
  final DemoBookingRepository demoRepository = DemoBookingRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIA',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [AppStringsDelegate()],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00D6A6),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6), elevation: 0),
      ),
      home: BookingPage(
        repository: demoRepository,
        onToggleLocale: () => setState(() {
          locale = locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
        }),
      ),
    );
  }
}
