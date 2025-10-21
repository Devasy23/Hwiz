import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_extensions.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/forms/profile_form_fields.dart';

/// Screen for adding a new profile
class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
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
    final date = await ProfileFormFields.showDatePickerDialog(
      context,
      initialDate: _selectedDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveProfile() async {
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        title: const Text('Add Family Member'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Let\'s add a new profile',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Enter their basic information to get started',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),

                // Name field
                ProfileFormFields.nameField(
                  controller: _nameController,
                ),

                const SizedBox(height: AppTheme.spacing20),

                // Date of birth
                ProfileFormFields.dateOfBirthField(
                  context: context,
                  selectedDate: _selectedDate,
                  onTap: _selectDate,
                ),

                const SizedBox(height: AppTheme.spacing20),

                // Gender
                ProfileFormFields.genderField(
                  selectedGender: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: AppTheme.spacing40),

                // Save button
                Consumer<ProfileViewModel>(
                  builder: (context, profileVM, child) {
                    return AppButton(
                      text: 'Add Profile',
                      onPressed: _saveProfile,
                      isLoading: profileVM.isLoading,
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
