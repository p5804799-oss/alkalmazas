import 'package:flutter/material.dart';
import 'screens/main_layout.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  runApp(const DagiApp());
}

class DagiApp extends StatelessWidget {
  const DagiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Dagi app',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: ThemeService().backgroundColor,
            primaryColor: ThemeService().primaryColor,
            appBarTheme: AppBarTheme(backgroundColor: ThemeService().backgroundColor),
          ),
          home: const MainLayout(),
        );
      }
    );
  }
}
