# LabLens Test Suite

Comprehensive test suite for the LabLens health analyzer application.

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate mocks
flutter pub run build_runner build

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Test Files

| File | Description | Tests |
|------|-------------|-------|
| `models_test.dart` | Data model tests (Parameter, BloodReport, Profile) | 45 |
| `api_key_service_test.dart` | API key management and validation | 15 |
| `data_export_import_service_test.dart` | Data export/import functionality | 10 |
| `gemini_service_test.dart` | Gemini AI service integration | 8 |
| `widgets_test.dart` | UI component tests | 50 |
| `widget_test.dart` | Main app smoke test | 1 |

## Running Tests

### All Tests
```bash
flutter test
```

### Specific File
```bash
flutter test test/models_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Generating Mocks

Some tests require mock classes:

```bash
flutter pub run build_runner build
```

## Next Steps

1. Navigate to health_analyzer directory
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build`
4. Run `flutter test`

For detailed documentation, see TEST_SUMMARY.md