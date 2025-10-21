# Code Examples - Quick Reference

This file contains copy-paste ready code examples to help you implement the UI quickly.

## 1. Profile ViewModel

Create `lib/viewmodels/profile_viewmodel.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/database_helper.dart';

class ProfileViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Profile> _profiles = [];
  bool _isLoading = false;
  String? _error;
  
  List<Profile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load all profiles from database
  Future<void> loadProfiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _profiles = await _db.getAllProfiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Create a new profile
  Future<bool> createProfile(Profile profile) async {
    try {
      await _db.insertProfile(profile);
      await loadProfiles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Update existing profile
  Future<bool> updateProfile(Profile profile) async {
    try {
      await _db.updateProfile(profile);
      await loadProfiles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a profile
  Future<bool> deleteProfile(int id) async {
    try {
      await _db.deleteProfile(id);
      await loadProfiles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

## 2. Profile List Screen

Create `lib/views/screens/profile_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/profile.dart';
import '../widgets/profile_card.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  @override
  void initState() {
    super.initState();
    // Load profiles when screen opens
    Future.microtask(
      () => context.read<ProfileViewModel>().loadProfiles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LabLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${viewModel.error}'),
                  ElevatedButton(
                    onPressed: viewModel.loadProfiles,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No profiles yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddProfileDialog(context),
                    child: const Text('Add First Profile'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.profiles.length,
            itemBuilder: (context, index) {
              final profile = viewModel.profiles[index];
              return ProfileCard(
                profile: profile,
                onTap: () {
                  // TODO: Navigate to profile dashboard
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProfileDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final profile = Profile(name: nameController.text);
                final success = await context
                    .read<ProfileViewModel>()
                    .createProfile(profile);
                
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile created!')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
```

## 3. Profile Card Widget

Create `lib/views/widgets/profile_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../models/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Profile info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view reports',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 4. Report ViewModel

Create `lib/viewmodels/report_viewmodel.dart`:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/blood_report.dart';
import '../services/database_helper.dart';
import '../services/gemini_service.dart';
import '../services/loinc_mapper.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final GeminiService _gemini = GeminiService();
  
  bool _isScanning = false;
  String? _error;
  Map<String, dynamic>? _extractedData;
  
  bool get isScanning => _isScanning;
  String? get error => _error;
  Map<String, dynamic>? get extractedData => _extractedData;
  
  /// Scan and extract data from report
  Future<bool> scanReport(File reportFile) async {
    _isScanning = true;
    _error = null;
    _extractedData = null;
    notifyListeners();
    
    try {
      // Extract data using Gemini
      _extractedData = await _gemini.extractWithRetry(reportFile);
      
      _isScanning = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isScanning = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Save extracted data to database
  Future<bool> saveReport({
    required int profileId,
    String? imagePath,
  }) async {
    if (_extractedData == null) return false;
    
    try {
      final testDate = DateTime.parse(_extractedData!['test_date']);
      final parameters = _extractedData!['parameters'] as Map<String, dynamic>;
      
      // Convert to database format
      final dbParameters = <String, Map<String, dynamic>>{};
      parameters.forEach((key, value) {
        final normalizedKey = LOINCMapper.normalize(key);
        dbParameters[normalizedKey] = {
          'value': value['value'],
          'unit': value['unit'],
          'ref_min': value['ref_min'],
          'ref_max': value['ref_max'],
          'raw_name': value['raw_name'] ?? key,
        };
      });
      
      await _db.saveBloodReport(
        profileId: profileId,
        testDate: testDate,
        parameters: dbParameters,
        labName: _extractedData!['lab_name'],
        imagePath: imagePath,
      );
      
      _extractedData = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Clear extracted data
  void clearExtractedData() {
    _extractedData = null;
    _error = null;
    notifyListeners();
  }
}
```

## 5. Scan Report Screen (Simplified)

Create `lib/views/screens/scan_report_screen.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../services/document_picker_service.dart';

class ScanReportScreen extends StatefulWidget {
  final int profileId;
  
  const ScanReportScreen({
    super.key,
    required this.profileId,
  });

  @override
  State<ScanReportScreen> createState() => _ScanReportScreenState();
}

class _ScanReportScreenState extends State<ScanReportScreen> {
  final DocumentPickerService _picker = DocumentPickerService();
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Blood Report'),
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Extracting data...'),
                  Text('This may take 5-10 seconds'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // File preview
                if (_selectedFile != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _picker.isImage(_selectedFile!)
                          ? Image.file(_selectedFile!, fit: BoxFit.contain)
                          : const Center(
                              child: Icon(Icons.picture_as_pdf, size: 64),
                            ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Picker buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final file = await _picker.takePhoto();
                          if (file != null) {
                            setState(() => _selectedFile = file);
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final file = await _picker.pickImageFromGallery();
                          if (file != null) {
                            setState(() => _selectedFile = file);
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    final file = await _picker.pickPDF();
                    if (file != null) {
                      setState(() => _selectedFile = file);
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Select PDF'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Extract button
                if (_selectedFile != null)
                  FilledButton.icon(
                    onPressed: () async {
                      final success = await viewModel.scanReport(_selectedFile!);
                      
                      if (success && context.mounted) {
                        // Save to database
                        final saved = await viewModel.saveReport(
                          profileId: widget.profileId,
                          imagePath: _selectedFile!.path,
                        );
                        
                        if (saved && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report saved successfully!'),
                            ),
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${viewModel.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.scanner),
                    label: const Text('Extract & Save'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## 6. Main.dart with Provider Setup

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/report_viewmodel.dart';
import 'views/screens/profile_list_screen.dart';

void main() {
  runApp(const HealthAnalyzerApp());
}

class HealthAnalyzerApp extends StatelessWidget {
  const HealthAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        // Add more providers as needed
      ],
      child: MaterialApp(
        title: 'LabLens',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const ProfileListScreen(),
      ),
    );
  }
}
```

## 7. Simple Chart Example

Create `lib/views/widgets/blood_parameter_chart.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodParameterChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final String parameterName;
  final double? refMin;
  final double? refMax;

  const BloodParameterChart({
    super.key,
    required this.trendData,
    required this.parameterName,
    this.refMin,
    this.refMax,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: true),
          // Add reference range lines
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (refMin != null)
                HorizontalLine(
                  y: refMin!,
                  color: Colors.red.withOpacity(0.3),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                ),
              if (refMax != null)
                HorizontalLine(
                  y: refMax!,
                  color: Colors.red.withOpacity(0.3),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return trendData.map((data) {
      final date = DateTime.parse(data['test_date']);
      final value = (data['parameter_value'] as num).toDouble();
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        value,
      );
    }).toList();
  }
}
```

## 8. Usage Example - Putting It All Together

```dart
// In your profile dashboard screen:

class ProfileDashboard extends StatelessWidget {
  final int profileId;
  
  const ProfileDashboard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Dashboard')),
      body: Column(
        children: [
          // Show latest report
          FutureBuilder(
            future: DatabaseHelper.instance.getReportsByProfile(profileId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              
              final reports = snapshot.data!;
              if (reports.isEmpty) {
                return const Text('No reports yet');
              }
              
              // Show latest report summary
              return Text('Latest: ${reports.first.testDate}');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanReportScreen(profileId: profileId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## Quick Tips

1. **Copy-paste these examples** into your project
2. **Customize gradually** - start simple, add features later
3. **Test frequently** - run `flutter run` after each change
4. **Use hot reload** - press `r` in terminal after code changes
5. **Check errors** - look at terminal output for issues

## Next Steps

1. Create the ViewModel files
2. Create the screen files
3. Update main.dart with providers
4. Test profile creation
5. Test report scanning
6. Add charts

**You're ready to build! 🚀**
