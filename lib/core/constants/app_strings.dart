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

  // ============ 프로젝트 ============
  static const String newProject = '새 프로젝트';
  static const String projectName = '프로젝트 이름';
  static const String projectNameHint = '예: 첫 목도리';
  static const String projectEdit = '프로젝트 편집';
  static const String enterProjectName = '프로젝트 이름을 입력해주세요';
  static const String secondaryCounters = '보조 카운터';
  static const String enterCounterName = '카운터 이름을 입력해주세요';
  static const String targetRow = '목표 단수';
  static const String targetRowHint = '몇 줄 뜰 건가요?';
  static const String targetRowTip = '팁: 목도리는 보통 150-200단이에요';
  static const String startProject = '시작하기';
  static const String myProjects = '내 프로젝트';
  static const String noProjects = '아직 프로젝트가 없어요\n첫 프로젝트를 시작해보세요!';
  static const String deleteProjectConfirm = '프로젝트를 삭제할까요?\n이 작업은 되돌릴 수 없습니다.';

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

  // ============ 광고 ============
  static const String watchAdForMore = '광고 보고 추가하기';


  // ============ 축하 ============
  static const String congratulations = '축하합니다!';
  static const String milestoneReached = '단 달성!';
  static const String greatJob = '잘하고 있어요!';
  static const String projectCompleted = '프로젝트 완료!';

  // ============ 설정 ============
  static const String settings = '설정';
  static const String hapticFeedback = '햅틱 피드백';
  static const String hapticFeedbackDesc = '탭할 때 진동 피드백';
  static const String voiceFeedback = '음성 피드백';
  static const String keepScreenOn = '화면 유지';
  static const String keepScreenOnDesc = '뜨개질하는 동안 화면이 꺼지지 않아요';
  static const String darkMode = '다크 모드';
  static const String about = '앱 정보';
  static const String feedbackSection = '피드백';
  static const String displaySection = '화면';
  static const String themeSection = '테마';
  static const String themeLight = '라이트';
  static const String themeDark = '다크';
  static const String themeSystem = '시스템';
  static const String helpSection = '도움말';
  static const String tutorialRewatchDesc = '롱프레스 기능 다시 배우기';
  static const String versionLoading = '버전 정보 로딩 중...';

  // ============ 일반 ============
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String delete = '삭제';
  static const String edit = '편집';
  static const String save = '저장';
  static const String later = '나중에';
  static const String today = '오늘';
  static const String yesterday = '어제';

  // ============ 일반 (추가) ============
  static const String remove = '제거';
  static const String add = '추가';
  static const String numberInput = '숫자 입력';
  static const String autoSaveHint = '배경을 탭하면 자동 저장됩니다';
  static const String label = '라벨';
  static const String projectNotFound = '프로젝트를 찾을 수 없어요';

  // ============ 에러 ============
  static const String error = '오류';
  static const String errorOccurred = '오류가 발생했어요';
  static const String tryAgain = '다시 시도해주세요';

  // ============ 튜토리얼 ============
  static const String tutorialTitle = '기능 둘러보기';
  static const String tutorialSubtitle = '1분이면 충분해요';
  static const String tutorialSkip = '건너뛰기';
  static const String tutorialNext = '다음';
  static const String tutorialDone = '완료';
  static const String tutorialTryIt = '직접 해보기';
  static const String tutorialRewatch = '튜토리얼 다시 보기';

  // 튜토리얼 Step 1: ProgressHeader
  static const String tutorialStep1Title = '프로젝트 편집';
  static const String tutorialStep1Description = '여기를 길게 누르면\n프로젝트명과 목표를 수정할 수 있어요';

  // 튜토리얼 Step 2: ProjectInfoBar
  static const String tutorialStep2Title = '날짜 편집';
  static const String tutorialStep2Description = '여기를 길게 누르면\n시작일과 완료일을 설정할 수 있어요';

  // 튜토리얼 Step 3: SecondaryCounter
  static const String tutorialStep3Title = '보조 카운터 편집';
  static const String tutorialStep3Description = '보조 카운터를 길게 누르면\n이름과 목표를 수정할 수 있어요';

  // 튜토리얼 Step 4: Timer
  static const String tutorialStep4Title = '작업 시간 리셋';
  static const String tutorialStep4Description = '타이머 버튼을 길게 누르면\n작업 시간을 리셋할 수 있어요';

  // 튜토리얼 Step 5: Voice Commands
  static const String tutorialStep5Title = '음성 명령';
  static const String tutorialStep5Description = '"다음", "이전"으로 카운터 조작\n"취소"로 되돌리기가 가능해요';

  // 튜토리얼 완료
  static const String tutorialCompleteTitle = '준비 완료!';
  static const String tutorialCompleteDescription = '주요 기능을 모두 알게 되셨어요\n이제 첫 프로젝트를 시작해볼까요?';

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

  // ============ 카운터 (추가) ============
  static const String stitchCounterSettingsTitle = '코 카운터 설정';
  static const String patternCounterSettingsTitle = '패턴 카운터 설정';
  static const String targetStitchCount = '목표 코 수';
  static const String autoReset = '자동 리셋';
  static const String goalCounterLabel = '횟수 카운터';
  static const String repetitionCounterLabel = '반복 카운터';
  static const String goalOptional = '목표 (선택)';
  static const String periodOptional = '주기 (선택)';
  static const String goalHintExample = '예: 10';
  static const String periodHintExample = '예: 4';
  static const String goalReachedMessage = '목표에 도달했어요. 계속하시겠어요?';

  /// 코 카운터 목표 완료 제목
  static String stitchGoalCompleted(int target) => '$target코 완료!';

  /// 패턴 자동 리셋 토스트
  static String patternAutoReset(int resetAt) => '패턴 $resetAt회 완료 → 리셋됨';

  /// 프로젝트 삭제 확인 (이름 포함)
  static String deleteProjectConfirmNamed(String name) =>
      '\'$name\' 프로젝트를 삭제할까요?\n이 작업은 되돌릴 수 없습니다.';

  /// 진행률 텍스트
  static String rowCompleted(int currentRow, int progressPercent) =>
      '$currentRow단 완료 ($progressPercent%)';

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
  static const String editCounter = '카운터 편집';

  // ============ 타이머/작업 시간 ============
  static const String editSchedule = '일정 편집';
  static const String startDateLabel = '시작일';
  static const String completedDateLabel = '완료일 (선택)';
  static const String setDate = '설정하기';
  static const String completedDateInfo = '완료일을 설정하면 프로젝트가 완료 상태로 변경됩니다.';
  static const String resetWorkTime = '작업 시간 리셋';
  static const String resetWorkTimeConfirm = '누적 작업 시간을 0으로 리셋할까요?';

  // ============ 데이터 관리 ============
  static const String dataManagementSection = '데이터 관리';
  static const String backupData = '데이터 백업';
  static const String backupDataDesc = '모든 프로젝트와 설정을 파일로 저장';
  static const String restoreData = '데이터 복원';
  static const String restoreDataDesc = '백업 파일에서 데이터를 복원';
  static const String backupSuccess = '백업 파일이 생성되었습니다.';
  static const String restoreSuccess = '데이터가 복원되었습니다.';
  static const String restoreConfirmTitle = '데이터를 복원할까요?';
  static const String restoreConfirmBody =
      '현재 데이터가 모두 삭제되고 백업 데이터로 대체됩니다.\n이 작업은 되돌릴 수 없습니다.';
  static const String invalidBackupFile = '유효하지 않은 백업 파일입니다.';
  static const String backupVersionTooNew =
      '이 백업은 더 새로운 버전의 앱에서 생성되었습니다.\n앱을 업데이트해주세요.';
  static const String backupFileTooLarge = '백업 파일이 너무 큽니다. (최대 10MB)';

  static String restoreConfirmDetail(int count, String date) =>
      '이 백업에는 $count개의 프로젝트가 포함되어 있습니다.\n($date에 생성됨)';
}
