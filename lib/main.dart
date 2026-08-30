import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  try {
    await NotificationService.init();
  } catch (_) {
    // Ha az inicializálás nem sikerül háttérben, az app ettől még indul
  }
  await ThemeService().init();

  runApp(const DagiFitnessApp());
}

class DagiFitnessApp extends StatelessWidget {
  const DagiFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Dagi App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF07101B),
            colorScheme: ColorScheme.dark(
              primary: ThemeService().primaryColor,
              secondary: ThemeService().secondaryColor,
              surface: ThemeService().cardColor,
            ),
            useMaterial3: true,
          ),
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}