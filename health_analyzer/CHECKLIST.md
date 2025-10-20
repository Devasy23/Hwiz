# Implementation Checklist

Use this checklist to track your progress as you build the LabLens app.

## ✅ Phase 0: Foundation (COMPLETED)

- [x] Project structure created
- [x] All models defined (Profile, BloodReport, Parameter)
- [x] Database helper with SQLite implementation
- [x] Gemini AI service for OCR
- [x] LOINC mapper for parameter normalization
- [x] Document picker service
- [x] Constants and configuration
- [x] Dependencies in pubspec.yaml
- [x] Documentation (README, guides)

**Status: 100% Complete** ✅

---

## 🔧 Phase 1: Project Setup

- [ ] Run `flutter create . --project-name health_analyzer`
- [ ] Run `flutter pub get` to install dependencies
- [ ] Get Gemini API key from https://makersuite.google.com/app/apikey
- [ ] Test run: `flutter run`
- [ ] Verify app launches without errors

**Estimated Time: 15 minutes**

---

## 👥 Phase 2: Profile Management

### ViewModels
- [ ] Create `lib/viewmodels/profile_viewmodel.dart`
  - [ ] Add loadProfiles() method
  - [ ] Add createProfile() method
  - [ ] Add updateProfile() method
  - [ ] Add deleteProfile() method
  - [ ] Add error handling
  - [ ] Test with print statements

### UI - Profile List
- [ ] Create `lib/views/screens/profile_list_screen.dart`
  - [ ] Add AppBar with title
  - [ ] Add Consumer<ProfileViewModel>
  - [ ] Show loading indicator
  - [ ] Show error messages
  - [ ] Show empty state
  - [ ] List profiles with ListView.builder
  - [ ] Add FloatingActionButton for new profile

### UI - Profile Card
- [ ] Create `lib/views/widgets/profile_card.dart`
  - [ ] Add avatar with initial
  - [ ] Add profile name
  - [ ] Add tap handler
  - [ ] Add delete option (long press/swipe)

### UI - Add Profile Dialog
- [ ] Create dialog or screen for adding profile
  - [ ] Name TextField
  - [ ] Optional: Date of birth picker
  - [ ] Optional: Gender selector
  - [ ] Save button
  - [ ] Cancel button
  - [ ] Validation

### Integration
- [ ] Update main.dart with ChangeNotifierProvider
- [ ] Test: Create a profile
- [ ] Test: List shows created profile
- [ ] Test: Delete a profile
- [ ] Test: Empty state when no profiles

**Estimated Time: 1-2 days**

---

## 📸 Phase 3: Report Scanning

### ViewModels
- [ ] Create `lib/viewmodels/report_viewmodel.dart`
  - [ ] Add scanReport() method
  - [ ] Add saveReport() method
  - [ ] Add error handling
  - [ ] Add retry logic
  - [ ] Test with sample image

### UI - Profile Dashboard
- [ ] Create `lib/views/screens/profile_dashboard_screen.dart`
  - [ ] Show profile info
  - [ ] Show latest report summary
  - [ ] Show report count
  - [ ] List recent reports
  - [ ] Add FAB for scanning new report
  - [ ] Navigation from profile list

### UI - Scan Report Screen
- [ ] Create `lib/views/screens/scan_report_screen.dart`
  - [ ] File preview area
  - [ ] "Take Photo" button
  - [ ] "Choose from Gallery" button
  - [ ] "Select PDF" button
  - [ ] "Extract Data" button
  - [ ] Loading indicator during scan
  - [ ] Error message display

### UI - Review Data Screen
- [ ] Create `lib/views/screens/review_data_screen.dart`
  - [ ] Show extracted parameters in list
  - [ ] Make values editable (TextField)
  - [ ] Show test date
  - [ ] Show lab name
  - [ ] "Save" button
  - [ ] "Cancel" button
  - [ ] Validation

### Integration
- [ ] Add ReportViewModel to providers
- [ ] Set up API key input (Settings screen or dialog)
- [ ] Test: Pick an image
- [ ] Test: Extract data with Gemini
- [ ] Test: Review extracted data
- [ ] Test: Save to database
- [ ] Test: View saved report in profile

**Estimated Time: 2-3 days**

---

## 📊 Phase 4: Data Visualization

### ViewModels
- [ ] Create `lib/viewmodels/chart_viewmodel.dart`
  - [ ] Add loadTrendData() method
  - [ ] Add parameter selection
  - [ ] Add time range filtering
  - [ ] Calculate statistics (avg, min, max)

### UI - Trend Chart Screen
- [ ] Create `lib/views/screens/trend_chart_screen.dart`
  - [ ] Parameter dropdown selector
  - [ ] Time range picker
  - [ ] Chart display area
  - [ ] Latest value display
  - [ ] Reference range indicator
  - [ ] Export button (optional)

### UI - Blood Parameter Chart Widget
- [ ] Create `lib/views/widgets/blood_parameter_chart.dart`
  - [ ] Implement LineChart with FL Chart
  - [ ] Add data points
  - [ ] Add trend line
  - [ ] Add reference range lines
  - [ ] Add date labels on X-axis
  - [ ] Add value labels on Y-axis
  - [ ] Add tooltips on tap
  - [ ] Style and colors

### UI - Parameter List Item
- [ ] Create `lib/views/widgets/parameter_list_item.dart`
  - [ ] Show parameter name
  - [ ] Show latest value
  - [ ] Show trend indicator (↑↓→)
  - [ ] Show status (normal/abnormal)
  - [ ] Tap to open chart

### Integration
- [ ] Add ChartViewModel to providers
- [ ] Link from profile dashboard to trend screen
- [ ] Test: View chart for RBC count
- [ ] Test: Select different parameters
- [ ] Test: Change time range
- [ ] Test: Multiple data points display correctly

**Estimated Time: 2-3 days**

---

## ⚙️ Phase 5: Settings & Configuration

### UI - Settings Screen
- [ ] Create `lib/views/screens/settings_screen.dart`
  - [ ] API key input field
  - [ ] Test API key button
  - [ ] Theme selector (light/dark)
  - [ ] About section
  - [ ] Version info
  - [ ] Privacy policy link

### Features
- [ ] API key management
  - [ ] Save to secure storage
  - [ ] Validate before saving
  - [ ] Show masked key
- [ ] Data management
  - [ ] Export all data (JSON)
  - [ ] Import data
  - [ ] Clear all data (with confirmation)
- [ ] App info
  - [ ] Version number
  - [ ] Credits
  - [ ] Help/FAQ

**Estimated Time: 1 day**

---

## 🎨 Phase 6: Polish & UX

### Visual Improvements
- [ ] Add app icon
- [ ] Add splash screen
- [ ] Consistent color scheme
- [ ] Typography refinement
- [ ] Animations (page transitions)
- [ ] Loading states everywhere
- [ ] Empty states with helpful messages
- [ ] Success animations

### Error Handling
- [ ] User-friendly error messages
- [ ] Retry buttons where appropriate
- [ ] Offline mode indicators
- [ ] Network error handling
- [ ] API quota exceeded handling

### Performance
- [ ] Image compression
- [ ] Database query optimization
- [ ] Lazy loading for long lists
- [ ] Debounce search/filter inputs

### Accessibility
- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Font size scaling
- [ ] Touch target sizes (48dp minimum)

**Estimated Time: 1-2 days**

---

## 🧪 Phase 7: Testing

### Unit Tests
- [ ] Test Profile model serialization
- [ ] Test BloodReport model
- [ ] Test Parameter model
- [ ] Test LOINCMapper.normalize()
- [ ] Test DatabaseHelper CRUD operations
- [ ] Test GeminiService extraction (mocked)

### Widget Tests
- [ ] Test ProfileListScreen
- [ ] Test ProfileCard widget
- [ ] Test ScanReportScreen
- [ ] Test BloodParameterChart
- [ ] Test navigation flows

### Integration Tests
- [ ] Test complete scan workflow
- [ ] Test profile creation to report viewing
- [ ] Test data persistence across app restarts

### Manual Testing
- [ ] Test on Android device
- [ ] Test on iOS device (if available)
- [ ] Test with real blood reports
- [ ] Test with poor quality images
- [ ] Test with multiple profiles
- [ ] Test with many reports (performance)

**Estimated Time: 1-2 days**

---

## 🚀 Phase 8: Deployment Prep

### Android
- [ ] Update app name in AndroidManifest.xml
- [ ] Update app icon
- [ ] Add required permissions
- [ ] Set minimum SDK version
- [ ] Sign app with keystore
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test release build

### iOS (if applicable)
- [ ] Update app name in Info.plist
- [ ] Update app icon
- [ ] Add usage descriptions
- [ ] Set deployment target
- [ ] Configure signing
- [ ] Build release: `flutter build ios --release`

### Documentation
- [ ] Update README with final features
- [ ] Add user manual
- [ ] Add troubleshooting guide
- [ ] Add screenshots
- [ ] Record demo video

**Estimated Time: 1 day**

---

## 🎯 Optional Enhancements (Future)

### Advanced Features
- [ ] Cloud backup (encrypted)
- [ ] Multi-device sync
- [ ] Share reports with doctors (PDF export)
- [ ] Medication tracking
- [ ] Appointment reminders
- [ ] Support for more report types
  - [ ] Lipid panel
  - [ ] Thyroid function
  - [ ] Liver function
  - [ ] Kidney function
- [ ] AI health insights
- [ ] Correlate parameters (e.g., WBC vs Neutrophils)

### Technical Improvements
- [ ] Offline queue for scans
- [ ] Background processing
- [ ] Push notifications
- [ ] Widget for home screen
- [ ] Wear OS / Apple Watch app

---

## 📊 Progress Tracker

| Phase | Status | Completion | Time Spent |
|-------|--------|------------|------------|
| 0. Foundation | ✅ Done | 100% | 4 hours |
| 1. Project Setup | ⏳ Pending | 0% | - |
| 2. Profile Management | ⏳ Pending | 0% | - |
| 3. Report Scanning | ⏳ Pending | 0% | - |
| 4. Visualization | ⏳ Pending | 0% | - |
| 5. Settings | ⏳ Pending | 0% | - |
| 6. Polish | ⏳ Pending | 0% | - |
| 7. Testing | ⏳ Pending | 0% | - |
| 8. Deployment | ⏳ Pending | 0% | - |
| **TOTAL** | **🟡 In Progress** | **40%** | **4 hours** |

---

## 🎓 Learning Checkpoints

As you build, make sure you understand:

- [ ] How Flutter widgets work
- [ ] State management with Provider
- [ ] Async/await and Futures
- [ ] SQLite database operations
- [ ] API integration
- [ ] File handling
- [ ] Navigation in Flutter
- [ ] Error handling patterns
- [ ] Testing basics

---

## 💡 Tips for Success

1. **Work in small increments** - Complete one checkbox at a time
2. **Test frequently** - Run the app after each feature
3. **Commit often** - Use git to save your progress
4. **Don't skip error handling** - Handle errors early
5. **Ask for help** - Use GitHub issues, Stack Overflow
6. **Take breaks** - Coding marathons lead to bugs
7. **Celebrate wins** - Check off those boxes! 🎉

---

## 🆘 When You Get Stuck

1. **Read the error message** - It usually tells you what's wrong
2. **Check documentation** - Flutter docs are excellent
3. **Search Stack Overflow** - Someone has had your problem
4. **Look at examples** - See CODE_EXAMPLES.md
5. **Debug step by step** - Use print statements
6. **Start fresh** - Sometimes a restart helps
7. **Ask the community** - Flutter Discord, Reddit

---

## 🎉 Completion Criteria

Your app is done when:

- ✅ All checkboxes in Phases 1-7 are checked
- ✅ You can create profiles
- ✅ You can scan and save blood reports
- ✅ You can view trend charts
- ✅ The app handles errors gracefully
- ✅ Tests are passing
- ✅ App runs on a real device
- ✅ Your father can use it! 👨‍⚕️

---

**Current Status: Foundation Complete (40%)** 🚀

**Next Milestone: Complete Phase 1 (Profile Management)** 👥

**Estimated Time to MVP: 2 weeks** ⏰

**You're doing great! Keep going!** 💪
