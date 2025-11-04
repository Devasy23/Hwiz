# Material 3 Components - Developer Quick Reference

## 🚀 Quick Start

When building new UI or updating existing screens, follow these patterns:

---

## 🔘 Buttons

### Primary Action (Most Important)
```dart
// Regular
FilledButton(
  onPressed: () {},
  child: const Text('Save'),
)

// With icon
FilledButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.save),
  label: const Text('Save'),
)

// Full width
SizedBox(
  width: double.infinity,
  child: FilledButton(
    onPressed: () {},
    child: const Text('Continue'),
  ),
)

// Loading state
FilledButton(
  onPressed: isLoading ? null : () {},
  child: isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : const Text('Submit'),
)
```

### Secondary Action
```dart
// Tonal variant (softer emphasis)
FilledButton.tonal(
  onPressed: () {},
  child: const Text('Edit'),
)

// Outlined (even less emphasis)
OutlinedButton(
  onPressed: () {},
  child: const Text('Cancel'),
)

// With icon
OutlinedButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.close),
  label: const Text('Cancel'),
)
```

### Low Priority Action
```dart
TextButton(
  onPressed: () {},
  child: const Text('Skip'),
)

TextButton.icon(
  onPressed: () {},
  icon: const Icon(Icons.info),
  label: const Text('Learn More'),
)
```

### Icon Buttons
```dart
// Filled (high emphasis)
IconButton.filled(
  onPressed: () {},
  icon: const Icon(Icons.add),
)

// Filled tonal (medium emphasis)
IconButton.filledTonal(
  onPressed: () {},
  icon: const Icon(Icons.edit),
)

// Standard (low emphasis)
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.more_vert),
)

// Outlined
IconButton.outlined(
  onPressed: () {},
  icon: const Icon(Icons.favorite_outline),
)
```

---

## 🎴 Cards

### Standard Card
```dart
Card(
  // No need to specify elevation, shape, color - theme handles it
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Content
      ],
    ),
  ),
)
```

### Colored Card (for emphasis)
```dart
Card(
  color: Theme.of(context).colorScheme.primaryContainer,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        Text(
          'Info',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    ),
  ),
)
```

### Clickable Card
```dart
Card(
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Content
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  ),
)
```

---

## 📝 Text Fields

### Basic Input
```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Name',
    hintText: 'Enter your name',
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

### With Helper Text
```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'user@example.com',
    helperText: 'We\'ll never share your email',
    prefixIcon: Icon(Icons.email),
  ),
)
```

### With Clear Button
```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Search',
    prefixIcon: const Icon(Icons.search),
    suffixIcon: _controller.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() => _controller.clear());
            },
          )
        : null,
  ),
)
```

### Dropdown
```dart
DropdownButtonFormField<String>(
  value: _selectedValue,
  decoration: const InputDecoration(
    labelText: 'Category',
    prefixIcon: Icon(Icons.category),
  ),
  items: ['Option 1', 'Option 2', 'Option 3']
      .map((value) => DropdownMenuItem(
            value: value,
            child: Text(value),
          ))
      .toList(),
  onChanged: (value) {
    setState(() => _selectedValue = value);
  },
)
```

---

## 💬 Dialogs

### Alert Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm Action'),
    content: const Text('Are you sure you want to proceed?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          // Action
          Navigator.pop(context);
        },
        child: const Text('Confirm'),
      ),
    ],
  ),
)
```

### Form Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Add Item'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Description',
          ),
          maxLines: 3,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          // Save
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ],
  ),
)
```

---

## 📄 Bottom Sheets

### Modal Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Your content
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### Draggable Sheet
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.9,
    builder: (context, scrollController) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          // Content
        ],
      ),
    ),
  ),
)
```

---

## 📱 Snackbars

### Simple Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Action completed'),
  ),
)
```

### With Action
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Item deleted'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Undo action
      },
    ),
  ),
)
```

### Success/Error
```dart
// Success
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Saved successfully'),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
)

// Error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('An error occurred'),
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
)
```

---

## ⏳ Progress Indicators

### Circular (Indeterminate)
```dart
const Center(
  child: CircularProgressIndicator(),
)
```

### Circular (Determinate)
```dart
Center(
  child: CircularProgressIndicator(
    value: 0.65, // 0.0 to 1.0
  ),
)
```

### Linear
```dart
const LinearProgressIndicator()

// Or determinate
LinearProgressIndicator(
  value: 0.65,
)
```

### In Button
```dart
FilledButton(
  onPressed: isLoading ? null : () {},
  child: isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : const Text('Submit'),
)
```

---

## 📋 List Items

### Simple List Tile
```dart
ListTile(
  leading: const Icon(Icons.person),
  title: const Text('John Doe'),
  subtitle: const Text('john@example.com'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {},
)
```

### Selected List Tile
```dart
ListTile(
  selected: isSelected,
  leading: const Icon(Icons.check),
  title: const Text('Option 1'),
  onTap: () {},
)
```

### Three-Line
```dart
ListTile(
  leading: const CircleAvatar(
    child: Icon(Icons.person),
  ),
  title: const Text('John Doe'),
  subtitle: const Text('Software Engineer\nSan Francisco, CA'),
  isThreeLine: true,
  trailing: const Icon(Icons.more_vert),
  onTap: () {},
)
```

---

## 🎨 Using Theme Colors

### Get Colors
```dart
// Primary
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.onPrimary

// Surface
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.onSurface

// With extension (easier)
context.primaryColor
context.onPrimaryColor
context.surfaceColor
```

### Semantic Colors
```dart
// Success (green)
context.successColor
context.successContainer

// Warning (orange)
context.warningColor
context.warningContainer

// Info (blue)
context.infoColor
context.infoContainer

// Error
context.errorColor
Theme.of(context).colorScheme.errorContainer
```

### Surface Elevation
```dart
// Get surface at specific elevation (0-5)
context.surfaceAtElevation(0) // Base surface
context.surfaceAtElevation(1) // Slightly elevated
context.surfaceAtElevation(3) // More elevated
context.surfaceAtElevation(5) // Highest elevation
```

---

## 📏 Spacing & Sizing

### Spacing
```dart
// Use constants instead of hardcoded values
AppTheme.spacing4   // 4dp
AppTheme.spacing8   // 8dp
AppTheme.spacing12  // 12dp
AppTheme.spacing16  // 16dp (standard)
AppTheme.spacing24  // 24dp
AppTheme.spacing32  // 32dp

// Example
Padding(
  padding: const EdgeInsets.all(AppTheme.spacing16),
  child: child,
)
```

### Border Radius
```dart
AppTheme.radiusSmall   // 8dp
AppTheme.radiusMedium  // 12dp (standard)
AppTheme.radiusLarge   // 16dp
AppTheme.radiusXLarge  // 20dp
AppTheme.radiusFull    // 999dp (circular)

// Example
BorderRadius.circular(AppTheme.radiusMedium)
```

---

## ✅ Best Practices Checklist

When building a new component:

- [ ] Use `FilledButton` for primary actions
- [ ] Use `FilledButton.tonal` or `OutlinedButton` for secondary actions
- [ ] Use `TextButton` for low-priority actions
- [ ] Don't hardcode colors - use `Theme.of(context).colorScheme.*`
- [ ] Don't hardcode spacing - use `AppTheme.spacing*`
- [ ] Don't hardcode radius - use `AppTheme.radius*`
- [ ] Don't set elevation on Cards - theme handles it
- [ ] Use `const` constructors where possible
- [ ] Ensure minimum 48dp touch targets
- [ ] Test in both light and dark modes
- [ ] Test with dynamic colors (Android 12+)
- [ ] Add semantic labels for accessibility

---

## 🚫 Anti-Patterns (Don't Do This)

### ❌ Hardcoded Colors
```dart
// Bad
Container(
  color: Colors.blue,
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)

// Good
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)
```

### ❌ Manual Elevation
```dart
// Bad
Card(
  elevation: 4,
  child: content,
)

// Good
Card(
  // Let theme handle elevation
  child: content,
)
```

### ❌ Inline Styling
```dart
// Bad
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Save'),
)

// Good
FilledButton(
  // Let theme handle styling
  child: Text('Save'),
)
```

### ❌ Wrong Button Type
```dart
// Bad - Using ElevatedButton
ElevatedButton(
  onPressed: () {},
  child: Text('Save'),
)

// Good - Using FilledButton
FilledButton(
  onPressed: () {},
  child: Text('Save'),
)
```

---

## 🎯 Quick Decision Tree

**Need a button?**
- Is it the main action on the screen? → `FilledButton`
- Is it an important but not primary action? → `FilledButton.tonal` or `OutlinedButton`
- Is it a low-priority action? → `TextButton`
- Is it just an icon? → `IconButton.filled` or `IconButton.filledTonal`

**Need a container?**
- Does it group related content? → `Card`
- Does it need emphasis? → `Card` with `primaryContainer` color
- Is it just for layout? → `Container` or `Padding`

**Need user input?**
- Text input? → `TextFormField`
- Selection from list? → `DropdownButtonFormField`
- Yes/No? → `Switch` or `Checkbox`
- Multiple choice? → `Radio` or `Chip`

**Need to show feedback?**
- Brief message? → `SnackBar`
- Important message? → `Dialog`
- Bottom options? → `BottomSheet`

---

## 📚 Full Examples

### Complete Form Screen
```dart
class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Your async operation
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
```

---

This guide covers 95% of common UI patterns. For more complex components, refer to:
- [Material 3 Components](https://m3.material.io/components)
- [Flutter Material Widgets](https://docs.flutter.dev/ui/widgets/material)

Happy coding! 🚀
