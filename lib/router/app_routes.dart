/// 앱 라우트 경로 상수
///
/// `GoRouter` 설정(`app_router.dart`)과 화면 전환에서 공통으로 사용됩니다.
/// 라우팅 설정 파일이 화면을 import 하므로, 순환 import 방지를 위해
/// 경로 상수만 별도 파일로 분리합니다.
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String tutorial = '/tutorial';
  static const String counter = '/';
  static const String projects = '/projects';
  static const String projectSettings = '/projects/settings';
  static const String newProject = '/projects/new';
  static const String settings = '/settings';
  static const String memos = '/memos';
}
