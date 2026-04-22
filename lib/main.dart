import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:novastore_flutter/services/api_service.dart';
import 'pages/login_screen.dart';
import 'pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _hasValidToken() async {
    developer.log('Token kontrolü başlatılıyor', name: 'APP_START', level: 800);

    final token = await ApiService.getToken();
    final hasToken = token != null && token.isNotEmpty;

    if (hasToken) {
      developer.log(
        'Geçerli token bulundu, HomeScreen\'e yönlendiriliyor',
        name: 'APP_START',
        level: 800,
      );
    } else {
      developer.log(
        'Token bulunamadı, LoginScreen\'e yönlendiriliyor',
        name: 'APP_START',
        level: 800,
      );
    }

    return hasToken;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myTheme,
      debugShowCheckedModeBanner: bool.fromEnvironment(
        'debugShowCheckedModeBanner',
      ),
      home: FutureBuilder<bool>(
        future: _hasValidToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Uygulama yüklenirken splash screen göster
            return Scaffold(
              backgroundColor: colorScheme.primary,
              body: Center(
                child: CircularProgressIndicator(color: colorScheme.onPrimary),
              ),
            );
          }

          // Token varsa HomeScreen'e, yoksa LoginScreen'e git
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
