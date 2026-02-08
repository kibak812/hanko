import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/migration_utils.dart';
import 'data/datasources/objectbox_database.dart';
import 'domain/services/ad_service.dart';
import 'presentation/providers/app_providers.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}');
      debugPrint('${details.stack}');
    };

    // 세로 모드 고정
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    try {
      // SharedPreferences 초기화
      final sharedPreferences = await SharedPreferences.getInstance();

      // ObjectBox 데이터베이스 초기화
      final objectBoxDatabase = await ObjectBoxDatabase.create();

      // 데이터 마이그레이션 실행
      await MigrationUtils.runMigrationIfNeeded(sharedPreferences, objectBoxDatabase);

      // AdService 생성 (초기화는 앱 실행 후 비동기로)
      final adService = AdService();

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            objectBoxDatabaseProvider.overrideWithValue(objectBoxDatabase),
            adServiceProvider.overrideWithValue(adService),
          ],
          child: const HankoHankoApp(),
        ),
      );

      // 광고 SDK 초기화 (앱 실행 후 비동기, 실패해도 앱 동작에 영향 없음)
      unawaited(adService.initialize().catchError((e) {
        debugPrint('AdService initialization failed: $e');
      }));
    } catch (e, stack) {
      debugPrint('Initialization error: $e');
      debugPrint('$stack');
      final message = kDebugMode
          ? '앱 초기화에 실패했습니다.\n앱을 재시작해주세요.\n\n$e'
          : '앱 초기화에 실패했습니다.\n앱을 재시작해주세요.';
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(message, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('$stack');
  });
}
