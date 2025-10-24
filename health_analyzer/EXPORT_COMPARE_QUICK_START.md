# Quick Start Guide - Compare & Export Features

## 🎯 Quick Access

Both features are accessible from the **Home Tab** top bar:
- **Compare icon** (⇄): Compare any 2 reports
- **Import/Export icon** (⇅): Manage your data

---

## 📊 Compare Reports

### When to Use
- Track improvement over time
- See which parameters changed
- Identify trends (better/worse)
- Review treatment effectiveness

### How to Compare
1. Make sure your profile has **at least 2 reports**
2. Tap the **compare icon (⇄)** in top bar
3. Two most recent reports are auto-selected
4. Tap report cards to change selection
5. Scroll through parameter comparisons

### Understanding the Comparison
- **Green values**: Normal range
- **Red values**: High (above range)
- **Orange values**: Low (below range)
- **↑ arrow**: Value increased
- **↓ arrow**: Value decreased
- **→ arrow**: No change

### Example
```
Hemoglobin
Report 1: 12.5 g/dL (Low) ⚠️
Report 2: 14.2 g/dL (Normal) ✓
Trend: ↑ (Improved!)
```

---

## 💾 Export Your Data

### Export Current Profile (Complete Backup)
**Format**: JSON  
**Contains**: Profile + ALL reports  
**Best For**: Full backup, switching devices

**Steps**:
1. Tap **import/export icon (⇅)**
2. Select "Export Current Profile"
3. Choose where to save/share
4. Done! File saved as: `[Name]_complete_[timestamp].json`

### Export Single Report
**Format**: CSV  
**Contains**: One report's parameters  
**Best For**: Sharing with doctor, Excel analysis

**Steps**:
1. Tap **import/export icon (⇅)**
2. Select "Export Single Report (CSV)"
3. Pick the report from list
4. Share via any app
5. File saved as: `report_[ID].csv`

### Export All Reports (Bulk CSV)
**Format**: CSV  
**Contains**: All reports in one file  
**Best For**: Spreadsheet analysis, trends

**Steps**:
1. Tap **import/export icon (⇅)**
2. Select "Export All Reports (CSV)"
3. Share or save
4. File saved as: `[Name]_reports_[timestamp].csv`

---

## 📥 Import Data

### Import Complete Profile
**Format**: JSON  
**Use Case**: Restore backup, transfer from another device

**Steps**:
1. Tap **import/export icon (⇅)**
2. Select "Import Complete Profile"
3. Pick your JSON file
4. Wait for import (shows progress)
5. New profile created with all reports!

**Example**:
```json
{
  "profile": {
    "name": "John Doe",
    "dateOfBirth": "1990-01-01",
    ...
  },
  "reports": [...]
}
```

### Import Reports (CSV)
**Format**: CSV  
**Use Case**: Add bulk reports to existing profile

**Steps**:
1. **Select a profile first**
2. Tap **import/export icon (⇅)**
3. Select "Import Reports (CSV)"
4. Pick your CSV file
5. Reports added to current profile!

**CSV Format**:
```csv
Report ID,Test Date,Lab Name,Parameter,Value,Unit,Ref Min,Ref Max,Status
1,2024-01-15,LabCorp,Hemoglobin,14.5,g/dL,13.0,17.0,normal
```

---

## ⚠️ Important Notes

### File Formats
- **JSON**: Use for complete backups (profile + reports)
- **CSV**: Use for spreadsheet analysis or bulk imports

### Before Import
- ✓ Make sure file format is correct
- ✓ Check that dates are in proper format
- ✓ Verify parameter names match expected format

### After Export
- Files are temporary - **save them** somewhere permanent
- You can share directly via messaging/email apps
- CSV files open in Excel, Google Sheets, etc.

### Security
- Exported files contain sensitive health data
- Store them securely
- Don't share publicly
- Delete after importing if no longer needed

---

## 💡 Pro Tips

### Comparing Reports
1. **Time-based**: Compare reports 3-6 months apart to see real trends
2. **Post-treatment**: Compare before/after medication or lifestyle changes
3. **Multiple parameters**: Focus on related parameters (e.g., all cholesterol values)

### Exporting Data
1. **Regular backups**: Export complete profile monthly
2. **Doctor visits**: Export latest report as CSV before appointments
3. **Family sharing**: Export and share with family members' devices

### Importing Data
1. **Restore**: If you switch phones, just import your JSON backup
2. **Merge data**: Import CSV to add missing reports without duplicating profile
3. **Test imports**: Try with a small CSV first to verify format

---

## 🐛 Troubleshooting

### "Need More Reports" on Compare
- You need at least 2 reports to compare
- Add more reports by scanning new blood tests

### "No file selected" on Import
- File picker was cancelled
- Try again and select a file

### "Invalid file format" on Import
- Check that JSON structure matches expected format
- For CSV, verify column headers match exactly
- Date format should be: `YYYY-MM-DD` or ISO 8601

### "Import failed" Error
- File might be corrupted
- Check JSON syntax with a validator
- For CSV, ensure no missing required columns

### Compare Screen Blank
- Both reports must be selected
- Tap the report cards to choose reports
- If still blank, check that reports have parameters

---

## 📱 Sharing Options

After exporting, you can share via:
- ✉️ Email
- 💬 WhatsApp, Telegram, etc.
- 📁 Save to Files/Downloads
- ☁️ Google Drive, Dropbox, OneDrive
- 💻 Nearby Share (Android)
- 🔗 Any app that accepts files

---

## ✅ Success Indicators

### Successful Export
- ✓ "Exported successfully!" message
- ✓ Share dialog appears
- ✓ File can be opened in appropriate app

### Successful Import
- ✓ "Imported [Name/X reports]!" message  
- ✓ New profile appears in list (for profile import)
- ✓ Report count increases (for CSV import)
- ✓ Data visible immediately

---

## 🎓 Real-World Examples

### Example 1: Tracking Diabetes
**Goal**: See if blood sugar improving  
**Steps**:
1. Have reports from last 6 months
2. Compare oldest vs newest
3. Look at HbA1c, Glucose trends
4. Export all to CSV for doctor

### Example 2: Family Health Records
**Goal**: Keep records for entire family  
**Steps**:
1. Create profile for each family member
2. Export each profile regularly (monthly)
3. Store JSON files in secure cloud folder
4. Easy to restore or share if needed

### Example 3: Second Opinion
**Goal**: Share with new doctor  
**Steps**:
1. Export latest 3-6 months reports as CSV
2. Email or print for appointment
3. Easy to read in spreadsheet format
4. Doctor can import to their system

---

**Need Help?**
- Check the main README.md for general app usage
- Review COMPONENT_GUIDE.md for UI elements
- See ARCHITECTURE.md for technical details

---

**Feature Version**: 1.0  
**Last Updated**: 2024
