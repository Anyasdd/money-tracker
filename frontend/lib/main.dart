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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),

      home: BlocProvider(
        create: (context) => BalanceBloc(
          BalanceRepository(),
        )..add(BalanceRequested()),

        child: const HomeScreen(),
      ),
    );
  }
}