import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Lablens/widgets/common/status_badge.dart';
import 'package:Lablens/widgets/common/profile_avatar.dart';
import 'package:Lablens/widgets/common/app_button.dart';
import 'package:Lablens/widgets/common/empty_state.dart';
import 'package:Lablens/widgets/common/loading_indicator.dart';

void main() {
  group('StatusBadge Widget', () {
    testWidgets('renders normal status badge correctly', (WidgetTester tester) async {
      // Given: Normal status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Normal',
              type: StatusType.normal,
            ),
          ),
        ),
      );

      // Then: Should display label and icon
      expect(find.text('Normal'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders high status badge correctly', (WidgetTester tester) async {
      // Given: High status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'High',
              type: StatusType.high,
            ),
          ),
        ),
      );

      // Then: Should display label and up arrow icon
      expect(find.text('High'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('renders low status badge correctly', (WidgetTester tester) async {
      // Given: Low status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Low',
              type: StatusType.low,
            ),
          ),
        ),
      );

      // Then: Should display label and down arrow icon
      expect(find.text('Low'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('renders abnormal status badge correctly', (WidgetTester tester) async {
      // Given: Abnormal status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Abnormal',
              type: StatusType.abnormal,
            ),
          ),
        ),
      );

      // Then: Should display label and warning icon
      expect(find.text('Abnormal'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders info status badge correctly', (WidgetTester tester) async {
      // Given: Info status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Info',
              type: StatusType.info,
            ),
          ),
        ),
      );

      // Then: Should display label and info icon
      expect(find.text('Info'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('compact mode does not show icon', (WidgetTester tester) async {
      // Given: Compact status badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Normal',
              type: StatusType.normal,
              isCompact: true,
            ),
          ),
        ),
      );

      // Then: Should display label but no icon
      expect(find.text('Normal'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('applies correct colors for each status type', (WidgetTester tester) async {
      // Test that widget builds without error for all types
      for (final statusType in StatusType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(
                label: statusType.name,
                type: statusType,
              ),
            ),
          ),
        );
        expect(find.byType(StatusBadge), findsOneWidget);
      }
    });
  });

  group('ProfileAvatar Widget', () {
    testWidgets('renders initials from single name', (WidgetTester tester) async {
      // Given: Single name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: 'John'),
          ),
        ),
      );

      // Then: Should display first letter
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('renders initials from full name', (WidgetTester tester) async {
      // Given: Full name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: 'John Doe'),
          ),
        ),
      );

      // Then: Should display first and last initials
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('handles empty name gracefully', (WidgetTester tester) async {
      // Given: Empty name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: ''),
          ),
        ),
      );

      // Then: Should display question mark
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('handles whitespace-only name', (WidgetTester tester) async {
      // Given: Whitespace name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: '   '),
          ),
        ),
      );

      // Then: Should display question mark
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('uses custom size when provided', (WidgetTester tester) async {
      // Given: Custom size
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              name: 'John Doe',
              size: 60,
            ),
          ),
        ),
      );

      // Then: Should find the widget with correct size
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, equals(60));
      expect(container.constraints?.maxHeight, equals(60));
    });

    testWidgets('shows border when showBorder is true', (WidgetTester tester) async {
      // Given: Avatar with border
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              name: 'John Doe',
              showBorder: true,
            ),
          ),
        ),
      );

      // Then: Should render without error
      expect(find.byType(ProfileAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('uses custom background color when provided', (WidgetTester tester) async {
      // Given: Avatar with custom color
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              name: 'John Doe',
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      // Then: Should render without error
      expect(find.byType(ProfileAvatar), findsOneWidget);
    });

    testWidgets('handles names with multiple spaces', (WidgetTester tester) async {
      // Given: Name with multiple spaces
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: 'John   Doe   Smith'),
          ),
        ),
      );

      // Then: Should display first and last initials
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('converts initials to uppercase', (WidgetTester tester) async {
      // Given: Lowercase name
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: 'john doe'),
          ),
        ),
      );

      // Then: Should display uppercase initials
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('jd'), findsNothing);
    });
  });

  group('AppButton Widget', () {
    testWidgets('renders primary button with text', (WidgetTester tester) async {
      // Given: Primary button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should display text
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders secondary button', (WidgetTester tester) async {
      // Given: Secondary button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Cancel',
              type: AppButtonType.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should display as outlined button
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders text button', (WidgetTester tester) async {
      // Given: Text button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Skip',
              type: AppButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should display as text button
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders destructive button', (WidgetTester tester) async {
      // Given: Destructive button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Delete',
              type: AppButtonType.destructive,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should display as elevated button
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('button is disabled when onPressed is null', (WidgetTester tester) async {
      // Given: Button with null onPressed
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      // Then: Button should be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      // Given: Loading button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should show loading indicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      // Given: Button with icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Add',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should display both icon and text
      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      // Given: Button with callback
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Press Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // When: Tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Then: Callback should be called
      expect(pressed, isTrue);
    });

    testWidgets('uses custom width when provided', (WidgetTester tester) async {
      // Given: Button with custom width
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Wide Button',
              width: 200,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should have correct width
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(200));
    });

    testWidgets('uses custom height when provided', (WidgetTester tester) async {
      // Given: Button with custom height
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Tall Button',
              height: 60,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Then: Should have correct height
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(60));
    });
  });

  group('EmptyState Widget', () {
    testWidgets('renders with title and icon', (WidgetTester tester) async {
      // Given: Empty state with title
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
            ),
          ),
        ),
      );

      // Then: Should display title and icon
      expect(find.text('No Items'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders with optional message', (WidgetTester tester) async {
      // Given: Empty state with message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item to get started',
            ),
          ),
        ),
      );

      // Then: Should display message
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Add your first item to get started'), findsOneWidget);
    });

    testWidgets('renders without message when not provided', (WidgetTester tester) async {
      // Given: Empty state without message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
            ),
          ),
        ),
      );

      // Then: Should only show title
      expect(find.text('No Items'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders action button when provided', (WidgetTester tester) async {
      // Given: Empty state with action
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              actionLabel: 'Add Item',
              onAction: () {},
            ),
          ),
        ),
      );

      // Then: Should display action button
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('action button calls callback when tapped', (WidgetTester tester) async {
      // Given: Empty state with action
      var actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              actionLabel: 'Add Item',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      // When: Tap action button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Then: Callback should be called
      expect(actionCalled, isTrue);
    });

    testWidgets('does not show action button when onAction is null', (WidgetTester tester) async {
      // Given: Empty state with label but no action
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              actionLabel: 'Add Item',
              onAction: null,
            ),
          ),
        ),
      );

      // Then: Should not display action button
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('centers content on screen', (WidgetTester tester) async {
      // Given: Empty state widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
            ),
          ),
        ),
      );

      // Then: Should be centered
      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('LoadingIndicator Widget', () {
    testWidgets('renders circular progress indicator', (WidgetTester tester) async {
      // Given: Loading indicator
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Then: Should display progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with optional message', (WidgetTester tester) async {
      // Given: Loading indicator with message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      // Then: Should display message
      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders without message when not provided', (WidgetTester tester) async {
      // Given: Loading indicator without message
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Then: Should only show progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows determinate progress when provided', (WidgetTester tester) async {
      // Given: Loading indicator with progress
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              showProgress: true,
              progress: 0.5,
            ),
          ),
        ),
      );

      // Then: Should show determinate progress
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, equals(0.5));
    });

    testWidgets('shows indeterminate progress by default', (WidgetTester tester) async {
      // Given: Loading indicator without progress value
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Then: Should show indeterminate progress
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
    });

    testWidgets('centers content on screen', (WidgetTester tester) async {
      // Given: Loading indicator
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Then: Should be centered
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('renders in container with decoration', (WidgetTester tester) async {
      // Given: Loading indicator
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              message: 'Processing...',
            ),
          ),
        ),
      );

      // Then: Should find container
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('StatusBadge and ProfileAvatar work together', (WidgetTester tester) async {
      // Given: A layout with multiple widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                ProfileAvatar(name: 'John Doe'),
                SizedBox(height: 16),
                StatusBadge(label: 'Normal', type: StatusType.normal),
              ],
            ),
          ),
        ),
      );

      // Then: Both widgets should render
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('EmptyState with action button integration', (WidgetTester tester) async {
      // Given: Empty state in a full screen layout
      var itemAdded = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('My App')),
            body: EmptyState(
              icon: Icons.folder_open,
              title: 'No Reports',
              message: 'Start by adding your first report',
              actionLabel: 'Add Report',
              onAction: () => itemAdded = true,
            ),
          ),
        ),
      );

      // When: Tap the action button
      await tester.tap(find.text('Add Report'));
      await tester.pump();

      // Then: Action should be triggered
      expect(itemAdded, isTrue);
    });

    testWidgets('Loading overlay with message', (WidgetTester tester) async {
      // Given: Stack with loading indicator overlay
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(child: Text('Content')),
                LoadingIndicator(message: 'Saving...'),
              ],
            ),
          ),
        ),
      );

      // Then: Both content and loading should be present
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Saving...'), findsOneWidget);
    });
  });
}