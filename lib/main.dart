import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitJournalApp());
}

class FitJournalApp extends StatefulWidget {
  const FitJournalApp({super.key});

  @override
  State<FitJournalApp> createState() => _FitJournalAppState();
}

class _FitJournalAppState extends State<FitJournalApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      appState: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'FitJournal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: _appState.isLoggedIn
                ? const MainNavigationScreen()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
