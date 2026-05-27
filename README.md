# LinguaMastery App

[English](#english) | [繁體中文](#繁體中文)

> **下載 APK**：[GitHub Releases](https://github.com/Raito66/lingua-mastery-app/releases)

---

## 繁體中文

### 專案簡介

LinguaMastery 行動應用程式，使用 Flutter 開發，支援 Android 平台。提供使用者登入、單字書管理、閃卡學習、選擇題測驗與 SRS 複習等功能。

### 技術棧

- **框架**：Flutter 3
- **語言**：Dart
- **HTTP**：http 套件
- **本地儲存**：shared_preferences
- **TTS**：flutter_tts
- **目標平台**：Android
- **後端 API**：https://lingua-mastery-api.onrender.com

### 主要功能

- 使用者註冊 / 登入（Enter 鍵切換欄位）
- Email 驗證流程
- 忘記密碼 / 重設密碼（Token 手動輸入）
- 單字書管理（⋮ 選單編輯 / 刪除）
- 單字列表（含熟練度進度條 + 各等級統計 + 即時搜尋 + 熟練度篩選）
- 閃卡學習模式（含自動朗讀 TTS + 🔊 手動重播 + 熟練度 badge）
- 選擇題測驗（四選一，答後顯示綠✓紅✗）
- 間隔重複複習（SRS）
- 學習結果統計（全局 + 每本書獨立練習次數與準確率）
- 每日學習 Streak（🔥 連續天數 + 今日練習數）
- 會員專區（顯示名稱編輯、更改密碼、關於頁）

### 安裝（手機直接使用）

1. 前往 [GitHub Releases](https://github.com/Raito66/lingua-mastery-app/releases)
2. 下載最新版 `LinguaMastery-vX.X.X.apk`
3. 手機開啟檔案，允許「安裝未知來源應用程式」
4. 安裝完成即可使用

### 本地開發

#### 前置條件

- Flutter 3.x SDK
- Android Studio（含 Android 模擬器）

#### 安裝與啟動

```bash
flutter pub get
flutter run
```

> 注意：App 預設連線至 Render 正式環境（`https://lingua-mastery-api.onrender.com`）。
> 本地開發若需連線至本機後端，請修改 `lib/services/api_service.dart` 的 `baseUrl`。

### 專案結構

```
lib/
├── main.dart
├── models/
│   ├── word.dart
│   └── word_book.dart
├── services/
│   ├── api_service.dart      # HTTP 基礎設定、401 自動登出
│   ├── auth_service.dart     # 驗證相關 API
│   └── word_service.dart     # 單字、複習、統計 API
├── widgets/
│   └── flashcard_widget.dart # 閃卡元件（含熟練度 badge）
└── screens/
    ├── login_screen.dart
    ├── verify_email_screen.dart
    ├── forgot_password_screen.dart
    ├── reset_password_screen.dart
    ├── home_screen.dart
    ├── word_list_screen.dart
    ├── flashcard_screen.dart
    ├── quiz_screen.dart
    ├── review_screen.dart
    └── result_screen.dart
```

---

## English

### Overview

Mobile application for LinguaMastery, a gamified language learning platform. Built with Flutter, targeting Android.

> **Download APK**: [GitHub Releases](https://github.com/Raito66/lingua-mastery-app/releases)

### Tech Stack

- **Framework**: Flutter 3
- **Language**: Dart
- **HTTP**: http package
- **Local Storage**: shared_preferences
- **TTS**: flutter_tts
- **Platform**: Android
- **Backend API**: https://lingua-mastery-api.onrender.com

### Features

- User registration / login (Enter key field navigation)
- Email verification flow
- Forgot password / password reset (manual token entry)
- Vocabulary book management (⋮ menu for edit / delete)
- Word list screen (proficiency progress bar + level stats)
- Flashcard study mode (auto TTS + 🔊 manual replay + proficiency badge)
- Multiple choice quiz (4 options, correct ✓ / wrong ✗ feedback)
- Spaced repetition review (SRS)
- Learning result statistics (global + per-book study count and accuracy)
- Daily learning streak (🔥 consecutive days + today's count)
- Member profile (edit display name, change password, About page)

### Install (on your phone)

1. Go to [GitHub Releases](https://github.com/Raito66/lingua-mastery-app/releases)
2. Download the latest `LinguaMastery-vX.X.X.apk`
3. Open the file on your phone and allow "Install from unknown sources"
4. Done — open the app and start learning

### Local Development

#### Prerequisites

- Flutter 3.x SDK
- Android Studio (with Android emulator)

#### Install & Run

```bash
flutter pub get
flutter run
```

> The app connects to the Render production API by default.
> For local backend, update `baseUrl` in `lib/services/api_service.dart`.

### Project Structure

```
lib/
├── main.dart
├── models/
│   ├── word.dart
│   └── word_book.dart
├── services/
│   ├── api_service.dart      # HTTP base config, 401 auto-logout
│   ├── auth_service.dart     # Auth-related API calls
│   └── word_service.dart     # Word, review, stats API calls
├── widgets/
│   └── flashcard_widget.dart # Flashcard widget with proficiency badge
└── screens/
    ├── login_screen.dart
    ├── verify_email_screen.dart
    ├── forgot_password_screen.dart
    ├── reset_password_screen.dart
    ├── home_screen.dart
    ├── word_list_screen.dart
    ├── flashcard_screen.dart
    ├── quiz_screen.dart
    ├── review_screen.dart
    └── result_screen.dart
```

---

## 更新日誌 / Changelog

### v1.0.5 (2026-05-27)
- 新增：單字列表顯示每本書獨立的練習次數與答題準確率

### v1.0.4 (2026-05-25)
- 修正：auth_service 錯誤回應改用 isNotEmpty 保護 jsonDecode，防止伺服器回傳非 JSON body 時崩潰

### v1.0.3 (2026-05-25)
- 新增：單字列表支援即時搜尋（單字 / 翻譯 / 讀音）與熟練度篩選

### v1.0.2 (2026-05-22)
- 修正：空單字本現在也顯示「單字」按鈕，可正常進入列表新增單字

### v1.0.1 (2026-05-22)
- 新增：註冊模式加入顯示名稱欄位
- 修正：重設密碼前端驗證改為 8 碼+英數

### v1.0.0 (2026-05-22)
- 新增：會員專區畫面 — 頭像圓圈（姓名縮寫）、顯示名稱、編輯名稱、更改密碼、關於頁
- 新增：首頁 AppBar 以頭像圓圈按鈕進入會員專區

### v0.9.8 (2026-05-22)
- 修正：閃卡按鈕加入防連點機制，避免快速雙擊送出兩次結果
- 修正：_finish() 補 mounted check，避免 Widget 已銷毀時仍導頁
- 修正：study 模式 submitResult 補 catchError，網路失敗不崩潰
- 修正：quiz 進度條改 (index+1)/total，第一題不再顯示 0%
- 修正：quiz 結果對話框前移除多餘的 loading 狀態閃爍
- 修正：api_service _handleUnauthorized 改為 Future<void>，flag 在 finally 重置
- 修正：getReviewStats 的 as int 強轉改為 (as num).toInt() 防 ClassCastException

### v0.9.7 (2026-05-21)
- 新增：單字列表頁可直接新增單字（FAB `+` 按鈕）
- 新增：單字列表每個項目可編輯單字資訊（⋯ 選單 → 編輯）
- 新增：單字列表每個項目可刪除單字（⋯ 選單 → 刪除，含確認對話框）
- 修正：編輯/刪除後確保 Widget 仍掛載才刷新列表
- 修正：API 回傳空 body 時不再拋出 JSON 解析例外

### v0.9.6 (2026-05-21)
- 新增：SRS 複習預覽畫面（顯示今日到期與新單字數量，再進入閃卡）
- 新增：獨立學習統計頁面（連續天數、今日練習、總學習次數、正確率）

### v0.9.5 (2026-05-21)
- 新增：密碼欄位眼睛圖示，可切換顯示/隱藏密碼
- 新增：註冊時前端驗證密碼強度（8碼以上、含英文與數字）

### v0.9.4 (2026-05-21)
- 修正：密碼欄位不再裁切頭尾空格
- 修正：Email 或密碼空白時顯示提示，不送出請求
- 修正：首頁載入失敗時顯示錯誤訊息與重試按鈕
- 修正：防止登出流程被並發重複觸發

### v0.9.3 (2026-05-21)
- 修正：登入失敗時 loading 按鈕卡住不恢復
- 修正：首頁資料載入失敗時轉圈卡死
- 改善：所有 HTTP 請求加上 30 秒 timeout

### v0.9.2 (2026-05-21)
- 修正：補上 Android INTERNET 權限，release APK 終於能連線後端

### v0.9.1 (2026-05-21)
- 修正：密碼欄位按鍵盤完成鍵（Done）在登入與註冊模式皆可送出

### v0.9.0 (2026-05-21)
- 修正：註冊模式下密碼欄位按 Enter 會誤觸提交
- 修正：網路錯誤時 loading 按鈕卡住不恢復

### v0.8.0 (2026-05-19)
- API 改連線至 Render 正式環境
- APK 發布至 GitHub Releases，可直接下載安裝

### v0.7.0 (2026-05-19)
- 新增單字列表畫面（熟練度進度條 + 各等級數量統計）
- 閃卡正面顯示熟練度 badge
- 書卡改為四個等寬按鈕（單字 / 閃卡 / 選擇題 / 複習）
- ⋮ 選單取代長按，操作更直覺
- 登入頁 Enter 鍵直接觸發登入

### v0.6.0 (2026-05-19)
- 新增選擇題畫面（答後顯示綠✓紅✗）
- 書卡新增「選擇題」按鈕（白色低調），「測驗」改名「閃卡」
- 登入頁 input 文字改為黑色

### v0.5.0 (2026-05-19)
- 首頁新增 🔥 Streak 顯示（連續天數 + 今日練習數）

### v0.4.1 (2026-05-16)
- 新增單字本新增功能（右下角 FAB）
- 長按書卡可刪除單字本（附確認對話框）

### v0.4.0 (2026-05-16)
- 新增 TTS 發音功能（閃卡自動朗讀 + 🔊 手動重播按鈕）
- 修正首次播放聲音模糊問題（TTS 引擎預熱）
- 語速調整至 0.7，適合語言學習節奏

### v0.3.0 (2026-05-15)
- 新增 SRS 複習模式（閃卡複習 + 到期單字優先排程）
- 首頁書卡顯示今日待複習數量紅點
- 新增單字本編輯功能（長按書卡）

### v0.2.0
- 新增 Email 驗證、忘記密碼、重設密碼畫面

### v0.1.0
- 初始版本：登入、單字書管理、閃卡測驗、學習統計

---

### v1.0.5 (2026-05-27)
- Add: Per-book study count and accuracy displayed in word list screen

### v1.0.4 (2026-05-25)
- Fix: auth_service error responses now guard jsonDecode with isNotEmpty to prevent crashes on non-JSON server responses

### v1.0.3 (2026-05-25)
- Add: Word list supports live search (word / translation / reading) and proficiency filter

### v1.0.2 (2026-05-22)
- Fix: Empty word books now show the "單字" button — word list always accessible

### v1.0.1 (2026-05-22)
- Add: Display name field in register mode
- Fix: Reset password validation updated to 8+ chars, letters + numbers

### v1.0.0 (2026-05-22)
- Add: Member profile screen — avatar (initials), display name, edit name, change password, About
- Add: Home screen AppBar avatar circle button navigates to profile

### v0.9.8 (2026-05-22)
- Fix: Flashcard buttons debounced — rapid double-tap no longer submits twice
- Fix: _finish() mounted check added to prevent navigation after widget disposal
- Fix: Study mode submitResult now has catchError — network failures don't crash
- Fix: Quiz progress bar changed to (index+1)/total — no longer 0% on first question
- Fix: Removed spurious loading state flicker before quiz result dialog
- Fix: _handleUnauthorized changed to Future<void>, flag reset in finally block
- Fix: getReviewStats cast changed to (as num).toInt() to prevent ClassCastException

### v0.9.7 (2026-05-21)
- Add: Word list screen supports adding new words (FAB `+` button)
- Add: Edit word inline from word list (⋯ menu → Edit)
- Add: Delete word with confirmation dialog (⋯ menu → Delete)
- Fix: Mounted check before refreshing list after edit/delete
- Fix: No longer throws JSON parse exception when API returns empty body

### v0.9.6 (2026-05-21)
- Add: SRS review preview screen (shows due & new word counts before entering flashcard)
- Add: Dedicated learning statistics screen (streak, today's count, total studied, accuracy)

### v0.9.5 (2026-05-21)
- Add: Password visibility toggle (eye icon) on password field
- Add: Frontend password strength validation for registration (8+ chars, letters + numbers)

### v0.9.4 (2026-05-21)
- Fix: Password field no longer trims leading/trailing spaces
- Fix: Empty email or password now shows inline error instead of making a network call
- Fix: Home screen shows error message and retry button when data fails to load
- Fix: Prevent duplicate unauthorized logout calls on concurrent 401 responses

### v0.9.3 (2026-05-21)
- Fix: Login loading button no longer gets stuck on failed login
- Fix: Home screen loading spinner no longer freezes when API calls fail
- Improve: Added 30-second timeout to all HTTP requests

### v0.9.2 (2026-05-21)
- Fix: Added Android INTERNET permission — release APK can now connect to the backend

### v0.9.1 (2026-05-21)
- Fix: Keyboard Done key now submits in both login and register modes

### v0.9.0 (2026-05-21)
- Fix: Enter key in register mode no longer auto-submits the form
- Fix: Loading button no longer gets stuck when a network error occurs

### v0.8.0 (2026-05-19)
- API now connects to Render production environment
- APK published to GitHub Releases for direct download

### v0.7.0 (2026-05-19)
- Added word list screen (proficiency progress bar + level stats)
- Proficiency badge on flashcard front
- Book card redesigned with 4 equal-width buttons (Words / Flashcard / Quiz / Review)
- ⋮ menu replaces long-press for more intuitive interaction
- Enter key triggers login on login screen

### v0.6.0 (2026-05-19)
- Added multiple choice quiz screen (green ✓ / red ✗ feedback)
- Added "選擇題" button on book cards, renamed "測驗" to "閃卡"
- Fixed login input text color to black

### v0.5.0 (2026-05-19)
- Added 🔥 Streak display on home screen (consecutive days + today's count)

### v0.4.1 (2026-05-16)
- Added vocabulary book creation (FAB button on home screen)
- Added vocabulary book deletion via long-press (with confirmation dialog)

### v0.4.0 (2026-05-16)
- Added TTS pronunciation (auto-play on flashcard + 🔊 manual replay button)
- Fixed muffled first playback (TTS engine warm-up)
- Adjusted speech rate to 0.7 for better language learning experience

### v0.3.0 (2026-05-15)
- Added SRS review mode (flashcard review with due-first scheduling)
- Review count badge on home screen book cards
- Added vocabulary book edit (long-press on book card)

### v0.2.0
- Added email verification, forgot password, password reset screens

### v0.1.0
- Initial release: login, vocabulary book management, flashcard study, learning statistics
