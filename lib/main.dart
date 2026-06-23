import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/room_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0E17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const OtakuWallsApp());
}

class OtakuWallsApp extends StatelessWidget {
  const OtakuWallsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtakuWalls',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        primaryColor: const Color(0xFFE53170),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53170),
          secondary: Color(0xFFFF8906),
          surface: Color(0xFF0F0E17),
        ),
        useMaterial3: true,
      ),
      home: const RoomScreen(),
    );
  }
}
