import 'package:flutter/material.dart';
import 'core/di.dart';
import 'data/services/morse_audio_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  // Initialize Morse Audio Service
  await getIt<MorseAudioService>().init();
  runApp(const DecodeItApp());
}

class DecodeItApp extends StatelessWidget {
  const DecodeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decode It!',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
