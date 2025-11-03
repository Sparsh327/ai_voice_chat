

---

## 📄 README.md

````markdown
# AI Voice Chat App

A Flutter app with AI chat,

## 🚀 Quick Setup

### Requirements

- Flutter 3.35.0
- Dart 3.9.0

### Installation

1. **Clone & Install**

```bash
git clone <your-repo>
cd ai_voice_chat
flutter pub get
```
````

2. **Create `.env` file** in project root:

```env
openAiApiKey=sk-YOUR_KEY_HERE
openAiApiUrl=https://api.openai.com/v1/chat/completions
openAiModel=gpt-3.5-turbo
supabaseUrl=https://YOUR_PROJECT.supabase.co
supabaseAnonKey=YOUR_ANON_KEY
```

3. **Get API Keys**

- OpenAI: https://platform.openai.com/api-keys
- Supabase: https://supabase.com (Settings → API)



4. **Add Permissions**

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Speech recognition for voice chat</string>
```

5. **Run**

```bash
flutter run
```

```
