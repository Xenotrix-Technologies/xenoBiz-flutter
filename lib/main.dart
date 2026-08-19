import 'package:flutter/material.dart';
import 'application/app.dart';
import 'application/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection & Hive local storage
  await configureDependencies();

  runApp(const XenoBizApp());
}
