# Component Improvements Plan - Material 3 Best Practices

## 🎯 Overview
Systematically upgrade all UI components to follow Material 3 design guidelines, similar to the NavigationBar update.

---

## 📋 Components to Update

### ✅ Already Updated
- [x] NavigationBar (replaced BottomNavigationBar)
- [x] Theme system with Material 3 colors
- [x] Typography (Material 2021)

### 🔄 To Update

#### 1. **Buttons** - HIGH PRIORITY
**Files affected:**
- All screens with buttons
- Common patterns: ElevatedButton, OutlinedButton, TextButton

**M3 Changes:**
- Use `FilledButton` instead of `ElevatedButton` for primary actions
- Use `FilledButton.tonal` for secondary filled buttons
- Use `OutlinedButton` for secondary actions
- Use `TextButton` for low-priority actions
- Add `IconButton.filled` and `IconButton.filledTonal` variants
- Consistent padding and corner radius

#### 2. **Cards** - HIGH PRIORITY
**Files affected:**
- `home_tab.dart`
- `profile_list_screen.dart`
- `report_list_screen.dart`
- `settings_screen.dart`

**M3 Changes:**
- Remove elevation (already done in theme)
- Use outlined cards with `outlineVariant` border
- Use `surfaceContainerLow` for background
- Consistent 12dp corner radius
- Proper padding (16dp standard)

#### 3. **Text Fields** - HIGH PRIORITY
**Files affected:**
- `profile_form_screen.dart`
- `settings_screen.dart`
- `add_profile_screen.dart`

**M3 Changes:**
- Use filled style (already in theme)
- Proper focus states
- Helper text positioning
- Consistent error styling
- Prefix/suffix icon colors

#### 4. **Dialogs** - MEDIUM PRIORITY
**Files affected:**
- `settings_screen.dart` (API key dialog)
- `profile_list_screen.dart` (delete confirmation)

**M3 Changes:**
- Use `AlertDialog` with proper styling
- Title: headlineSmall
- Content: bodyMedium
- Actions aligned properly
- 28dp padding
- Full-width action buttons option

#### 5. **FAB (Floating Action Button)** - MEDIUM PRIORITY
**Files affected:**
- `home_tab.dart`
- `report_list_screen.dart`

**M3 Changes:**
- Use `FloatingActionButton.extended` for labeled FAB
- Use `primaryContainer` color
- Proper elevation (default is good)
- Consider FAB size variants (small, regular, large)

#### 6. **List Items** - MEDIUM PRIORITY
**Files affected:**
- `profile_list_screen.dart`
- `report_list_screen.dart`
- Profile switcher sheet

**M3 Changes:**
- Use `ListTile` with Material 3 styling
- Leading/trailing icon colors
- Proper padding (16dp horizontal, 12dp vertical)
- Selection state with `selectedTileColor`
- Three-line support

#### 7. **Chips** - LOW PRIORITY
**Files affected:**
- None currently, but useful for tags/filters

**M3 Changes:**
- Use `Chip`, `FilterChip`, `InputChip`
- Elevated vs flat variants
- Proper icon placement
- Selection states

#### 8. **Snackbars** - LOW PRIORITY
**Files affected:**
- All screens with feedback

**M3 Changes:**
- Use floating behavior (already in theme)
- Proper action button
- Maximum width constraints
- Inverse surface colors

#### 9. **Progress Indicators** - LOW PRIORITY
**Files affected:**
- Loading states in all screens

**M3 Changes:**
- Circular: proper sizing (24dp, 36dp, 48dp)
- Linear: proper height and colors
- Container styling for inline indicators

#### 10. **Bottom Sheets** - MEDIUM PRIORITY
**Files affected:**
- `profile_switcher_sheet.dart`
- `profile_list_screen.dart` (detail sheet)

**M3 Changes:**
- Drag handle (4dp width, 32dp height indicator)
- Proper corner radius (28dp top corners)
- Modal vs standard sheets
- Scrim opacity

---

## 🎨 Material 3 Button Hierarchy

### Primary Actions (Most Important)
```dart
FilledButton(
  onPressed: () {},
  child: Text('Save'),
)
```

### Secondary Actions (Important but not primary)
```dart
FilledButton.tonal(
  onPressed: () {},
  child: Text('Edit'),
)
```

### Tertiary Actions (Less emphasis)
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
```

### Low Priority Actions
```dart
TextButton(
  onPressed: () {},
  child: Text('Skip'),
)
```

### Icon Actions
```dart
IconButton.filled(
  onPressed: () {},
  icon: Icon(Icons.add),
)

IconButton.filledTonal(
  onPressed: () {},
  icon: Icon(Icons.edit),
)
```

---

## 📐 Spacing & Sizing Standards

### Padding
- **Small**: 8dp
- **Medium**: 12dp
- **Standard**: 16dp
- **Large**: 24dp
- **XLarge**: 32dp

### Corner Radius
- **Small**: 8dp (chips)
- **Medium**: 12dp (cards, buttons)
- **Large**: 16dp (dialogs)
- **XLarge**: 28dp (sheets)

### Touch Targets
- **Minimum**: 48dp × 48dp
- **Icon Buttons**: 48dp × 48dp
- **List Items**: 56dp height minimum

---

## 🔄 Implementation Priority

### Phase 1: Critical UI Elements (Day 1)
1. ✅ NavigationBar
2. 🔄 Buttons (FilledButton migration)
3. 🔄 Cards (ensure consistency)
4. 🔄 Text Fields (polish)

### Phase 2: Interactive Elements (Day 2)
5. 🔄 Dialogs
6. 🔄 Bottom Sheets
7. 🔄 FABs
8. 🔄 List Items

### Phase 3: Feedback & Polish (Day 3)
9. 🔄 Snackbars
10. 🔄 Progress Indicators
11. 🔄 Chips (if needed)

---

## 🚀 Implementation Strategy

### For Each Component:

1. **Audit Current Usage**
   - Find all occurrences
   - Document current pattern
   
2. **Update to M3**
   - Replace deprecated components
   - Apply M3 styling
   - Test light/dark modes
   
3. **Document Changes**
   - Add inline comments
   - Update pattern library
   
4. **Test**
   - Visual check
   - Interaction test
   - Accessibility check

---

## 📝 Code Patterns

### Before (M2 Style)
```dart
// Old ElevatedButton
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 48),
  ),
  onPressed: () {},
  child: Text('Save'),
)
```

### After (M3 Style)
```dart
// New FilledButton
FilledButton(
  onPressed: () {},
  child: Text('Save'),
)
// Note: Full-width handled by wrapping in SizedBox
```

### Before (M2 Card)
```dart
Card(
  elevation: 4,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: content,
  ),
)
```

### After (M3 Card)
```dart
Card(
  // Elevation handled by theme (0)
  // Border added by theme
  child: Padding(
    padding: EdgeInsets.all(16),
    child: content,
  ),
)
```

---

## ✅ Checklist for Each Screen

When updating a screen:

- [ ] Replace `ElevatedButton` with `FilledButton`
- [ ] Replace secondary `ElevatedButton` with `FilledButton.tonal`
- [ ] Ensure `TextButton` for low priority
- [ ] Remove manual elevation from Cards
- [ ] Use theme colors (no hardcoded Colors.xxx)
- [ ] Consistent spacing (use AppTheme.spacing*)
- [ ] Proper corner radius (use AppTheme.radius*)
- [ ] Icon colors from theme
- [ ] Text styles from theme
- [ ] Test dark mode
- [ ] Test dynamic colors
- [ ] Accessibility: minimum 48dp touch targets
- [ ] Accessibility: proper contrast ratios

---

## 📚 References

- [Material 3 Components](https://m3.material.io/components)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [Button Guidelines](https://m3.material.io/components/buttons/overview)
- [Card Guidelines](https://m3.material.io/components/cards/overview)
- [TextField Guidelines](https://m3.material.io/components/text-fields/overview)

---

## 🎯 Success Criteria

Component upgrade is complete when:

✅ All components use M3 variants  
✅ No hardcoded colors  
✅ Consistent spacing/radius  
✅ Works in light & dark modes  
✅ Works with dynamic colors  
✅ Meets accessibility standards  
✅ Smooth animations  
✅ Proper touch targets  
✅ No visual regressions  
✅ Code is documented  

