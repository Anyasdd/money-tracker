import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/balance_bloc.dart';
import 'repositories/balance_repository.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        // Основные цвета
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F70)),

        // Фон экранов
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),

        // Верхняя панель
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8FB),
          foregroundColor: Color(0xFF172B29),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),

        // Карточки
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        // Поля ввода
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),

        // Кнопки сохранения
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF087F70),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      home: BlocProvider(
        create: (context) =>
            BalanceBloc(BalanceRepository())..add(BalanceRequested()),

        child: const HomeScreen(),
      ),
    );
  }
}
