# LabLens - Implementation Guide

## 🎯 Project Overview

This document provides a complete implementation guide for the LabLens app - a Flutter application that uses AI to analyze blood reports and track health trends over time.

## 📂 Project Structure Created

```
health_analyzer/
├── lib/
│   ├── main.dart                               ✅ Created
│   ├── models/
│   │   ├── blood_report.dart                   ✅ Created
│   │   ├── profile.dart                        ✅ Created
│   │   └── parameter.dart                      ✅ Created
│   ├── viewmodels/                             📁 Ready for implementation
│   │   ├── report_viewmodel.dart
│   │   ├── profile_viewmodel.dart
│   │   └── chart_viewmodel.dart
│   ├── views/                                  📁 Ready for implementation
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── scan_report_screen.dart
│   │   │   ├── profile_list_screen.dart
│   │   │   └── trend_chart_screen.dart
│   │   └── widgets/
│   │       ├── blood_parameter_chart.dart
│   │       └── profile_card.dart
│   ├── services/
│   │   ├── database_helper.dart                ✅ Created
│   │   ├── gemini_service.dart                 ✅ Created
│   │   ├── loinc_mapper.dart                   ✅ Created
│   │   └── document_picker_service.dart        ✅ Created
│   └── utils/
│       └── constants.dart                      ✅ Created
├── pubspec.yaml                                ✅ Created
└── README.md                                   ✅ Created
```

## 🚀 Next Steps - Quick Start

### Step 1: Initialize Flutter Project

Since we've created the folder structure, now you need to initialize it as a Flutter project:

```powershell
cd "c:\Users\Devasy\OneDrive\Desktop\Hwiz\health_analyzer"
flutter create . --project-name health_analyzer
```

This will generate the necessary Flutter project files (android/, ios/, web/, etc.).

### Step 2: Install Dependencies

```powershell
flutter pub get
```

This will install all packages defined in `pubspec.yaml`.

### Step 3: Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Keep it safe - you'll enter it in the app settings

### Step 4: Test the Project

```powershell
flutter run
```

## 🔑 Key Features Already Implemented

### ✅ 1. Database Layer (SQLite)
- **File**: `lib/services/database_helper.dart`
- **Features**:
  - Profile management (create, read, update, delete)
  - Blood report storage with transactions
  - Parameter tracking with normalization
  - Trend data queries
  - Foreign key constraints with cascade delete
  - Optimized indexes for fast queries

### ✅ 2. AI Service (Gemini API)
- **File**: `lib/services/gemini_service.dart`
- **Features**:
  - Image and PDF processing
  - Structured data extraction with custom prompts
  - Automatic parameter normalization
  - Retry logic with exponential backoff
  - API key management with secure storage
  - Error handling and validation

### ✅ 3. Parameter Normalization (LOINC Mapper)
- **File**: `lib/services/loinc_mapper.dart`
- **Features**:
  - 100+ parameter name variations mapped
  - Handles different naming conventions across labs
  - Fuzzy matching for unknown parameters
  - Display name conversion
  - Extensible mapping system

### ✅ 4. Document Handling
- **File**: `lib/services/document_picker_service.dart`
- **Features**:
  - Image selection from gallery
  - Camera capture
  - PDF file selection
  - File validation (size, type)
  - Cross-platform support

### ✅ 5. Data Models
- **Files**: 
  - `lib/models/profile.dart` - User profile
  - `lib/models/blood_report.dart` - Report container
  - `lib/models/parameter.dart` - Individual test values
- **Features**:
  - Immutable data classes
  - Database serialization
  - Status detection (normal/abnormal)
  - Copy constructors

### ✅ 6. Constants & Configuration
- **File**: `lib/utils/constants.dart`
- **Features**:
  - Standard parameter names
  - Reference ranges for normal values
  - Unit definitions
  - App configuration

## 📋 Implementation Roadmap

### Phase 1: Core UI (Week 1-2)

#### 1.1 Home Screen
Create `lib/views/screens/home_screen.dart`:
- Display list of profiles
- Quick stats (latest report, abnormal values)
- Navigation to other screens
- Floating action button to add profile

#### 1.2 Profile Management
Create `lib/views/screens/profile_list_screen.dart`:
- List all profiles with cards
- Add/edit/delete profiles
- Profile photos (optional)
- Report count per profile

#### 1.3 Profile ViewModel
Create `lib/viewmodels/profile_viewmodel.dart`:
```dart
class ProfileViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Profile> _profiles = [];
  bool _isLoading = false;
  
  Future<void> loadProfiles() async {
    _isLoading = true;
    notifyListeners();
    
    _profiles = await _db.getAllProfiles();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> createProfile(Profile profile) async {
    await _db.insertProfile(profile);
    await loadProfiles();
  }
  // ... more methods
}
```

### Phase 2: Report Scanning (Week 2-3)

#### 2.1 Scan Report Screen
Create `lib/views/screens/scan_report_screen.dart`:
- Select profile
- Choose image/PDF (gallery or camera)
- Preview selected file
- Scan button with loading indicator
- Review extracted data
- Save to database

#### 2.2 Report ViewModel
Create `lib/viewmodels/report_viewmodel.dart`:
```dart
class ReportViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final GeminiService _gemini = GeminiService();
  
  Future<void> scanAndSaveReport({
    required int profileId,
    required File reportFile,
  }) async {
    // 1. Extract data with Gemini
    final extractedData = await _gemini.extractWithRetry(reportFile);
    
    // 2. Normalize parameters
    final normalizedParams = _normalizeParameters(extractedData);
    
    // 3. Save to database
    await _db.saveBloodReport(
      profileId: profileId,
      testDate: DateTime.parse(extractedData['test_date']),
      parameters: normalizedParams,
      labName: extractedData['lab_name'],
      imagePath: reportFile.path,
    );
    
    notifyListeners();
  }
}
```

### Phase 3: Data Visualization (Week 3-4)

#### 3.1 Trend Chart Screen
Create `lib/views/screens/trend_chart_screen.dart`:
- Select parameter to visualize
- Time range selector
- Reference range overlay
- Data points with values
- Export chart option

#### 3.2 Blood Parameter Chart Widget
Create `lib/views/widgets/blood_parameter_chart.dart`:
```dart
import 'package:fl_chart/fl_chart.dart';

class BloodParameterChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final String parameterName;
  final double? refMin;
  final double? refMax;
  
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _buildSpots(),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
        // Add reference range lines
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (refMin != null)
              HorizontalLine(y: refMin!, color: Colors.red.withOpacity(0.3)),
            if (refMax != null)
              HorizontalLine(y: refMax!, color: Colors.red.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
```

### Phase 4: Settings & Polish (Week 4-5)

#### 4.1 Settings Screen
- API key management
- Theme selection
- Data export/import
- About & help

#### 4.2 Error Handling
- User-friendly error messages
- Retry mechanisms
- Offline support

#### 4.3 Testing
- Unit tests for models
- Widget tests for UI
- Integration tests for workflows

## 🔧 Configuration Files Needed

### 1. Android Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### 2. iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan blood reports</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select blood reports</string>
```

## 🎨 UI Design Principles

### Color Scheme
- **Primary**: Blue (trust, health)
- **Success**: Green (normal values)
- **Warning**: Orange (borderline values)
- **Error**: Red (abnormal values)
- **Background**: White/Light gray

### Typography
- **Headlines**: Bold, large
- **Body**: Regular, readable
- **Parameter values**: Monospace, emphasized

## 📊 Sample Workflow

1. **User opens app** → Shows list of profiles
2. **User selects profile** → Shows profile dashboard with latest report
3. **User taps "Scan New Report"** → Document picker opens
4. **User selects blood report image** → Preview shown
5. **User taps "Extract Data"** → Gemini API processes image
6. **Extracted data shown** → User reviews and can edit
7. **User taps "Save"** → Data stored in SQLite
8. **User views trends** → Charts show parameter history

## 🔍 Testing Strategy

### Unit Tests
```dart
test('Profile model serialization', () {
  final profile = Profile(name: 'John Doe');
  final map = profile.toMap();
  final restored = Profile.fromMap(map);
  expect(restored.name, 'John Doe');
});

test('Parameter normalization', () {
  expect(LOINCMapper.normalize('RBC Count'), 'rbc_count');
  expect(LOINCMapper.normalize('Red Blood Cells'), 'rbc_count');
});
```

### Widget Tests
```dart
testWidgets('Home screen shows profiles', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('LabLens'), findsOneWidget);
});
```

## 🚨 Common Issues & Solutions

### Issue 1: Gemini API Quota Exceeded
**Solution**: Implement rate limiting and show user-friendly error

### Issue 2: Poor OCR Accuracy
**Solution**: 
- Ensure high-quality images
- Good lighting conditions
- Clear text in reports
- Prompt engineering

### Issue 3: Parameter Name Mismatch
**Solution**: 
- Expand LOINC mapper with more variations
- Allow user to manually map unknown parameters
- Store mapping for future use

## 💰 Cost Optimization

### Gemini API Usage
- Compress images before sending (already implemented: max 1920x1920)
- Cache extracted data
- Use batch processing for multiple reports
- Monitor API usage

### Storage Optimization
- Store images in compressed format
- Implement database cleanup for old reports
- Add data export/archive feature

## 🔐 Security Considerations

1. **API Keys**: 
   - Never hardcode
   - Use flutter_secure_storage
   - Allow user to set/change

2. **Data Privacy**:
   - All data stored locally
   - No telemetry by default
   - Optional cloud backup (encrypted)

3. **Medical Data**:
   - Follow healthcare data guidelines
   - Add disclaimers
   - Don't use for medical decisions

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Gemini API Guide](https://ai.google.dev/docs)
- [SQLite in Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [FL Chart Examples](https://github.com/imaNNeo/fl_chart/tree/master/example)
- [MVVM in Flutter](https://medium.com/flutter-community/mvvm-in-flutter-edd212fd767a)

## 🎯 Success Criteria

- ✅ User can create multiple profiles
- ✅ User can scan blood reports (image/PDF)
- ✅ AI accurately extracts 90%+ of parameters
- ✅ Charts show clear trends over time
- ✅ App works offline after initial scan
- ✅ Data is persistent across app restarts
- ✅ UI is intuitive and responsive
- ✅ Error handling is user-friendly

## 📞 Support & Contributing

For questions or contributions:
1. Open an issue on GitHub
2. Submit a pull request
3. Contact: [Your Email]

---

**Ready to build!** The foundation is solid. Now it's time to create the UI and bring this app to life! 🚀
