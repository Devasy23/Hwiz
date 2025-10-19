# Hwiz - Health Analyzer 🩺

An open-source Flutter app for analyzing and visualizing blood report trends over time using AI.

## 🎯 Project Vision

Track your family's health by uploading blood test reports (images or PDFs), automatically extracting data using Google Gemini AI, and viewing beautiful trend charts for each parameter over time.

## ✨ Key Features

- 📸 **AI-Powered OCR**: Upload blood report images/PDFs, extract data automatically
- 👥 **Multi-Profile Support**: Track reports for multiple family members
- 📊 **Trend Visualization**: Beautiful charts showing parameter trends over time
- 🔒 **Privacy First**: All data stored locally using SQLite
- 🎯 **Smart Normalization**: Handles different parameter naming conventions across labs
- 📱 **Cross-Platform**: Works on Android, iOS, and Web

## 🏗️ Project Structure

```
Hwiz/
├── health_analyzer/              # Main Flutter app
│   ├── lib/
│   │   ├── models/              ✅ Data models
│   │   ├── viewmodels/          📁 State management (to be implemented)
│   │   ├── views/               📁 UI screens (to be implemented)
│   │   ├── services/            ✅ Business logic & APIs
│   │   └── utils/               ✅ Constants & utilities
│   ├── README.md                # Detailed app documentation
│   ├── QUICK_START.md           # Getting started guide
│   ├── IMPLEMENTATION_GUIDE.md  # Development roadmap
│   ├── CODE_EXAMPLES.md         # Copy-paste ready code
│   ├── CHECKLIST.md             # Implementation checklist
│   └── ARCHITECTURE.md          # System architecture diagrams
└── README.md                    # This file
```

## 🚀 Current Status

**Phase 1: Foundation - COMPLETE ✅**
- ✅ Complete backend architecture (40% of total project)
- ✅ SQLite database with optimized schema
- ✅ Google Gemini AI integration for OCR
- ✅ Parameter normalization engine (handles naming variations)
- ✅ Document picker (images & PDFs)
- ✅ All data models and services
- ✅ Comprehensive documentation

**Next Phase: UI Implementation (60% remaining)**
- Profile management screens
- Report scanning interface
- Trend visualization charts
- Settings and configuration

## 💡 The Core Problem We Solve

**Problem**: Blood test reports use inconsistent parameter names across different labs:
- One lab writes "RBC Count"
- Another writes "RBC"
- Another writes "Red Blood Cells"

**Solution**: Multi-layer normalization system:
1. AI normalization during extraction
2. LOINC-based mapping table (100+ variations)
3. Fuzzy matching for unknown parameters
4. Result: Consistent database keys → Perfect visualizations!

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite (local storage)
- **AI/OCR**: Google Gemini 1.5 Pro API
- **Charts**: FL Chart
- **State Management**: Provider (MVVM pattern)
- **Security**: flutter_secure_storage

## 📊 Architecture Highlights

### Database Schema
```
profiles → reports → blood_parameters
   ↓          ↓            ↓
  Name    Test Date   Parameter Name (normalized)
          Lab Name    Parameter Value
          Image Path  Unit & Reference Ranges
```

### Data Flow
```
Upload Report → Gemini API → Normalize Parameters → SQLite → Charts
```

## 🎯 Use Case Example

Your father wants to track his RBC count over time:

1. **Add Profile**: Create "Father" profile
2. **Scan Report**: Upload blood test image from January
3. **Auto-Extract**: AI extracts "RBC: 5.1"
4. **Normalize**: "RBC" → `rbc_count` (standardized)
5. **Save**: Stored in local database
6. **Repeat**: Add more reports over months
7. **Visualize**: View trend chart showing RBC changes from Jan to Oct

## 💰 Cost Analysis

**Gemini API Pricing**:
- ~$0.001 per report scan (less than 1 cent!)
- 1000 scans = ~$1
- Perfect for personal/family use

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Google Gemini API key (free from [Google AI Studio](https://makersuite.google.com/app/apikey))

### Quick Start
```bash
cd health_analyzer
flutter create . --project-name health_analyzer
flutter pub get
flutter run
```

See **[QUICK_START.md](health_analyzer/QUICK_START.md)** for detailed instructions.

## 📚 Documentation

- **[README.md](health_analyzer/README.md)** - App overview and features
- **[QUICK_START.md](health_analyzer/QUICK_START.md)** - Get started in 5 minutes
- **[IMPLEMENTATION_GUIDE.md](health_analyzer/IMPLEMENTATION_GUIDE.md)** - Detailed development roadmap
- **[CODE_EXAMPLES.md](health_analyzer/CODE_EXAMPLES.md)** - Copy-paste ready code snippets
- **[CHECKLIST.md](health_analyzer/CHECKLIST.md)** - Track your progress
- **[ARCHITECTURE.md](health_analyzer/ARCHITECTURE.md)** - System design diagrams
- **[PROJECT_SUMMARY.md](health_analyzer/PROJECT_SUMMARY.md)** - Complete overview

## 🎯 Roadmap

### MVP (2-3 weeks)
- [x] Backend architecture (DONE)
- [ ] Profile management UI
- [ ] Report scanning UI
- [ ] Trend visualization
- [ ] Settings screen

### Future Enhancements
- [ ] More report types (lipid panel, thyroid, etc.)
- [ ] Medication tracking
- [ ] Export to PDF
- [ ] Share with doctors
- [ ] Cloud backup (encrypted)
- [ ] Multi-device sync

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Devasy Patel** ([@Devasy23](https://github.com/Devasy23))

## 🙏 Acknowledgments

- Google Gemini API for AI-powered extraction
- Flutter team for the amazing framework
- FL Chart for beautiful visualizations
- The open-source community

## ⚠️ Disclaimer

This app is for personal health tracking only and should not be used as a substitute for professional medical advice. Always consult with qualified healthcare providers for medical decisions.

---

**Status**: Foundation Complete (40%) | **Next**: UI Implementation (60%)

Made with ❤️ for better health tracking
