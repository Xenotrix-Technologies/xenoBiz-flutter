import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'application/app.dart';
import 'application/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Dependency Injection & Hive local storage
  await configureDependencies();

  // 2. Request & verify startup permissions: Camera, Storage, Photos
  await _requestStartupPermissions();

  runApp(const XenoBizApp());
}

Future<void> _requestStartupPermissions() async {
  try {
    await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.manageExternalStorage,
    ].request();
  } catch (_) {}
}

