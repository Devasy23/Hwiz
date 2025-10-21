## **LabLens - Simplified User Flow Design**

### **Revised Screen Flow Architecture:**

```
[Onboarding] → [API Setup] → [Home] ⟷ [Settings]
                                ↓
                          [Report Scan]
                                ↓
                          [Report Details] → [Parameter Trend & Insights]
```

---

### **Detailed Screen-by-Screen Flow:**

#### **1. Onboarding Screens (First Launch Only)**
- **Screen 1.1: Welcome**
  - App logo + tagline: "Your Family's Health, Tracked & Analyzed"
  - Brief 3-slide carousel: Scan → Extract → Track → Insights
  - CTA: "Get Started"

- **Screen 1.2: API Key Setup**
  - Title: "Connect Your AI Engine"
  - Input field: "Enter Gemini API Key"
  - Help text: "Your key stays on your device. We never store it."
  - Link: "How to get API key?"
  - CTA: "Continue"

- **Screen 1.3: Create First Profile**
  - "Let's create your first profile"
  - Name (text input)
  - Date of Birth (date picker)
  - Relationship (dropdown: Self, Spouse, Parent, Child, Other)
  - CTA: "Start Using LabLens"

---

#### **2. Home Screen (Main Screen)**

**Top Bar:**
- App logo/name (left)
- **Profile Switcher (right):** 
  - Shows current profile avatar/initials in colored circle
  - Displays name below avatar (small text)
  - Tap → Opens profile switcher bottom sheet

**Profile Switcher Bottom Sheet:**
- List of all family members with:
  - Avatar/initials
  - Name + Age
  - Last report date (if any)
- "➕ Add New Member" button at bottom
- Tap member → Switches active profile, refreshes home content

**Home Content (For Selected Profile):**

**Section 1: Profile Summary Card**
- Member name + age
- Total reports count
- Last test date
- "Edit Profile" button (opens edit form)

**Section 2: Recent Reports List**
- Shows all reports for current profile (sorted newest first)
- Each report card shows:
  - **Header:** Test date (large) + Lab name (small)
  - **Quick Stats:** "12 parameters | 2 abnormal"
  - **Status Badge:** Color-coded pill (All Normal / Has Abnormal)
  - **Visual:** Small sparkline/mini-chart showing trend
- Empty state: "No reports yet. Tap + to scan your first report"

**Section 3: Health Highlights (if reports exist)**
- "⚠️ Parameters Needing Attention" (collapsible)
  - Shows abnormal parameters across all reports
  - Each item: Parameter name, latest value, status
  - Tap → Opens Parameter Trend Screen
- "✓ Recent Improvements" (collapsible, optional)
  - Parameters that improved since last report

**Bottom Navigation Bar:**
- **Home** (active) - House icon
- **Settings** - Gear icon

**FAB (Floating Action Button):**
- Large circular "+" button (bottom right)
- Primary color with slight elevation/shadow
- Tap → Report Scan Screen

**Navigation from Home:**
- Tap report card → Report Details Screen
- Tap abnormal parameter → Parameter Trend Screen
- Tap profile switcher → Switch profile
- Tap FAB → Report Scan Screen
- Tap Settings tab → Settings Screen

---

#### **3. Report Scan Screen**

**Header:**
- Back button
- Title: "Scan Report"
- Current profile indicator (small chip showing name + avatar)

**Content:**
- Large info text: "Scanning for: [Member Name]"
- Switch profile link (if user wants to change)

**Scan Options (3 Large Buttons/Cards):**
- 📷 **Take Photo** - "Use Camera"
- 🖼️ **From Gallery** - "Choose Image"
- 📄 **Upload PDF** - "Select PDF File"

**Flow:**
- User taps scan option → Camera/Gallery/File picker opens
- After selection → **Processing Screen**
  - Full-screen loading indicator
  - "Analyzing report..."
  - "Extracting parameters..."
  - Progress indicator or animated scan effect
- → **Report Details Screen** (newly created report)

---

#### **4. Report Details Screen**

**Header:**
- Back button
- Test date (large)
- Lab name (small, below date)
- Menu (⋮): Options
  - Delete report
  - View raw image/PDF

**Top Summary Card:**
- **Member Info:** Avatar + Name
- **Status Overview:**
  - Total parameters: 15
  - Normal: 13 ✓
  - Abnormal: 2 ⚠️
- **Visual Status Indicator:** Colored bar or donut chart
- **CTA Button:** "View AI Insights" (scrolls to insights section or opens bottom sheet)

**Parameters List (Grouped & Expandable):**
- Groups collapsed by default, tap to expand:
  - **Complete Blood Count (CBC)** - Shows count badge (e.g., "8 parameters, 1 abnormal")
  - **Lipid Profile** - (e.g., "4 parameters")
  - **Liver Function Test**
  - **Kidney Function Test**
  - **Thyroid Profile**
  - **Blood Sugar**
  - **Others/Miscellaneous**

**Each Parameter Card (Inside Group):**
- Parameter name (bold)
- **Current Value** (large) + unit
- Reference range (small, gray)
- **Status Indicator:**
  - ✓ Normal (green accent)
  - ⚠️ High (red accent)
  - ⚠️ Low (orange accent)
- **Trend Icon** (if history exists): ↑ ↓ → with small mini-sparkline
- **Border/Background:** Subtle color coding (green/red/orange tint)

**Interaction:**
- Tap parameter card → **Parameter Trend Screen**

**Bottom Section: AI Insights (Collapsible)**
- "💡 AI Health Analysis" header
- **Overall Assessment:**
  - Brief summary of report status
  - "Most parameters are within normal range"
- **Areas of Concern:** (if abnormal values exist)
  - Lists abnormal parameters
  - Brief explanation for each
  - Possible implications
- **Recommendations:**
  - General health tips based on results
  - Suggested lifestyle changes
  - "Consider discussing with your doctor if..."
- **Disclaimer:** 
  - "This is AI-generated information. Always consult healthcare professionals for medical advice."

---

#### **5. Parameter Trend Screen**

**Header:**
- Back button
- Parameter name (e.g., "Hemoglobin")
- Member name (small, below)

**Current Status Card:**
- **Latest Value** (very large, bold)
- Unit (next to value)
- Test date
- **Reference Range** (highlighted box)
- **Status Badge:** Normal / High / Low (color-coded)

**Trend Visualization:**
- **Interactive Line Chart:**
  - X-axis: Dates (all reports where this parameter exists)
  - Y-axis: Parameter value
  - **Reference range shown as shaded green band**
  - **Data points:** Tappable dots
    - Green dots (normal range)
    - Red dots (outside range)
  - **Trend line:** Smooth connecting line
  - Tap any point → Shows tooltip (date + value + status)
- If only 1 report: Shows single value with message "Upload more reports to see trends"

**History Table:**
- Compact table view below chart
- Columns: Date | Value | Status
- Sorted newest to oldest
- Color-coded rows for quick scanning

**AI Insights Section (Expandable):**
- "💡 Trend Analysis"
- **Pattern Recognition:**
  - "Your [parameter] has been consistently [high/low/normal]"
  - "Noticed [increasing/decreasing/stable] trend over [time period]"
- **Contextual Information:**
  - What this parameter measures
  - Why it's important
  - Normal ranges explained
- **Recommendations (if abnormal):**
  - Possible causes
  - Lifestyle factors to consider
  - When to consult a doctor
- **Comparison Context:**
  - "Compared to your average: [+X% / -X%]"
  - "Best value: [value] on [date]"
  - "Worst value: [value] on [date]"

---

#### **6. Settings Screen**

**Bottom Navigation Bar:**
- Home
- **Settings** (active)

**Settings Sections:**

**1. Family Members**
- List of all profiles
- Each shows: Avatar, Name, Age, Reports count
- Tap member → Edit Profile Form
- "➕ Add New Member" button
- Swipe to delete (with confirmation)

**Edit Profile Form (Modal/New Screen):**
- Name (text input)
- Date of Birth (date picker)
- Relationship (dropdown)
- Delete Profile button (bottom, destructive style)
- Save button

**2. API Configuration**
- "Gemini API Key"
- Show masked key: "sk-...xyz123"
- "Change Key" button → Opens input modal
- "Test Connection" button (verifies API)
- Connection status indicator

**3. Data Management**
- **Export Data**
  - "Export All Reports (JSON)" button
  - Shows last export date (if any)
- **Import Data**
  - "Import from JSON" button
  - Allows restoring backup
- **Clear All Data**
  - Red destructive button
  - Requires confirmation: "This will delete all profiles and reports. Continue?"

**4. App Preferences**
- **Theme**
  - Radio buttons: Light / Dark / System Default
- **Units** (future feature placeholder)
  - Metric / Imperial
- **Default View**
  - Most Recent Report / All Reports

**5. About & Help**
- App Version (e.g., "v1.0.0")
- "How to Use LabLens" → Tutorial/guide
- "How to Get API Key" → Instructions
- "Privacy Policy" → "All data stored locally on your device"
- "Open Source Licenses"
- "Rate LabLens" (if on app store)
- "Contact Support"

---

## **Complete Navigation Map:**

```
┌─────────────────────────────────────────────────┐
│                  BOTTOM NAV                     │
│         [Home]  ←→  [Settings]                  │
└─────────────────────────────────────────────────┘
                      │
                      │ (FAB on Home)
                      ↓
              [Report Scan Screen]
                      │
                      ↓
              [Report Details]
                      │
                      ↓
         [Parameter Trend & Insights]


Profile Switcher (Top Right on Home):
    → [Quick Switch Bottom Sheet]
    → [Add New Member Form]

Settings:
    → [Edit Profile Form]
    → [API Key Modal]
    → [Various Settings Screens]
```

---

## **User Journey - Core Flow (Minimum Clicks):**

### **Scenario 1: Scan First Report**
1. Open app → Home screen
2. Tap FAB → Report Scan
3. Tap "Take Photo" → Camera opens
4. Capture → Processing → Report Details (✅ **3 clicks**)

### **Scenario 2: View Parameter Trend**
1. Home → Tap report card → Report Details
2. Tap parameter → Trend Screen (✅ **2 clicks**)

OR

1. Home → Tap abnormal parameter (in highlights) → Trend Screen (✅ **1 click**)

### **Scenario 3: Switch Profile & Scan**
1. Home → Tap profile switcher → Select member
2. Tap FAB → Tap scan option (✅ **3 clicks**)

### **Scenario 4: Add New Family Member**
1. Tap profile switcher → "Add New Member"
2. Fill form → Save (✅ **2 clicks** + form entry)

---

## **Key UX Decisions:**

✅ **2-tab bottom nav** (Home + Settings only)  
✅ **FAB** always visible on Home for quick scan access  
✅ **Profile switcher** at top-right for instant context switching  
✅ **Single tap** from home highlights → trend screen  
✅ **AI insights** embedded in relevant screens (not separate tab)  
✅ **Progressive disclosure** - summary first, details on demand  
✅ **Contextual actions** - everything relative to current profile  
