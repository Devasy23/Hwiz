# How to View Trend Charts - User Guide

## 📊 Quick Start Guide

There are **two ways** to view trend charts in the Health Analyzer app:

---

## Method 1: View All Parameter Trends (From Report)

### Steps:
1. **Open the app** and navigate to your reports list
2. **Tap on any report** to open the Report Detail Screen
3. **Look at the top-right** of the screen (in the app bar)
4. **Tap the Timeline icon** (⏱️ clock/timeline symbol)
5. You'll see the **Parameter Trend Screen** with:
   - A dropdown to select different parameters
   - Time range filters (3M, 6M, 1Y, All)
   - Interactive line chart
   - Statistics panel at the bottom

### What You'll See:
```
┌─────────────────────────────────┐
│ ← Profile's Trends        ⏱️ 🔲 │ ← Timeline icon here
├─────────────────────────────────┤
│ Select Parameter                │
│ ▼ Hemoglobin                    │
├─────────────────────────────────┤
│ [3M] [6M] [1Y] [All]           │ ← Time filters
├─────────────────────────────────┤
│                                 │
│      Chart showing trend        │
│         📈                      │
│                                 │
├─────────────────────────────────┤
│ Statistics Summary              │
│ Latest | Avg | Min | Max       │
│ Trend: ↗️ 5.2% increase         │
└─────────────────────────────────┘
```

---

## Method 2: View Specific Parameter Trend (Quick Access)

### Steps:
1. **Open any report** to see the list of parameters
2. **Tap directly on any parameter card** (e.g., "Hemoglobin")
3. The trend chart for **that specific parameter** will open immediately
4. You'll see the same Parameter Trend Screen, but pre-selected to show that parameter

### Visual Indicator:
Each parameter card has a **small chart icon** (📈) on the right side indicating it's tappable for trends.

```
┌─────────────────────────────────┐
│ Hemoglobin                📈    │ ← Click anywhere on card
│ Haemoglobin                     │
│                          [HIGH] │
│ Value: 18.5 gm%                 │
│ Reference: 13.5 - 18.0          │
└─────────────────────────────────┘
```

---

## 🎯 Using the Trend Chart Screen

### Top Section - Parameter Selection
- **Dropdown Menu**: Shows all available parameters from your reports
- **Tap to change**: Select different parameters to view their trends
- Example: Switch from "Hemoglobin" to "WBC Count"

### Time Range Filters
Click on any chip to filter the data:
- **3M** (3 Months): Shows last 90 days
- **6M** (6 Months): Shows last 180 days  
- **1Y** (1 Year): Shows last 365 days
- **All**: Shows complete history

### The Chart Itself

#### Understanding the Chart:
- **Blue Line**: Your actual values over time
- **Blue Dots (white center)**: Normal values (within reference range)
- **Red Dots**: Abnormal values (outside reference range)
- **Orange Dashed Lines**: Reference range boundaries
  - Upper line = Maximum normal value
  - Lower line = Minimum normal value
- **Shaded Area**: Light blue area below your trend line

#### Interactive Features:
1. **Tap on any dot** to see:
   - Exact date
   - Exact value with unit
   - Popup tooltip appears

2. **Toggle Reference Ranges**:
   - Tap the **grid icon** (🔲) in top-right
   - Hides/shows the orange reference lines

### Statistics Panel (Bottom)

Shows four key metrics:
```
┌──────────────────────────────────┐
│ Latest    Average    Min    Max  │
│  18.5      17.2     15.8   18.5  │
│  gm%       gm%      gm%    gm%   │
├──────────────────────────────────┤
│ Trend: ↗️ 12.3% increase         │
└──────────────────────────────────┘
```

- **Latest**: Most recent measurement
- **Average**: Mean of all values in selected time range
- **Min**: Lowest value recorded
- **Max**: Highest value recorded
- **Trend**: Percentage change from first to latest value
  - Green ↗️ = Increase
  - Red ↘️ = Decrease

---

## 📋 Requirements to View Trends

### Minimum Requirements:
1. **At least 2 scanned reports** in your profile
2. **Same parameter** must appear in at least 2 reports
3. Reports must be from **different dates**

### If You See "No Data Available":
- You need to scan more reports
- Message will say: "Scan at least 2 reports to view trends"

### If You See "No Trend Data":
- The selected parameter only appears in 1 report
- Try selecting a different parameter
- Scan more reports that include this parameter

---

## 💡 Tips for Best Results

### 1. **Regular Scanning**
- Scan reports consistently (monthly/quarterly)
- More data points = better trend visualization
- Helps identify long-term patterns

### 2. **Parameter Selection**
- Start with common parameters like Hemoglobin, WBC Count
- These usually appear in all CBC reports
- Build up data over time

### 3. **Time Range Usage**
- Use **3M** for recent changes
- Use **6M** for seasonal patterns
- Use **1Y** for annual checkups
- Use **All** for complete health journey

### 4. **Reading Trends**
- **Flat line**: Stable values (good for most parameters)
- **Upward trend**: Increasing values
  - Good: HDL cholesterol, hemoglobin (if was low)
  - Bad: LDL cholesterol, blood sugar
- **Downward trend**: Decreasing values
  - Good: LDL cholesterol, triglycerides
  - Bad: Hemoglobin, WBC count (if too low)

### 5. **Reference Ranges**
- Orange lines show what's "normal"
- Values between lines = healthy
- Values outside = discuss with doctor
- Ranges may vary by age, gender, lab

---

## 🎨 Visual Guide - Step by Step

### Starting Point: Reports List
```
My Reports
┌─────────────────────────────┐
│ Jan 17, 2022               │
│ SADKARYA SEVA SANGH        │ ← Tap to open
│ 38 parameters              │
└─────────────────────────────┘
```

### Report Detail Screen
```
Report Details         ⏱️ 🖼️
┌─────────────────────────────┐
│ Test Date: January 17, 2022│
│ Lab: SADKARYA SEVA SANGH   │
├─────────────────────────────┤
│ Abnormal Values (3)        │
├─────────────────────────────┤
│ Hemoglobin           📈     │ ← Option 1: Tap card
│ 11.7 gm%          [LOW]    │
├─────────────────────────────┤
│ ...more parameters...      │
└─────────────────────────────┘
         ↑
    Option 2: Tap ⏱️ icon above
```

### Trend Chart Screen
```
Profile's Trends      🔲
┌─────────────────────────────┐
│ Select Parameter           │
│ ▼ Hemoglobin              │
├─────────────────────────────┤
│ [3M] [6M] [1Y] [All]      │
├─────────────────────────────┤
│        📈 Chart            │
│   ●─────●─────●            │
│   │     │     │            │
│ ──┼─────┼─────┼── Max     │
│   │     │ ●   │            │
│   │ ●   │     │            │
│ ──┼─────┼─────┼── Min     │
├─────────────────────────────┤
│ Latest  Avg   Min   Max   │
│  15.2   14.8  13.1  15.2  │
│                            │
│ Trend: ↗️ 8.5% increase    │
└─────────────────────────────┘
```

---

## ❓ Troubleshooting

### "I don't see the timeline icon"
- Make sure you're on the **Report Detail** screen (after tapping a report)
- Look in the **top-right corner** of the app bar
- It's next to the image icon (if report has an image)

### "Nothing happens when I tap a parameter card"
- Ensure you have **at least 2 reports** scanned
- The parameter must exist in **multiple reports**
- Try tapping in the middle of the card

### "Chart shows only one point"
- You need at least 2 data points for a trend
- Scan another report with the same parameter
- Or select a different parameter that has more data

### "Reference ranges not showing"
- Some parameters don't have reference ranges
- Toggle might be off - tap the grid icon (🔲)
- Original report might not have included ranges

### "Chart looks empty"
- Try switching to "All" time range
- Your reports might be older than selected range
- Scan more recent reports

---

## 🎓 Understanding Your Results

### Green Trend (Good)
- Values improving toward normal
- Staying within healthy range
- Consistent, stable readings

### Red Trend (Needs Attention)
- Values moving away from normal
- Crossing reference range boundaries
- Large fluctuations between tests

### Yellow Trend (Monitor)
- Close to reference range edges
- Slight variations
- May need lifestyle adjustments

### Important Note:
**Always consult with your doctor** about:
- Abnormal trends
- Sudden changes
- Values outside reference ranges
- Health concerns or symptoms

This app is for **tracking and visualization** only, not for medical diagnosis!

---

## 🚀 Quick Reference

| To Do This | Do That |
|-----------|---------|
| View all trends | Open report → Tap ⏱️ icon |
| View specific parameter | Tap on parameter card |
| Change parameter | Use dropdown at top |
| Change time range | Tap 3M/6M/1Y/All chips |
| See exact value | Tap on any dot in chart |
| Toggle reference lines | Tap 🔲 icon |
| Go back | Tap ← back button |

---

**Need more reports to see trends?** 
Scan your blood reports using the scan button and build up your health history! 📊💪
