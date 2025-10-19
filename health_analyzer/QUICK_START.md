# Quick Start Guide - Health Analyzer

## 🎯 What You Have Now

You have a complete **foundation** for your Health Analyzer app! Here's what's been created:

### ✅ Complete Core Architecture
1. **Database Layer** - SQLite with proper schema and indexes
2. **AI Service** - Gemini API integration for OCR
3. **Data Models** - Profile, BloodReport, Parameter
4. **Normalization Engine** - LOINC mapper with fuzzy matching
5. **Document Handling** - Image and PDF picker
6. **Configuration** - Constants, reference ranges, units

## 🚀 Getting Started (5 Minutes)

### Step 1: Initialize Flutter Project
Open PowerShell and run:

```powershell
cd "c:\Users\Devasy\OneDrive\Desktop\Hwiz\health_analyzer"
flutter create . --project-name health_analyzer
```

This creates the necessary Flutter files (android/, ios/, etc.)

### Step 2: Install Dependencies
```powershell
flutter pub get
```

### Step 3: Get Gemini API Key
1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key (keep it safe!)

### Step 4: Run the App
```powershell
flutter run
```

The app will start with a basic splash screen!

## 📋 What to Build Next

You have the **backend/logic** ready. Now build the **frontend/UI**:

### Priority 1: Profile Management (1-2 days)
- Screen to list profiles
- Add/edit/delete profile functionality
- Profile cards with basic info

### Priority 2: Report Scanning (2-3 days)
- Screen to select and upload report
- Integration with Gemini API
- Display extracted data
- Save to database

### Priority 3: Data Visualization (2-3 days)
- Charts using FL Chart
- Trend display per parameter
- Time range selection

## 🎨 UI Component Suggestions

### Home Screen Layout
```
┌─────────────────────────┐
│   Health Analyzer       │
├─────────────────────────┤
│                         │
│   Profile Cards:        │
│   ┌───────────────┐    │
│   │ 👤 Father      │    │
│   │ 📊 12 reports  │    │
│   │ 🔴 2 abnormal  │    │
│   └───────────────┘    │
│                         │
│   ┌───────────────┐    │
│   │ 👤 Mother      │    │
│   │ 📊 8 reports   │    │
│   │ 🟢 All normal  │    │
│   └───────────────┘    │
│                         │
│        [+ Add Profile]  │
└─────────────────────────┘
```

### Scan Report Screen
```
┌─────────────────────────┐
│  ← Scan Blood Report    │
├─────────────────────────┤
│                         │
│  Select Profile:        │
│  [Father ▼]            │
│                         │
│  ┌─────────────────┐   │
│  │                 │   │
│  │  [Image Preview]│   │
│  │                 │   │
│  └─────────────────┘   │
│                         │
│  [📷 Take Photo]        │
│  [🖼️ Choose from Gallery]│
│  [📄 Select PDF]        │
│                         │
│  [Extract & Save]       │
└─────────────────────────┘
```

## 💡 Pro Tips

### 1. Start Simple
Don't build everything at once. Start with:
- Create profile
- List profiles
- Delete profile

Then add scanning, then charts.

### 2. Use Existing Code
All the hard parts are done:
- Database queries → Use `DatabaseHelper`
- AI extraction → Use `GeminiService`
- Parameter names → Use `LOINCMapper`

### 3. Test As You Go
After each feature, test it:
```powershell
flutter run
```

### 4. Use Hot Reload
While app is running, make changes and press `r` in terminal for hot reload!

## 🔧 Quick Commands Reference

```powershell
# Run app
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device_id>

# Check for issues
flutter doctor

# Clean build
flutter clean
flutter pub get

# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests (once you add them)
flutter test
```

## 🎯 Development Timeline Estimate

| Phase | Task | Time | Status |
|-------|------|------|--------|
| 1 | Project setup | 30 min | ✅ Done |
| 2 | Core architecture | 3-4 hours | ✅ Done |
| 3 | Profile UI | 1-2 days | ⏳ Next |
| 4 | Scan Report UI | 2-3 days | ⏳ Next |
| 5 | Charts/Visualization | 2-3 days | ⏳ Next |
| 6 | Polish & Testing | 2-3 days | ⏳ Next |
| **Total** | **MVP** | **~2 weeks** | 40% Done |

## 🐛 Troubleshooting

### Error: "Target of URI doesn't exist"
**Cause**: Packages not installed
**Solution**: Run `flutter pub get`

### Error: "No devices found"
**Cause**: No emulator/device connected
**Solution**: 
- Start Android emulator
- Connect physical device
- Use Chrome: `flutter run -d chrome`

### Error: "Gemini API Error"
**Cause**: Invalid API key
**Solution**: Check API key in settings

## 📚 Helpful Resources

- **Flutter Widgets**: https://flutter.dev/docs/development/ui/widgets
- **Material Design**: https://m3.material.io/
- **FL Chart Examples**: https://github.com/imaNNeo/fl_chart/tree/master/example
- **Provider State Management**: https://pub.dev/packages/provider

## 🎉 You're Ready!

Everything you need is in place. The hard backend work is done. Now it's time to build the UI and make it look beautiful!

### Your Next Command:
```powershell
cd "c:\Users\Devasy\OneDrive\Desktop\Hwiz\health_analyzer"
flutter create . --project-name health_analyzer
flutter pub get
flutter run
```

Happy coding! 🚀
