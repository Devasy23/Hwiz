# Material 3 Dynamic Theming Guide

## 🎨 Overview

This app implements **Material 3 (Material You)** theming with full support for dynamic colors. The theme automatically adapts to:
- System wallpaper colors (Android 12+)
- Light/Dark mode preferences
- Platform-specific design patterns

---

## ✅ Implemented Best Practices

### 1. **Dynamic Color Scheme**
```dart
// Uses dynamic_color package for Material You support
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    // Automatically uses system colors or falls back to brand colors
  }
)
```

**Benefits:**
- ✨ Seamless integration with Android 12+ wallpaper colors
- 🎯 Consistent brand identity on older devices
- 🔄 Graceful fallback to custom brand colors

### 2. **Color Harmonization**
```dart
lightColorScheme = lightDynamic.harmonized();
darkColorScheme = darkDynamic.harmonized();
```

**Benefits:**
- Ensures all colors work harmoniously together
- Maintains accessibility contrast ratios
- Creates cohesive visual experience

### 3. **Typography Scale (Material 2021)**
```dart
typography: Typography.material2021()
```

**Material 3 Type Scale:**
- Display Large/Medium/Small - Hero headlines
- Headline Large/Medium/Small - Section headers
- Title Large/Medium/Small - Emphasized text
- Body Large/Medium/Small - Main content
- Label Large/Medium/Small - Buttons, chips

### 4. **Adaptive Visual Density**
```dart
visualDensity: VisualDensity.adaptivePlatformDensity
```

**Benefits:**
- Adjusts touch targets for mobile vs desktop
- Improves usability across platforms
- Follows platform conventions

### 5. **Tonal Surface System**
Instead of shadows, Material 3 uses **tonal elevation**:

```dart
surfaceContainerLowest  // Elevation 0
surfaceContainerLow     // Elevation 1
surfaceContainer        // Elevation 2
surfaceContainerHigh    // Elevation 3
surfaceContainerHighest // Elevation 4
```

**Usage Example:**
```dart
// Use context extension
Container(
  color: context.surfaceAtElevation(3),
  child: Card(...)
)
```

### 6. **State-Based Theming**
All interactive components use `WidgetStateProperty`:

```dart
SwitchTheme(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return scheme.onPrimary;
    }
    return scheme.outline;
  })
)
```

**Supported States:**
- `WidgetState.selected`
- `WidgetState.disabled`
- `WidgetState.hovered`
- `WidgetState.focused`
- `WidgetState.pressed`

### 7. **Theme Animations**
Smooth transitions between themes:

```dart
themeAnimationDuration: Duration(milliseconds: 300)
themeAnimationCurve: Curves.easeInOut
```

### 8. **Semantic Color Roles**

#### Primary Colors
- `primary` - Main brand color
- `onPrimary` - Text/icons on primary
- `primaryContainer` - Emphasized containers
- `onPrimaryContainer` - Content on containers

#### Secondary Colors
- `secondary` - Accent color
- `secondaryContainer` - Secondary emphasis
- `onSecondaryContainer` - Content on secondary

#### Surface Colors
- `surface` - Background surfaces
- `surfaceContainer*` - Elevated surfaces (5 levels)
- `inverseSurface` - High contrast surface
- `onSurface` - Text on surfaces

### 9. **Context Extensions**
Easy access to theme colors:

```dart
// Basic usage
Text('Hello', style: TextStyle(color: context.primaryColor))
Container(color: context.surfaceContainerHigh)

// Semantic colors
Icon(Icons.check, color: context.successColor)
Icon(Icons.warning, color: context.warningColor)

// State colors with containers
Container(
  color: context.successContainer,
  child: Text('Success!', style: TextStyle(color: context.successColor))
)

// Elevation-based surfaces
Card(color: context.surfaceAtElevation(2))
```

### 10. **Component Theming**

All Material components are themed consistently:

#### Buttons
- `ElevatedButton` - Primary actions (filled)
- `FilledButton` - Emphasized actions
- `OutlinedButton` - Secondary actions
- `TextButton` - Low emphasis

#### Form Inputs
- Consistent border radius (12dp)
- Proper focus states with color transitions
- Error states with clear visual feedback
- Filled style with subtle background

#### Cards & Containers
- No harsh shadows (elevation via tonal colors)
- Consistent corner radius (12dp)
- Subtle borders using `outlineVariant`

#### Dialogs & Sheets
- Modern rounded corners (16dp)
- Proper elevation (tonal surface level 3)
- Accessible contrast ratios

#### Navigation
- Bottom navigation bar with selected indicators
- NavigationRail for tablet/desktop
- Smooth transitions between selections

---

## 🚀 Usage Examples

### Using Theme Colors

```dart
// Good ✅ - Uses semantic color roles
Container(
  color: context.primaryContainer,
  child: Text(
    'Featured',
    style: TextStyle(color: context.onPrimaryContainer),
  ),
)

// Bad ❌ - Hardcoded colors
Container(
  color: Colors.blue,
  child: Text('Featured', style: TextStyle(color: Colors.white)),
)
```

### Using Surface Elevation

```dart
// Good ✅ - Tonal elevation
Card(
  color: context.surfaceAtElevation(2),
  child: content,
)

// Bad ❌ - Shadow elevation (deprecated in M3)
Card(
  elevation: 8.0,
  child: content,
)
```

### Using Typography

```dart
// Good ✅ - Uses Material 3 type scale
Text(
  'Headline',
  style: context.textTheme.headlineMedium,
)

// Also Good ✅ - Custom with theme color
Text(
  'Custom',
  style: AppTheme.titleLarge.copyWith(
    color: context.primaryColor,
  ),
)
```

### Status Colors

```dart
// Success message
Container(
  color: context.successContainer,
  child: Row(
    children: [
      Icon(Icons.check_circle, color: context.successColor),
      Text('Success!', style: TextStyle(color: context.successColor)),
    ],
  ),
)

// Warning message
Container(
  color: context.warningContainer,
  child: Row(
    children: [
      Icon(Icons.warning, color: context.warningColor),
      Text('Warning', style: TextStyle(color: context.warningColor)),
    ],
  ),
)
```

### Dark Mode Detection

```dart
// Check theme mode
if (context.isDarkMode) {
  // Dark mode specific logic
}

// Get color based on mode
final iconColor = context.dynamicColor(
  light: Colors.black87,
  dark: Colors.white70,
);
```

---

## 📋 Checklist for New Components

When creating new UI components, ensure:

- [ ] Use `context.colorScheme.*` instead of hardcoded colors
- [ ] Use Material 3 components (`FilledButton`, `Card`, etc.)
- [ ] Apply appropriate corner radius (8/12/16dp)
- [ ] Use tonal surfaces instead of shadows
- [ ] Implement proper state handling with `WidgetStateProperty`
- [ ] Test in both light and dark modes
- [ ] Test with dynamic colors (Android 12+)
- [ ] Ensure text contrast meets WCAG AA standards
- [ ] Use semantic spacing constants (AppTheme.spacing*)
- [ ] Add proper padding for touch targets (min 48dp)

---

## 🎯 Accessibility Features

### 1. **Contrast Ratios**
All color combinations meet WCAG AA standards:
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum
- UI components: 3:1 minimum

### 2. **Touch Targets**
Minimum 48dp for interactive elements (handled by `visualDensity`)

### 3. **Focus Indicators**
Clear focus states for keyboard navigation

### 4. **Dynamic Type**
Respects system font size settings

---

## 🔧 Customization

### Add Custom Brand Colors

Edit `lib/theme/app_theme.dart`:

```dart
static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFFYOURCOLOR), // Your brand color
  brightness: Brightness.light,
);
```

### Add Custom Semantic Colors

Edit `lib/theme/theme_extensions.dart`:

```dart
extension CustomColorExtension on BuildContext {
  Color get customColor => isDarkMode 
      ? Color(0xFF...) // Dark variant
      : Color(0xFF...); // Light variant
}
```

### Modify Component Themes

Edit component theme in `AppTheme.lightTheme()` and `darkTheme()`:

```dart
buttonTheme: ButtonThemeData(
  // Your customization
),
```

---

## 📚 Resources

- [Material 3 Design](https://m3.material.io/)
- [Material Theme Builder](https://m3.material.io/theme-builder)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [dynamic_color package](https://pub.dev/packages/dynamic_color)

---

## 🐛 Testing

Test your theme changes:

```bash
# Test on Android 12+ device (Material You)
flutter run

# Test light mode
# System Settings → Display → Light mode

# Test dark mode
# System Settings → Display → Dark mode

# Test different wallpapers (Android 12+)
# System Settings → Wallpaper & style
```

---

## ✨ Summary

Your app now follows **all Material 3 theming best practices**:

✅ Dynamic color support (Material You)  
✅ Color harmonization  
✅ Modern typography (Material 2021)  
✅ Adaptive visual density  
✅ Tonal elevation system  
✅ State-based theming  
✅ Smooth theme transitions  
✅ Semantic color roles  
✅ Helpful context extensions  
✅ Comprehensive component theming  
✅ Accessibility compliance  
✅ Dark mode support  

The theme system is production-ready and follows Google's latest design guidelines! 🎉
