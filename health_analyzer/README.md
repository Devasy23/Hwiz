# Health Analyzer 🩺

A Flutter application for tracking and analyzing blood report trends over time. Upload blood test reports (images or PDFs), extract data using AI, and visualize trends with beautiful charts.

## 📋 Features

- **Multi-Profile Support**: Create separate profiles for family members
- **AI-Powered OCR**: Extract blood test data from images/PDFs using Google Gemini API
- **Smart Normalization**: Handles variations in parameter naming across different labs
- **Trend Visualization**: Beautiful charts showing parameter trends over time
- **Local Storage**: All data stored locally using SQLite for privacy
- **Offline-First**: Works without internet after initial scan
- **Parameter Status**: Automatically flags abnormal values based on reference ranges

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with the following structure:

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── blood_report.dart        # Blood report model
│   ├── profile.dart             # User profile model
│   └── parameter.dart           # Blood parameter model
├── viewmodels/                  # Business logic
│   ├── report_viewmodel.dart
│   ├── profile_viewmodel.dart
│   └── chart_viewmodel.dart
├── views/                       # UI components
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── scan_report_screen.dart
│   │   ├── profile_list_screen.dart
│   │   └── trend_chart_screen.dart
│   └── widgets/
│       ├── blood_parameter_chart.dart
│       └── profile_card.dart
├── services/                    # Services layer
│   ├── database_helper.dart     # SQLite operations
│   ├── gemini_service.dart      # AI extraction
│   ├── loinc_mapper.dart        # Parameter normalization
│   └── document_picker_service.dart
└── utils/                       # Utilities
    └── constants.dart           # App constants
```

## 🗄️ Database Schema

### Profiles Table
- `id`: Primary key
- `name`: Profile name
- `date_of_birth`: Birth date (optional)
- `gender`: Gender (optional)
- `photo_path`: Profile photo path
- `created_at`: Creation timestamp

### Reports Table
- `id`: Primary key
- `profile_id`: Foreign key to profiles
- `test_date`: Date of blood test
- `lab_name`: Laboratory name
- `report_image_path`: Path to scanned report
- `created_at`: Creation timestamp

### Blood Parameters Table
- `id`: Primary key
- `report_id`: Foreign key to reports
- `parameter_name`: Normalized parameter name
- `parameter_value`: Numeric value
- `unit`: Unit of measurement
- `reference_range_min`: Minimum normal value
- `reference_range_max`: Maximum normal value
- `raw_parameter_name`: Original name from report

## 🔧 Key Technologies

- **Flutter**: Cross-platform UI framework
- **SQLite**: Local database storage
- **Google Gemini API**: AI-powered OCR and data extraction
- **FL Chart**: Data visualization
- **Provider**: State management
- **Fuzzy Matching**: Intelligent parameter name matching

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Google Gemini API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Devasy23/Hwiz.git
   cd Hwiz/health_analyzer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Setup Gemini API Key

1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. In the app settings, enter your API key
3. The key is stored securely using `flutter_secure_storage`

## 📊 Supported Blood Parameters

The app automatically normalizes and tracks common blood test parameters:

- **Complete Blood Count (CBC)**:
  - RBC Count
  - WBC Count
  - Hemoglobin
  - Hematocrit
  - Platelet Count
  - MCV, MCH, MCHC

- **Differential Count**:
  - Neutrophils
  - Lymphocytes
  - Monocytes
  - Eosinophils
  - Basophils

- **Additional Parameters**:
  - ESR
  - RDW
  - MPV
  - And more...

## 🎯 Parameter Normalization

The app uses a sophisticated multi-layer normalization system:

1. **AI-Powered Normalization**: Gemini API normalizes parameter names during extraction
2. **LOINC-Based Mapping**: Local mapping table with 100+ parameter variations
3. **Fuzzy Matching**: Handles typos and unknown variations

Examples of normalization:
- "RBC Count" / "Red Blood Cells" / "Erythrocytes" → `rbc_count`
- "WBC" / "White Blood Cells" / "TC" → `wbc_count`
- "Hemoglobin" / "Hb" / "HGB" → `hemoglobin`

## 💡 Usage Flow

1. **Create Profile**: Add a profile for yourself or family member
2. **Scan Report**: Upload image/PDF of blood test report
3. **AI Extraction**: Gemini API extracts and normalizes data
4. **Review & Save**: Verify extracted data and save to database
5. **View Trends**: See beautiful charts showing parameter trends over time
6. **Track Health**: Monitor which parameters are improving or declining

## 🔒 Privacy & Security

- **Local-First**: All data stored locally on device
- **No Cloud Storage**: Reports never leave your device
- **Secure API Keys**: Gemini API key stored in secure storage
- **Optional Biometrics**: Add fingerprint/face unlock (future feature)

## 💰 Cost Estimation

**Gemini API Pricing** (as of 2025):
- Gemini 1.5 Pro: ~$1.25 per million input tokens
- Average blood report scan: ~700 tokens
- **Cost per scan**: ~$0.001 (less than a tenth of a cent!)
- **1000 scans**: ~$1

Extremely affordable for personal/family use.

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 TODO / Roadmap

- [ ] Implement ViewModels for state management
- [ ] Create UI screens (Home, Scan, Charts)
- [ ] Add chart widgets with FL Chart
- [ ] Implement biometric authentication
- [ ] Add export functionality (PDF, CSV)
- [ ] Support for more report types (lipid panel, thyroid, etc.)
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Cloud backup option (encrypted)
- [ ] Share reports with doctors

## ⚠️ Disclaimer

This app is for personal health tracking only and should not be used as a substitute for professional medical advice. Always consult with qualified healthcare providers for medical decisions.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Devasy Patel**

## 🙏 Acknowledgments

- Google Gemini API for AI-powered extraction
- Flutter team for the amazing framework
- FL Chart for beautiful visualizations
- The open-source community

---

Made with ❤️ for better health tracking
