import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../../widgets/common/app_button.dart';
import '../main_shell.dart';

/// First profile creation during onboarding
class FirstProfileScreen extends StatefulWidget {
  const FirstProfileScreen({super.key});

  @override
  State<FirstProfileScreen> createState() => _FirstProfileScreenState();
}

class _FirstProfileScreenState extends State<FirstProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileVM = context.read<ProfileViewModel>();

    final success = await profileVM.createProfile(
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDate?.toIso8601String(),
      gender: _selectedGender,
    );

    if (success && mounted) {
      // Mark onboarding as complete (you can store this in shared preferences)
      // For now, just navigate to main shell
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainShell(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 50,
                    color: AppTheme.successColor,
                  ),
                ),

                const SizedBox(height: AppTheme.spacing32),

                // Title
                Text(
                  'Create Your First Profile',
                  style: AppTheme.headingLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Description
                Text(
                  'Let\'s start by creating a profile for you. You can add family members later.',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacing40),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),

                const SizedBox(height: AppTheme.spacing20),

                // Date of birth
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (Optional)',
                      hintText: 'Select date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Not set',
                      style: _selectedDate != null
                          ? AppTheme.bodyLarge
                          : AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacing20),

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender (Optional)',
                    hintText: 'Select gender',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: AppTheme.spacing40),

                // Create button
                Consumer<ProfileViewModel>(
                  builder: (context, profileVM, child) {
                    return AppButton(
                      text: 'Start Using LabLens',
                      onPressed: _createProfile,
                      isLoading: profileVM.isLoading,
                      width: double.infinity,
                      icon: Icons.check,
                    );
                  },
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Info text
                Text(
                  'You can add more family members anytime from Settings',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
