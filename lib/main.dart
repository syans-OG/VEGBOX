import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'auth_page.dart';
import 'core/di/injection.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Uncaught Flutter error',
      name: 'VegBox',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      'Uncaught async error',
      name: 'VegBox',
      error: error,
      stackTrace: stack,
    );
    return true;
  };
  setupLocator();
  runApp(const VegBoxApp());
}

class VegBoxApp extends StatelessWidget {
  const VegBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VegBox',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthPage(),
    );
  }
}
