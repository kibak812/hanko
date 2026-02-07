import 'package:mocktail/mocktail.dart';
import 'package:hanko_hanko/data/repositories/project_repository.dart';
import 'package:hanko_hanko/data/datasources/local_storage.dart';
import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/project.dart';
import 'package:hanko_hanko/data/models/app_settings.dart';
import 'package:hanko_hanko/domain/services/ad_service.dart';
import 'package:hanko_hanko/presentation/providers/app_providers.dart';

// ============ Mock 클래스 ============

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAdService extends Mock implements AdService {}

class MockInterstitialAdController extends Mock
    implements InterstitialAdController {}

// ============ Fallback 등록 ============

void registerFallbacks() {
  registerFallbackValue(Project(id: 0, name: 'fallback'));
  registerFallbackValue(Counter(id: 0, label: 'fallback'));
  registerFallbackValue(AppSettings());
}
