import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/objectbox_database.dart';
import 'presentation/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  // ObjectBox 데이터베이스 초기화
  final objectBoxDatabase = await ObjectBoxDatabase.create();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        objectBoxDatabaseProvider.overrideWithValue(objectBoxDatabase),
      ],
      child: const HankoHankoApp(),
    ),
  );
}
