# LabLens - Architecture Diagrams

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Profile  │  │  Scan    │  │  Trend   │  │ Settings │   │
│  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
┌───────┼─────────────┼─────────────┼─────────────┼──────────┐
│       │      VIEW MODELS (State Management)      │          │
│  ┌────▼─────┐  ┌───▼──────┐  ┌──▼───────┐  ┌──▼───────┐  │
│  │ Profile  │  │  Report  │  │  Chart   │  │ Settings │  │
│  │ViewModel │  │ViewModel │  │ViewModel │  │ViewModel │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
┌───────┼─────────────┼─────────────┼─────────────┼──────────┐
│       │          SERVICES (Business Logic)       │          │
│  ┌────▼─────────────▼─────────────▼─────────────▼──────┐  │
│  │              DatabaseHelper (SQLite)                 │  │
│  │  • Profile CRUD    • Report Storage                  │  │
│  │  • Trend Queries   • Parameter Tracking              │  │
│  └────┬──────────────────────────────────────────┬──────┘  │
│       │                                           │          │
│  ┌────▼──────────┐  ┌──────────────┐  ┌─────────▼──────┐  │
│  │ GeminiService │  │ LOINCMapper  │  │ DocumentPicker │  │
│  │ • OCR Extract │  │ • Normalize  │  │ • Image/PDF    │  │
│  │ • AI Process  │  │ • Map Names  │  │ • Validation   │  │
│  └───────────────┘  └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────────┘
        │                     │                     │
┌───────▼─────────────────────▼─────────────────────▼─────────┐
│                      DATA LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   SQLite    │  │   Gemini    │  │    File     │         │
│  │  Database   │  │   API (AI)  │  │   Storage   │         │
│  │  • profiles │  │  • Extract  │  │  • Images   │         │
│  │  • reports  │  │  • Analyze  │  │  • PDFs     │         │
│  │  • params   │  │  • JSON     │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow - Scanning a Report

```
┌──────────────┐
│  User Action │
│ "Scan Report"│
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 1. User selects Profile & Image/PDF     │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 2. DocumentPickerService validates file │
│    • Check size (<10MB)                  │
│    • Check type (jpg/png/pdf)           │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 3. GeminiService.extractBloodReportData │
│    a. Read file bytes                    │
│    b. Send to Gemini API with prompt    │
│    c. Receive JSON response              │
│    d. Parse and validate                 │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 4. LOINCMapper.normalize parameters      │
│    • "RBC Count" → "rbc_count"          │
│    • "WBC" → "wbc_count"                │
│    • Fuzzy match unknown params         │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 5. DatabaseHelper.saveBloodReport       │
│    [Transaction Start]                   │
│    a. INSERT into reports table         │
│    b. INSERT each parameter             │
│    [Transaction Commit]                  │
└──────┬───────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ 6. UI Updates                            │
│    • Show success message               │
│    • Navigate to profile dashboard      │
│    • Display latest values              │
└──────────────────────────────────────────┘
```

## 📊 Database Schema Relationships

```
┌─────────────────────┐
│      profiles       │
│─────────────────────│
│ • id (PK)           │
│ • name              │
│ • date_of_birth     │
│ • gender            │
│ • photo_path        │
│ • created_at        │
└──────────┬──────────┘
           │ 1
           │ owns
           │ many
           ▼ N
┌─────────────────────┐
│      reports        │
│─────────────────────│
│ • id (PK)           │
│ • profile_id (FK) ◄─┘
│ • test_date         │
│ • lab_name          │
│ • report_image_path │
│ • created_at        │
└──────────┬──────────┘
           │ 1
           │ has
           │ many
           ▼ N
┌─────────────────────────┐
│   blood_parameters      │
│─────────────────────────│
│ • id (PK)               │
│ • report_id (FK) ◄──────┘
│ • parameter_name        │  (normalized: "rbc_count")
│ • parameter_value       │  (numeric: 5.2)
│ • unit                  │  ("million cells/μL")
│ • reference_range_min   │  (4.5)
│ • reference_range_max   │  (5.9)
│ • raw_parameter_name    │  (original: "RBC Count")
└─────────────────────────┘

Indexes:
• idx_reports_profile (profile_id)
• idx_reports_date (test_date)
• idx_parameters_name (parameter_name)
```

## 🔀 Parameter Normalization Flow

```
┌─────────────────────────────────────────────┐
│  Raw Data from Blood Report                 │
│  "RBC Count: 5.2 million cells/μL"         │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ LAYER 1: Gemini AI Normalization           │
│ Prompt instructs: Convert to "rbc_count"   │
│ Output: {                                   │
│   "rbc_count": {                            │
│     "value": 5.2,                           │
│     "unit": "million cells/μL",            │
│     "raw_name": "RBC Count"                │
│   }                                         │
│ }                                           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ LAYER 2: LOINC Mapper Verification         │
│ Check mapping table:                        │
│ • "rbc count" → "rbc_count" ✓              │
│ • "red blood cells" → "rbc_count" ✓        │
│ • "erythrocytes" → "rbc_count" ✓           │
│ Result: Confirmed as "rbc_count"           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ LAYER 3: Fuzzy Matching (if needed)        │
│ For unknown variations:                     │
│ • "RBC-Count" → 95% match → "rbc_count"    │
│ • "RBC#" → 88% match → "rbc_count"         │
│ Threshold: 85% similarity                   │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ FINAL: Standardized Parameter              │
│ Database Storage:                           │
│ • parameter_name: "rbc_count"              │
│ • parameter_value: 5.2                     │
│ • unit: "million cells/μL"                 │
│ • raw_parameter_name: "RBC Count"          │
│                                             │
│ ✅ Consistent across all reports!          │
└─────────────────────────────────────────────┘
```

## 📈 Trend Visualization Data Flow

```
User selects: Profile="Father", Parameter="rbc_count"
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ DatabaseHelper.getParameterTrend()         │
│ Query:                                      │
│   SELECT test_date, parameter_value        │
│   FROM blood_parameters bp                 │
│   JOIN reports r ON bp.report_id = r.id   │
│   WHERE r.profile_id = ? AND               │
│         bp.parameter_name = ?              │
│   ORDER BY test_date ASC                   │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ Data Retrieved:                             │
│ [                                           │
│   {date: "2024-01-15", value: 5.1},       │
│   {date: "2024-04-20", value: 5.3},       │
│   {date: "2024-07-10", value: 5.0},       │
│   {date: "2024-10-19", value: 5.2}        │
│ ]                                           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ FL Chart LineChart Widget                   │
│                                             │
│  RBC Count Trend                            │
│  ┌─────────────────────────────────────┐   │
│  │                                     │   │
│  │ 5.9 ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ (max)      │   │
│  │     ╱╲                              │   │
│  │ 5.2    ╲╱╲                          │   │
│  │           ╲                         │   │
│  │ 4.5 ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ (min)      │   │
│  │                                     │   │
│  └─────────────────────────────────────┘   │
│    Jan   Apr   Jul   Oct                   │
│    2024  2024  2024  2024                  │
│                                             │
│  Reference Range: 4.5 - 5.9                │
│  Current Value: 5.2 (Normal ✓)             │
└─────────────────────────────────────────────┘
```

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────┐
│           USER DEVICE (Local)               │
│                                             │
│  ┌───────────────────────────────────┐     │
│  │      App Sandbox                  │     │
│  │                                   │     │
│  │  ┌─────────────────────────┐     │     │
│  │  │ FlutterSecureStorage    │     │     │
│  │  │ • Gemini API Key        │     │     │
│  │  │   (Encrypted)           │     │     │
│  │  └─────────────────────────┘     │     │
│  │                                   │     │
│  │  ┌─────────────────────────┐     │     │
│  │  │ SQLite Database         │     │     │
│  │  │ • Profiles              │     │     │
│  │  │ • Reports               │     │     │
│  │  │ • Parameters            │     │     │
│  │  │   (Local Only)          │     │     │
│  │  └─────────────────────────┘     │     │
│  │                                   │     │
│  │  ┌─────────────────────────┐     │     │
│  │  │ File Storage            │     │     │
│  │  │ • Report Images         │     │     │
│  │  │ • Report PDFs           │     │     │
│  │  │   (Private Directory)   │     │     │
│  │  └─────────────────────────┘     │     │
│  └───────────────────────────────────┘     │
│                                             │
│  ────────────────────────────────────────  │
│                                             │
│  Only during scan:                          │
│  ┌─────────────────────┐                   │
│  │  HTTPS Connection   │                   │
│  │  to Gemini API      │                   │
│  │  • Image bytes      │                   │
│  │  • Prompt text      │                   │
│  │  ↓                  │                   │
│  │  • JSON response    │                   │
│  └─────────────────────┘                   │
│                                             │
│  No other external connections             │
│  No cloud storage                           │
│  No analytics/telemetry                     │
└─────────────────────────────────────────────┘
```

## 🎨 UI Component Hierarchy

```
MaterialApp
└── HomeScreen
    ├── AppBar (Title: "LabLens")
    ├── Body
    │   └── ProfileList
    │       ├── ProfileCard (Father)
    │       │   ├── Avatar
    │       │   ├── Name
    │       │   ├── ReportCount
    │       │   └── AbnormalIndicator
    │       ├── ProfileCard (Mother)
    │       └── ProfileCard (...)
    └── FloatingActionButton (Add Profile)

    On Tap ProfileCard → ProfileDashboard
    ├── AppBar (Profile Name)
    ├── Body
    │   ├── LatestReportCard
    │   │   ├── Date
    │   │   ├── LabName
    │   │   └── ParameterSummary
    │   ├── ParameterList
    │   │   ├── ParameterTile (RBC)
    │   │   ├── ParameterTile (WBC)
    │   │   └── ParameterTile (...)
    │   └── ReportHistoryList
    └── FloatingActionButton (Scan Report)

        On Tap Scan → ScanReportScreen
        ├── AppBar ("Scan Blood Report")
        ├── Body
        │   ├── ImagePreview
        │   ├── PickerButtons
        │   │   ├── TakePhoto
        │   │   ├── ChooseGallery
        │   │   └── SelectPDF
        │   └── ExtractButton
        └── OnExtract → ReviewDataScreen
            ├── AppBar ("Review Data")
            ├── Body
            │   └── ExtractedParameterList
            │       ├── EditableParameterTile
            │       └── EditableParameterTile
            └── SaveButton

        On Tap ParameterTile → TrendChartScreen
        ├── AppBar (Parameter Name)
        ├── Body
        │   ├── TimeRangePicker
        │   ├── LineChart (FL Chart)
        │   │   ├── DataPoints
        │   │   ├── TrendLine
        │   │   └── ReferenceRangeLines
        │   └── StatsSummary
        │       ├── LatestValue
        │       ├── AverageValue
        │       └── TrendDirection
        └── ExportButton
```

## 🔄 State Management Flow (Provider)

```
┌─────────────────────────────────────────┐
│         Widget Tree                     │
│                                         │
│  ┌───────────────────────────────┐     │
│  │ ChangeNotifierProvider        │     │
│  │ <ProfileViewModel>            │     │
│  │   │                           │     │
│  │   ├─> ProfileListScreen       │     │
│  │   │    └─> Consumer<Profile   │     │
│  │   │         ViewModel>        │     │
│  │   │         • _profiles       │     │
│  │   │         • _isLoading      │     │
│  │   │                           │     │
│  │   └─> ProfileDashboard        │     │
│  │        └─> Consumer<Profile   │     │
│  │             ViewModel>        │     │
│  └───────────────────────────────┘     │
│                                         │
│  User Action: "Delete Profile"         │
│         │                               │
│         ▼                               │
│  ProfileViewModel.deleteProfile(id)    │
│         │                               │
│         ├─> DatabaseHelper.delete()    │
│         │                               │
│         └─> notifyListeners()          │
│                    │                    │
│                    ▼                    │
│         All Consumers Rebuild          │
│         • ProfileListScreen updates    │
│         • ProfileDashboard closes      │
└─────────────────────────────────────────┘
```

---

These diagrams should help visualize:
1. Overall system architecture
2. Data flow during scanning
3. Database relationships
4. Parameter normalization process
5. Trend visualization
6. Security model
7. UI hierarchy
8. State management

**Use these as reference when implementing the UI!** 🎨
