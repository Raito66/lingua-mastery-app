# LinguaMastery App

[English](#english) | [繁體中文](#繁體中文)

---

## 繁體中文

### 專案簡介

LinguaMastery 行動應用程式，使用 Flutter 開發，支援 Android 與 Web 平台。提供使用者登入、單字書管理、閃卡學習與學習記錄等功能。

### 技術棧

- **框架**：Flutter 3
- **語言**：Dart
- **HTTP**：http 套件
- **本地儲存**：shared_preferences
- **TTS**：flutter_tts
- **目標平台**：Android、Web

### 主要功能

- 使用者註冊 / 登入
- Email 驗證流程
- 忘記密碼 / 重設密碼（Token 手動輸入）
- 單字書管理（長按編輯名稱、語言）
- 閃卡學習模式（含自動朗讀 TTS + 🔊 手動重播）
- 間隔重複複習（SRS）
- 學習結果統計

### 本地啟動

#### 前置條件

- Flutter 3.x SDK
- Android Studio（含 Android 模擬器）
- 後端 API 運行中

#### 安裝與啟動

```bash
flutter pub get
flutter run
```

- **Android 模擬器**：API 連線至 `http://10.0.2.2:8080`
- **Web / Windows**：API 連線至 `http://localhost:8080`

### 專案結構

```
lib/
├── main.dart
├── models/
│   ├── word.dart
│   └── word_book.dart
├── services/
│   ├── api_service.dart    # HTTP 基礎設定、401 自動登出
│   ├── auth_service.dart   # 驗證相關 API
│   └── word_service.dart   # 單字、複習、統計 API
└── screens/
    ├── login_screen.dart
    ├── verify_email_screen.dart
    ├── forgot_password_screen.dart
    ├── reset_password_screen.dart
    ├── home_screen.dart
    ├── flashcard_screen.dart
    └── result_screen.dart
```

---

## English

### Overview

Mobile application for LinguaMastery, a gamified language learning platform. Built with Flutter, targeting Android and Web platforms.

### Tech Stack

- **Framework**: Flutter 3
- **Language**: Dart
- **HTTP**: http package
- **Local Storage**: shared_preferences
- **TTS**: flutter_tts
- **Platforms**: Android, Web

### Features

- User registration / login
- Email verification flow
- Forgot password / password reset (manual token entry)
- Vocabulary book management (long-press to edit name & language)
- Flashcard study mode (with auto TTS + 🔊 manual replay)
- Spaced repetition review (SRS)
- Learning result statistics

### Getting Started

#### Prerequisites

- Flutter 3.x SDK
- Android Studio (with Android emulator)
- Backend API running

#### Install & Run

```bash
flutter pub get
flutter run
```

- **Android emulator**: API connects to `http://10.0.2.2:8080`
- **Web / Windows**: API connects to `http://localhost:8080`

### Project Structure

```
lib/
├── main.dart
├── models/
│   ├── word.dart
│   └── word_book.dart
├── services/
│   ├── api_service.dart    # HTTP base config, 401 auto-logout
│   ├── auth_service.dart   # Auth-related API calls
│   └── word_service.dart   # Word, review, stats API calls
└── screens/
    ├── login_screen.dart
    ├── verify_email_screen.dart
    ├── forgot_password_screen.dart
    ├── reset_password_screen.dart
    ├── home_screen.dart
    ├── flashcard_screen.dart
    └── result_screen.dart
```

---

## 更新日誌 / Changelog

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
