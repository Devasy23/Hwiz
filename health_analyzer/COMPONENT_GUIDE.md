# LabLens UI Components - Quick Reference

## 🎨 Theme Usage

### Import Theme
```dart
import 'package:health_analyzer/theme/app_theme.dart';
```

### Using Colors
```dart
// Primary colors
Container(color: AppTheme.primaryColor)
Container(color: AppTheme.primaryLight)
Container(color: AppTheme.primaryDark)

// Status colors
Container(color: AppTheme.successColor)  // Green - normal
Container(color: AppTheme.warningColor)  // Orange - low
Container(color: AppTheme.errorColor)    // Red - high
Container(color: AppTheme.infoColor)     // Blue - info

// Text colors
Text('Text', style: TextStyle(color: AppTheme.textPrimary))
Text('Text', style: TextStyle(color: AppTheme.textSecondary))
Text('Text', style: TextStyle(color: AppTheme.textTertiary))
```

### Using Typography
```dart
// Headings
Text('Title', style: AppTheme.headingLarge)   // 32px bold
Text('Title', style: AppTheme.headingMedium)  // 24px bold
Text('Title', style: AppTheme.headingSmall)   // 20px semibold

// Titles
Text('Title', style: AppTheme.titleLarge)     // 18px semibold
Text('Title', style: AppTheme.titleMedium)    // 16px semibold
Text('Title', style: AppTheme.titleSmall)     // 14px semibold

// Body text
Text('Body', style: AppTheme.bodyLarge)       // 16px regular
Text('Body', style: AppTheme.bodyMedium)      // 14px regular
Text('Body', style: AppTheme.bodySmall)       // 12px regular

// Labels
Text('Label', style: AppTheme.labelLarge)     // 14px medium
Text('Label', style: AppTheme.labelMedium)    // 12px medium
Text('Label', style: AppTheme.labelSmall)     // 10px medium
```

### Using Spacing
```dart
SizedBox(height: AppTheme.spacing4)   // 4px
SizedBox(height: AppTheme.spacing8)   // 8px
SizedBox(height: AppTheme.spacing12)  // 12px
SizedBox(height: AppTheme.spacing16)  // 16px
SizedBox(height: AppTheme.spacing20)  // 20px
SizedBox(height: AppTheme.spacing24)  // 24px
SizedBox(height: AppTheme.spacing32)  // 32px
SizedBox(height: AppTheme.spacing40)  // 40px
SizedBox(height: AppTheme.spacing48)  // 48px
```

### Using Radius
```dart
BorderRadius.circular(AppTheme.radiusSmall)   // 8px
BorderRadius.circular(AppTheme.radiusMedium)  // 12px
BorderRadius.circular(AppTheme.radiusLarge)   // 16px
BorderRadius.circular(AppTheme.radiusXLarge)  // 20px
BorderRadius.circular(AppTheme.radiusFull)    // 999px (pill)
```

---

## 🧩 Common Components

### AppButton
```dart
import 'package:health_analyzer/widgets/common/app_button.dart';

// Primary button
AppButton(
  text: 'Save',
  onPressed: () {},
  type: AppButtonType.primary,
)

// Secondary button
AppButton(
  text: 'Cancel',
  onPressed: () {},
  type: AppButtonType.secondary,
)

// With icon
AppButton(
  text: 'Add',
  icon: Icons.add,
  onPressed: () {},
)

// Loading state
AppButton(
  text: 'Saving...',
  isLoading: true,
)

// Full width
AppButton(
  text: 'Submit',
  onPressed: () {},
  width: double.infinity,
)
```

### StatusBadge
```dart
import 'package:health_analyzer/widgets/common/status_badge.dart';

// Normal status
StatusBadge(
  label: 'Normal',
  type: StatusType.normal,
)

// High value
StatusBadge(
  label: 'High',
  type: StatusType.high,
)

// Low value
StatusBadge(
  label: 'Low',
  type: StatusType.low,
)

// Compact version
StatusBadge(
  label: 'Normal',
  type: StatusType.normal,
  isCompact: true,
)
```

### ProfileAvatar
```dart
import 'package:health_analyzer/widgets/common/profile_avatar.dart';

// Default avatar
ProfileAvatar(
  name: 'John Doe',
  size: 40,
)

// Large avatar
ProfileAvatar(
  name: 'Jane Smith',
  size: 60,
)

// With border
ProfileAvatar(
  name: 'Bob Johnson',
  size: 50,
  showBorder: true,
)

// Custom color
ProfileAvatar(
  name: 'Alice Brown',
  size: 40,
  backgroundColor: Colors.purple,
)
```

### EmptyState
```dart
import 'package:health_analyzer/widgets/common/empty_state.dart';

// Basic empty state
EmptyState(
  icon: Icons.description_outlined,
  title: 'No reports yet',
  message: 'Tap the + button to scan your first report',
)

// With action
EmptyState(
  icon: Icons.person_add,
  title: 'No profiles',
  message: 'Create a profile to get started',
  actionLabel: 'Add Profile',
  onAction: () {
    // Navigate to add profile
  },
)
```

### LoadingIndicator
```dart
import 'package:health_analyzer/widgets/common/loading_indicator.dart';

// Basic loading
LoadingIndicator()

// With message
LoadingIndicator(
  message: 'Analyzing report...',
)

// With progress
LoadingIndicator(
  message: 'Processing...',
  showProgress: true,
  progress: 0.65,  // 65%
)
```

---

## 📐 Layout Patterns

### Card with Padding
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(AppTheme.spacing16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: AppTheme.titleMedium),
        const SizedBox(height: AppTheme.spacing8),
        Text('Content', style: AppTheme.bodyMedium),
      ],
    ),
  ),
)
```

### Section Header
```dart
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: AppTheme.spacing16,
    vertical: AppTheme.spacing8,
  ),
  child: Text(
    'Section Title',
    style: AppTheme.headingSmall,
  ),
)
```

### List Item
```dart
ListTile(
  leading: Icon(Icons.person),
  title: Text('Title', style: AppTheme.titleMedium),
  subtitle: Text('Subtitle', style: AppTheme.bodySmall),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

---

## 🎨 Color-Coded Status Pattern

### Parameter Card
```dart
Container(
  decoration: BoxDecoration(
    color: isNormal 
      ? AppTheme.successLight 
      : AppTheme.errorLight,
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    border: Border.all(
      color: isNormal 
        ? AppTheme.successColor 
        : AppTheme.errorColor,
      width: 1,
    ),
  ),
  padding: const EdgeInsets.all(AppTheme.spacing16),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hemoglobin', style: AppTheme.titleMedium),
            Text('14.5 g/dL', style: AppTheme.headingSmall),
          ],
        ),
      ),
      StatusBadge(
        label: isNormal ? 'Normal' : 'High',
        type: isNormal ? StatusType.normal : StatusType.high,
      ),
    ],
  ),
)
```

---

## 🚀 Navigation Examples

### Push to New Screen
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const ReportDetailsScreen(),
  ),
)
```

### Show Modal Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => const ProfileSwitcherSheet(),
)
```

### Show Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Perform action
          Navigator.pop(context);
        },
        child: Text('Confirm'),
      ),
    ],
  ),
)
```

---

## 📱 Responsive Patterns

### Safe Area
```dart
Scaffold(
  body: SafeArea(
    child: // Your content
  ),
)
```

### Scrollable Content
```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(AppTheme.spacing16),
  child: Column(
    children: [
      // Your content
    ],
  ),
)
```

### Sliver List
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: // Header widget
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => // List item
        childCount: items.length,
      ),
    ),
  ],
)
```

---

## 🎭 State Management

### Consumer Pattern
```dart
Consumer<ProfileViewModel>(
  builder: (context, profileVM, child) {
    if (profileVM.isLoading) {
      return LoadingIndicator();
    }
    
    if (profileVM.profiles.isEmpty) {
      return EmptyState(
        icon: Icons.person_add,
        title: 'No profiles',
      );
    }
    
    return ListView.builder(
      itemCount: profileVM.profiles.length,
      itemBuilder: (context, index) {
        final profile = profileVM.profiles[index];
        return // List item
      },
    );
  },
)
```

### Read Pattern (One-time access)
```dart
final profileVM = context.read<ProfileViewModel>();
await profileVM.createProfile(name: 'John Doe');
```

---

## 💡 Best Practices

### DO ✅
- Use AppTheme constants for colors, spacing, typography
- Use common components (AppButton, StatusBadge, etc.)
- Handle loading and error states
- Show empty states when no data
- Use Consumer for reactive UI
- Use context.read for actions
- Add proper error handling
- Validate user input

### DON'T ❌
- Hardcode colors or spacing values
- Ignore loading states
- Forget error handling
- Use magic numbers
- Skip empty states
- Mix theme and inline styles
- Forget to dispose controllers
- Skip form validation

---

## 🔍 Common Patterns

### Form Field
```dart
TextFormField(
  controller: _controller,
  decoration: const InputDecoration(
    labelText: 'Name',
    hintText: 'Enter name',
    prefixIcon: Icon(Icons.person),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  },
)
```

### Date Picker
```dart
final date = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
);

if (date != null) {
  setState(() {
    _selectedDate = date;
  });
}
```

### Dropdown
```dart
DropdownButtonFormField<String>(
  value: _selectedValue,
  decoration: const InputDecoration(
    labelText: 'Select option',
  ),
  items: options.map((option) {
    return DropdownMenuItem(
      value: option,
      child: Text(option),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedValue = value;
    });
  },
)
```

---

**Happy Coding! 🎉**
