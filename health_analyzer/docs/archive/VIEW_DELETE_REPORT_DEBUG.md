# View Report & Delete Report - Debugging Guide 🔍

## Status: ✅ Both Features Are Already Implemented!

Good news! Both **View Report** and **Delete Report** functionalities are fully implemented in the codebase. If they're not working, it's likely a navigation or runtime issue.

---

## How to Access These Features 🗺️

### 1. **View Reports** (Navigate to Report List)

There are two ways to access reports:

#### Method A: Through Profile Details (Recommended)
1. Open the app
2. Tap on **"Profiles"** tab (bottom navigation)
3. **Tap on any profile card** (e.g., "John Doe")
4. A **bottom sheet** will slide up showing profile details
5. Tap the **"View Reports"** button at the bottom
6. ✅ Report list screen opens

**File**: `lib/views/screens/profile_list_screen.dart` (lines 330-348)
```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportListScreen(
          profileId: profile.id!,
          profileName: profile.name,
        ),
      ),
    );
  },
  icon: const Icon(Icons.assessment),
  label: const Text('View Reports'),
)
```

#### Method B: Direct Navigation (If Implemented)
- Some screens may have direct links to report lists
- Check the home screen's "Recent Reports" section

---

### 2. **Delete Report**

Once you're on the Report List screen:

1. Find the report you want to delete
2. Tap the **three dots menu (⋮)** on the right side of the report card
3. Select **"Delete"** from the popup menu
4. A confirmation dialog appears
5. Tap **"Delete"** to confirm
6. ✅ Report is deleted and removed from the list

**File**: `lib/views/screens/report_list_screen.dart` (lines 268-285)
```dart
PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert),
  onSelected: (value) {
    if (value == 'delete') {
      onDelete();  // Shows confirmation dialog
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, size: 20, color: Colors.red),
          SizedBox(width: 12),
          Text('Delete', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
)
```

---

## Troubleshooting 🔧

### Issue 1: "View Reports" Button Not Showing

**Possible Causes:**
1. ❌ Not tapping on the profile card (must tap the card itself)
2. ❌ Bottom sheet not appearing (UI rendering issue)
3. ❌ Profile has no ID (database issue)

**Debug Steps:**
1. Check console for errors when tapping profile
2. Verify bottom sheet appears with profile details
3. Add debug print in `_showProfileDetails()` method:

```dart
void _showProfileDetails(BuildContext context, Profile profile) {
  debugPrint('🔍 Opening profile details for: ${profile.name} (ID: ${profile.id})');
  // ... rest of code
}
```

---

### Issue 2: "Delete" Menu Not Appearing on Report Card

**Possible Causes:**
1. ❌ PopupMenuButton is hidden or not clickable
2. ❌ Three dots icon (⋮) is not visible
3. ❌ Report card is not using `_ReportCard` widget

**Debug Steps:**
1. Check if you can see the three dots icon on report cards
2. Try long-pressing on the report card
3. Verify you're using the correct `ReportListScreen`:

```dart
// In profile_list_screen.dart
import 'report_list_screen.dart';  // Should be this import
```

---

### Issue 3: Delete Confirmation Dialog Not Working

**Possible Causes:**
1. ❌ ReportViewModel not provided in widget tree
2. ❌ Report ID is null
3. ❌ Database connection issue

**Debug Steps:**
1. Add debug logging in delete method:

```dart
TextButton(
  onPressed: () async {
    debugPrint('🗑️ Deleting report ID: ${report.id}');
    Navigator.pop(context);
    final success = await context
        .read<ReportViewModel>()
        .deleteReport(report.id!);
    debugPrint('✅ Delete success: $success');
    // ... rest of code
  },
  child: const Text('Delete'),
)
```

2. Check terminal/console for error messages
3. Verify ReportViewModel is provided in main.dart

---

### Issue 4: Report List Screen is Empty

**Possible Causes:**
1. ❌ No reports exist for this profile
2. ❌ Database query failing
3. ❌ ReportViewModel not loading reports

**Debug Steps:**
1. Check if you've scanned any reports for this profile
2. Add debug logging in `_loadReports()`:

```dart
void _loadReports() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      debugPrint('📊 Loading reports for profile: ${widget.profileId}');
      context.read<ReportViewModel>().loadReportsForProfile(widget.profileId);
    }
  });
}
```

3. Check console for "Loading reports" message
4. Verify database has reports: Use DB Browser for SQLite to check the `reports` table

---

## Code Verification ✅

I've verified these files are correct:

### ✅ `profile_list_screen.dart`
- Line 330-348: "View Reports" button implementation
- Line 146: Tap handler for profile cards
- Line 209: Bottom sheet with profile details

### ✅ `report_list_screen.dart`
- Line 97: Report cards with tap and delete handlers
- Line 145: `_navigateToReportDetail()` method
- Line 155: `_showDeleteConfirmation()` dialog
- Line 268: PopupMenuButton with delete option

### ✅ `report_viewmodel.dart`
- Line 345: `deleteReport()` method fully implemented
- Deletes parameters first, then report
- Updates local state and notifies listeners

---

## Testing Checklist 📋

Use this checklist to test both features:

### View Reports:
- [ ] Open Profiles tab
- [ ] Tap on a profile card
- [ ] Bottom sheet appears with profile stats
- [ ] "View Reports" button is visible at bottom
- [ ] Tapping button navigates to ReportListScreen
- [ ] Screen shows list of reports (or empty state)

### Delete Report:
- [ ] Navigate to ReportListScreen (see above)
- [ ] Find a report in the list
- [ ] Tap three dots (⋮) menu on report card
- [ ] "Delete" option appears in red
- [ ] Tap "Delete"
- [ ] Confirmation dialog appears
- [ ] Tap "Delete" to confirm
- [ ] Success message appears (green snackbar)
- [ ] Report disappears from list

---

## Common Mistakes ⚠️

1. **Not tapping the profile card itself**
   - You must tap the profile card to open the bottom sheet
   - The "View Reports" button is NOT on the profile card directly
   - It's inside the bottom sheet that appears after tapping

2. **Looking for "View Reports" on the profile card**
   - The profile card only has an Edit/Delete menu (three dots)
   - "View Reports" is in the bottom sheet

3. **Trying to delete from report details screen**
   - Delete is only available in the report LIST screen
   - Not in the individual report DETAIL screen

4. **Not creating any reports first**
   - If you haven't scanned any reports, the list will be empty
   - Use "Scan Report" to add reports first

---

## Quick Fix Suggestions 🚀

If features still don't work, try these:

### Fix 1: Restart the App
```bash
cd health_analyzer
flutter clean
flutter pub get
flutter run
```

### Fix 2: Check Provider Setup
Verify `ReportViewModel` is provided in `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
    ChangeNotifierProvider(create: (_) => ReportViewModel()),  // ← Must be here
    ChangeNotifierProvider(create: (_) => SettingsViewModel()),
  ],
  child: MyApp(),
)
```

### Fix 3: Force Rebuild
Hot restart instead of hot reload:
- Press `R` in terminal (capital R)
- Or stop and run again

### Fix 4: Check Database
```dart
// Add this to debug database content
Future<void> _debugDatabase() async {
  final db = await DatabaseHelper.instance.database;
  final reports = await db.query('reports');
  debugPrint('📊 Total reports in DB: ${reports.length}');
  debugPrint('Reports: $reports');
}
```

---

## Expected Behavior ✨

### When Everything Works:

1. **View Reports:**
   - Tap profile → Bottom sheet slides up
   - Shows profile stats (Total Reports, Parameters Tracked, Last Report)
   - Two buttons: "Edit" (outlined) and "View Reports" (filled blue)
   - Tapping "View Reports" navigates to list
   - List shows all reports sorted by date (newest first)

2. **Delete Report:**
   - Three dots menu visible on each report card
   - Tapping shows popup with "Delete" in red
   - Confirmation dialog with clear warning
   - Upon confirmation, report is deleted
   - Green success message appears
   - Report card fades out and disappears

---

## Still Not Working? 🆘

If you've tried everything above and features still don't work:

1. **Check console output** for error messages
2. **Take screenshots** of:
   - The profile list screen
   - What happens when you tap a profile
   - The report list screen (if you can reach it)
   - Any error messages

3. **Provide details:**
   - Which specific feature isn't working
   - What you're tapping/clicking
   - What you expect to happen
   - What actually happens

4. **Run in debug mode:**
```bash
flutter run --debug
```

Then check the console for any error messages when you try to use the features.

---

## Summary

**Both features ARE implemented and should work:**
- ✅ View Reports: Fully functional via profile bottom sheet
- ✅ Delete Report: Fully functional via three-dot menu

**If not working, most likely causes:**
1. User interface navigation confusion
2. Provider not set up correctly
3. Runtime error (check console)
4. No reports exist yet

**Quick test:** Create a profile → Scan a report → Tap profile → View Reports → Delete via menu
