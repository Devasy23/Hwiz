# Debug Guide: View Report Not Working

## Debug Logging Added ✅

I've added comprehensive debug logging to help identify exactly where the View Report functionality is failing.

---

## What to Do Now

### Step 1: Hot Reload the App
In the terminal where `flutter run` is running, press:
- **`r`** for hot reload (preferred)
- **`R`** for hot restart (if hot reload doesn't work)

Or restart the app completely:
```bash
# Stop the app (Ctrl+C or 'q' in terminal)
flutter run
```

---

### Step 2: Try to View a Report

1. Open the app
2. Go to **Profiles** tab
3. **Tap on a profile card**
4. Bottom sheet appears
5. **Tap "View Reports" button**
6. Try to **tap on a report card**

---

### Step 3: Watch the Console Output

While performing the steps above, **watch the terminal/console** for debug messages:

#### When you tap "View Reports" button:
```
🔵 "View Reports" button tapped
  Profile ID: 1
  Profile Name: John Doe
🔵 Building ReportListScreen...
📊 DEBUG: Loading reports for profile 1
📊 Loading reports for profile 1...
✅ Loaded 2 reports
📄 Report #0: ID=1, Params=15
📄 Report #1: ID=2, Params=12
```

#### When you tap a report card:
```
👆 Report card tapped: Report ID 1
🔍 DEBUG: Attempting to navigate to report detail
  Report ID: 1
  Test Date: 2024-10-15 00:00:00.000
  Lab Name: HealthLab
  Parameters Count: 15
  Image Path: /path/to/image.jpg
✅ Building ReportDetailScreen...
🔍 ReportDetailScreen initialized
  Report ID: 1
  Test Date: 2024-10-15 00:00:00.000
  Lab Name: HealthLab
📋 Loading parameters for report ID: 1
✅ Loaded 15 parameters
  - Hemoglobin: 14.5 g/dL
  - WBC Count: 7200.0 cells/µL
  - RBC Count: 5.2 million/µL
  - Platelet Count: 250000.0 cells/µL
  - Glucose: 95.0 mg/dL
✅ Parameters set in state, UI should update
```

---

## What the Debug Messages Mean

### ✅ Success Messages:
- **🔵** = Navigation started
- **📊** = Loading data
- **✅** = Operation successful
- **📄** = Report found
- **📋** = Parameters loading
- **🔙** = Returned from screen

### ❌ Error Messages:
- **❌** = Something failed
- Look for these patterns:
  - "Navigation error"
  - "Exception during navigation"
  - "Error loading parameters"
  - "Failed to open report"

---

## Common Issues and What to Look For

### Issue 1: Nothing happens when tapping "View Reports"

**Look for in console:**
```
🔵 "View Reports" button tapped
❌ Exception navigating to reports: ...
```

**Possible causes:**
- Profile ID is null
- Navigation context issue
- ReportListScreen import missing

---

### Issue 2: Report List is empty but should have reports

**Look for in console:**
```
📊 DEBUG: Loading reports for profile 1
📊 Loading reports for profile 1...
✅ Loaded 0 reports  ← PROBLEM: Should be > 0
```

**Possible causes:**
- No reports in database for this profile
- Database query filtering incorrectly
- Reports belong to different profile

**To verify:** Check if you've actually scanned any reports for this profile.

---

### Issue 3: Report card tap does nothing

**Look for in console:**
```
👆 Report card tapped: Report ID 1
🔍 DEBUG: Attempting to navigate to report detail
❌ Exception during navigation: ...
```

**Possible causes:**
- Report ID is null
- ReportDetailScreen import missing
- Navigation context issue

---

### Issue 4: Report Detail screen opens but shows nothing

**Look for in console:**
```
🔍 ReportDetailScreen initialized
📋 Loading parameters for report ID: 1
❌ Error loading parameters: ...
```

**Possible causes:**
- Parameters not in database
- Database query error
- Report ID mismatch

---

### Issue 5: Report Detail screen shows loading forever

**Look for in console:**
```
🔍 ReportDetailScreen initialized
📋 Loading parameters for report ID: 1
(... no more messages ...)
```

**Possible causes:**
- `getParametersForReport()` hanging
- Database locked
- Async operation never completing

---

## Specific Things to Tell Me

After performing the steps above, **copy and paste the console output** and tell me:

1. **What step did you reach?**
   - Did you tap "View Reports"? (Yes/No)
   - Did the Report List screen open? (Yes/No)
   - Did you see any reports in the list? (Yes/No)
   - Did you tap a report? (Yes/No)
   - Did the Report Detail screen open? (Yes/No)

2. **What did you see on screen?**
   - Empty list?
   - Loading indicator forever?
   - Error message?
   - Nothing at all?

3. **What does the console say?**
   - Copy the entire console output from when you tapped "View Reports" to when it failed
   - Look for messages with 🔵, 📊, 👆, 🔍, ❌

---

## Quick Verification

### To verify reports exist in database:

**Option A: Using the app**
1. Go to Scan Report screen
2. Scan a new report
3. Then try to view it

**Option B: Check database directly**
```sql
-- Use DB Browser for SQLite to open health_analyzer.db
SELECT r.id, r.test_date, r.lab_name, r.profile_id, COUNT(bp.id) as param_count
FROM reports r
LEFT JOIN blood_parameters bp ON bp.report_id = r.id
GROUP BY r.id
ORDER BY r.test_date DESC;
```

---

## Expected Flow (When Working)

```
User taps profile → Bottom sheet opens
    ↓
User taps "View Reports"
    ↓
🔵 "View Reports" button tapped
🔵 Building ReportListScreen...
    ↓
Report List Screen opens
    ↓
📊 DEBUG: Loading reports for profile X
📊 Loading reports for profile X...
✅ Loaded N reports
    ↓
Reports appear in list
    ↓
User taps a report card
    ↓
👆 Report card tapped: Report ID X
🔍 DEBUG: Attempting to navigate to report detail
✅ Building ReportDetailScreen...
    ↓
Report Detail Screen opens
    ↓
🔍 ReportDetailScreen initialized
📋 Loading parameters for report ID: X
✅ Loaded N parameters
✅ Parameters set in state, UI should update
    ↓
Report details displayed with all parameters
```

---

## Next Steps

1. **Hot reload the app** (press `r` in terminal)
2. **Try to view a report** following the steps above
3. **Watch the console closely**
4. **Copy all console output** from the attempt
5. **Tell me:**
   - What you see on screen
   - What the console says
   - At which step it fails

This will help me pinpoint exactly where the issue is!

---

## Additional Debug Commands

If the app is running, you can also try:

- **`c`** - Clear the console (start fresh)
- **`R`** - Hot restart (full restart while running)
- **`q`** - Quit the app

---

**Remember:** The debug messages with emojis (🔵, 📊, 👆, 🔍, ❌, ✅) are the key to finding the problem!
