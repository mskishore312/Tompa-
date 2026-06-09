import 'package:flutter/material.dart';

import 'screens/company_screen.dart';

void main() {
  runApp(const TompaApp());
}

class TompaApp extends StatelessWidget {
  const TompaApp({super.key});

  static const _green = Color(0xFF126245);
  static const _yellow = Color(0xFFFFC400);
  static const _cream = Color(0xFFE3F0DF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TOM-PA',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        scaffoldBackgroundColor: _green,
        colorScheme: ColorScheme.fromSeed(seedColor: _green, primary: _green, secondary: _yellow, surface: _cream),
        appBarTheme: const AppBarTheme(backgroundColor: _green, foregroundColor: Colors.white, centerTitle: true, titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        cardTheme: CardThemeData(color: _cream, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2), side: const BorderSide(color: Colors.white, width: 1.2))),
        inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: _cream, border: OutlineInputBorder(), labelStyle: TextStyle(color: _green, fontWeight: FontWeight.bold)),
        listTileTheme: const ListTileThemeData(tileColor: _cream, iconColor: _green, textColor: _green),
        filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: _yellow, foregroundColor: _green, textStyle: const TextStyle(fontWeight: FontWeight.w900))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: _cream, foregroundColor: _green, textStyle: const TextStyle(fontWeight: FontWeight.w900))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: _yellow, side: const BorderSide(color: _yellow, width: 1.5))),
        tabBarTheme: const TabBarThemeData(labelColor: _yellow, unselectedLabelColor: Colors.white, indicatorColor: _yellow),
      ),
      home: const TompaHomeScreen(),
    );
  }
}

class TompaHomeScreen extends StatelessWidget {
  const TompaHomeScreen({super.key});

  static const _green = Color(0xFF126245);
  static const _yellow = Color(0xFFFFC400);
  static const _red = Color(0xFFE92B2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      body: SafeArea(
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyScreen())),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'T O M - P A',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _yellow, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 7),
                  ),
                  const SizedBox(height: 26),
                  const _TallyOnPanel(),
                  const SizedBox(height: 8),
                  const _MobileLogo(),
                  const SizedBox(height: 36),
                  const Text(
                    'P E R S O N A L   A C C O U N T A N T',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 4),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Version - 9',
                    style: TextStyle(color: _yellow, fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 34),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _yellow, foregroundColor: _green, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyScreen())),
                    child: const Text('ENTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
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

class _TallyOnPanel extends StatelessWidget {
  const _TallyOnPanel();

  static const _green = Color(0xFF126245);
  static const _yellow = Color(0xFFFFC400);
  static const _red = Color(0xFFE92B2B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFE3F0DF)),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Tally', style: TextStyle(color: _red, fontSize: 58, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text('Tally', style: TextStyle(color: Color(0xFF212121), fontSize: 58, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _red, border: Border.all(color: _yellow, width: 8)),
            alignment: Alignment.center,
            child: const Text('ON', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _MobileLogo extends StatelessWidget {
  const _MobileLogo();

  static const _green = Color(0xFF126245);
  static const _yellow = Color(0xFFFFC400);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('M', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900, height: 0.95)),
        Container(
          width: 52,
          height: 72,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 4)),
          child: Column(
            children: [
              Container(width: 32, height: 44, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: _yellow, borderRadius: BorderRadius.circular(14))),
              const SizedBox(height: 4),
              Wrap(spacing: 3, runSpacing: 2, alignment: WrapAlignment.center, children: List.generate(9, (_) => const CircleAvatar(radius: 2.3, backgroundColor: Colors.white))),
            ],
          ),
        ),
        const Text('BILE', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900, height: 0.95)),
      ],
    );
  }
}
