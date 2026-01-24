import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/migration_utils.dart';
import 'data/datasources/objectbox_database.dart';
import 'domain/services/ad_service.dart';
import 'domain/services/premium_service.dart';
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

  // 데이터 마이그레이션 실행
  await MigrationUtils.runMigrationIfNeeded(sharedPreferences, objectBoxDatabase);

  // AdService 초기화
  final adService = AdService();
  await adService.initialize();

  // PremiumService 초기화
  final premiumService = PremiumService();
  await premiumService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        objectBoxDatabaseProvider.overrideWithValue(objectBoxDatabase),
        adServiceProvider.overrideWithValue(adService),
        premiumServiceProvider.overrideWithValue(premiumService),
      ],
      child: const HankoHankoApp(),
    ),
  );
}
