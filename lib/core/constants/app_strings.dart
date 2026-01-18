/// 한코한코 앱 문자열 상수 (한국어)
class AppStrings {
  AppStrings._();

  // ============ 앱 정보 ============
  static const String appName = '한코한코';
  static const String appTagline = '뜨개질에만 집중하세요.\n카운팅은 제가 할게요';

  // ============ 온보딩 ============
  static const String welcomeTitle = '한코한코에 오신 것을 환영합니다!';
  static const String welcomeSubtitle = '뜨개질에만 집중하세요.\n카운팅은 제가 할게요';
  static const String startFirstProject = '첫 프로젝트 시작하기';
  static const String freeTrialNotice = '7일 프리미엄 무료 체험 중';

  // ============ 프로젝트 ============
  static const String newProject = '새 프로젝트';
  static const String projectName = '프로젝트 이름';
  static const String projectNameHint = '예: 첫 목도리';
  static const String targetRow = '목표 단수';
  static const String targetRowHint = '몇 줄 뜰 건가요?';
  static const String targetRowTip = '팁: 목도리는 보통 150-200단이에요';
  static const String startProject = '시작하기';
  static const String myProjects = '내 프로젝트';
  static const String noProjects = '아직 프로젝트가 없어요\n첫 프로젝트를 시작해보세요!';

  // ============ 카운터 ============
  static const String row = '단';
  static const String stitch = '코';
  static const String pattern = '반복';
  static const String reset = '리셋';
  static const String undo = '되돌리기';

  // ============ 메모 ============
  static const String addMemo = '메모 추가';
  static const String memoHint = '예: 코 줄이기 2코';
  static const String atRow = '단에서';
  static const String memo = '메모';
  static const String memos = '메모 목록';
  static const String editMemo = '메모 편집';
  static const String noMemos = '아직 메모가 없어요\n특정 단에 기억해야 할 내용을 추가해보세요';
  static const String rowNumber = '단 번호';
  static const String deleteMemoConfirm = '이 메모를 삭제할까요?';

  // ============ 진행률 ============
  static const String progress = '진행률';
  static const String completed = '완료';
  static const String inProgress = '진행 중';

  // ============ 음성 제어 ============
  static const String voiceListening = '듣고 있어요...';
  static const String voiceNotAvailable = '음성 인식을 사용할 수 없어요';
  static const String voiceLimitReached = '오늘 음성 사용 횟수를 다 썼어요';
  static const String voiceLimitTomorrow = '내일 다시 사용 가능해요';
  static const String watchAdForVoice = '광고 보고 추가하기';

  // ============ 프리미엄 ============
  static const String premium = '프리미엄';
  static const String premiumFeatures = '프리미엄 기능';
  static const String unlimitedProjects = '무제한 프로젝트';
  static const String unlimitedVoice = '무제한 음성 제어';
  static const String noAds = '광고 제거';
  static const String widget = '위젯 (잠금화면 카운트)';
  static const String cloudBackup = '클라우드 백업';
  static const String patternAutoReset = '패턴 반복 자동 리셋';
  static const String yearlyPrice = '₩9,900/년';
  static const String monthlyPrice = '₩1,500/월';
  static const String yearlyPricePerDay = '하루 ₩27, 커피 한 잔보다 저렴!';
  static const String startFreeTrial = '7일 무료 체험 시작';
  static const String restorePurchase = '구매 복원';

  // ============ 광고 ============
  static const String watchAdForMore = '광고 보고 추가하기';

  // ============ 제한 ============
  static const String projectLimitTitle = '프로젝트 2개까지 무료예요';
  static const String voiceLimitTitle = '음성 제어 3회/일';

  // ============ 축하 ============
  static const String congratulations = '축하합니다!';
  static const String milestoneReached = '단 달성!';
  static const String greatJob = '잘하고 있어요!';
  static const String projectCompleted = '프로젝트 완료!';

  // ============ 설정 ============
  static const String settings = '설정';
  static const String hapticFeedback = '햅틱 피드백';
  static const String voiceFeedback = '음성 피드백';
  static const String keepScreenOn = '화면 유지';
  static const String darkMode = '다크 모드';
  static const String about = '앱 정보';

  // ============ 일반 ============
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String delete = '삭제';
  static const String edit = '편집';
  static const String save = '저장';
  static const String later = '나중에';
  static const String today = '오늘';
  static const String yesterday = '어제';

  // ============ 에러 ============
  static const String error = '오류';
  static const String errorOccurred = '오류가 발생했어요';
  static const String tryAgain = '다시 시도해주세요';

  // ============ 보조 카운터 설정 ============
  static const String stitchCounterSettings = '코 카운터 설정';
  static const String patternCounterSettings = '패턴 카운터 설정';
  static const String targetStitch = '목표 코 수';
  static const String autoResetAt = '자동 리셋';
  static const String goalReached = '완료!';
  static const String resetAndContinue = '리셋하고 계속';
  static const String counterSettings = '카운터 설정';
  static const String removeCounter = '카운터 제거';
  static const String removeCounterConfirm = '이 카운터를 제거할까요? 현재 값은 사라집니다.';
  static const String customValue = '직접 입력';
  static const String stitchGoalTip = '목표에 도달하면 알려드려요';
  static const String patternResetTip = '설정한 횟수에 도달하면 자동으로 0으로 리셋';
  static const String patternAutoResetToast = '패턴 완료 → 리셋됨';
  static const String changeTarget = '목표 변경';
  static const String current = '현재';
  static const String none = '없음';

  // ============ 동적 보조 카운터 ============
  static const String repetitionType = '반복';
  static const String goalType = '횟수';
  static const String addSecondaryCounter = '보조 카운터 추가';
  static const String counterLabel = '카운터 이름';
  static const String selectCounterType = '유형 선택';
  static const String period = '주기';
  static const String goal = '목표';
  static const String everyNRows = '단마다';
  static const String totalNTimes = '총 N번';
  static const String secondaryCounterLimit = '무료 사용자는 보조 카운터를 2개까지 추가할 수 있어요';
  static const String editCounter = '카운터 편집';

  // ============ 타이머/작업 시간 ============
  static const String editSchedule = '일정 편집';
  static const String startDateLabel = '시작일';
  static const String completedDateLabel = '완료일 (선택)';
  static const String setDate = '설정하기';
  static const String completedDateInfo = '완료일을 설정하면 프로젝트가 완료 상태로 변경됩니다.';
  static const String resetWorkTime = '작업 시간 리셋';
  static const String resetWorkTimeConfirm = '누적 작업 시간을 0으로 리셋할까요?';
}
