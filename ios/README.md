# SimPo - Simple Pomodoro (iOS)

웹 버전(`../index.html`)과 같은 디자인의 SwiftUI 앱. iOS 17+, iPhone/iPad.

## Mac에서 빌드

```sh
brew install xcodegen
cd ios
sh fetch-fonts.sh      # Pretendard 폰트 받기
xcodegen               # SimPo.xcodeproj 생성
open SimPo.xcodeproj
```

Xcode에서 `SimPo` 타깃 → Signing & Capabilities → Team 선택 → 아이폰 연결 후 ▶︎ 실행.

## App Store 올리기 전에

1. [Apple Developer Program](https://developer.apple.com/programs/) 가입 (연 $99)
2. `project.yml`의 `com.example.simpo`를 본인 번들 ID로 바꾸고 `xcodegen` 다시 실행
3. [App Store Connect](https://appstoreconnect.apple.com)에서 새 앱 등록 (같은 번들 ID)
4. Xcode → Product → Archive → Distribute App → App Store Connect
5. App Store Connect에서 스크린샷, 설명, 개인정보 처리방침 URL 입력 후 심사 제출
   - 개인정보: 수집하는 데이터 없음 (`PrivacyInfo.xcprivacy` 포함됨)
   - 수출 규정: 암호화 사용 안 함 (`ITSAppUsesNonExemptEncryption = NO` 설정됨)

## 동작

- 종료 시간에 로컬 알림을 걸어둬서 화면이 꺼져 있어도 소리가 난다 (첫 시작 때 알림 권한 요청)
- 타이머 실행 중엔 화면 자동 잠금 해제
- 무음 모드면 소리 대신 진동만
