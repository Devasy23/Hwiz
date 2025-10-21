import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/profile.dart';
import '../../widgets/forms/profile_form_fields.dart';

/// Screen for creating or editing a profile
class ProfileFormScreen extends StatefulWidget {
  final Profile? profile; // Null for new profile, non-null for editing

  const ProfileFormScreen({
    super.key,
    this.profile,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isSaving = false;

  bool get isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Pre-fill form with existing data
      _nameController.text = widget.profile!.name;
      _selectedGender = widget.profile!.gender;
      if (widget.profile!.dateOfBirth != null) {
        try {
          _selectedDate = DateTime.parse(widget.profile!.dateOfBirth!);
          _dobController.text = _formatDate(_selectedDate!);
        } catch (e) {
          // Invalid date format
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Add Profile'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Name field
            ProfileFormFields.nameField(
              controller: _nameController,
            ),
            const SizedBox(height: 20),

            // Date of Birth field
            ProfileFormFields.dateOfBirthField(
              context: context,
              selectedDate: _selectedDate,
              onTap: _selectDate,
              controller: _dobController,
            ),
            const SizedBox(height: 20),

            // Gender field
            ProfileFormFields.genderField(
              selectedGender: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Info card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Additional profile details can be added later when analyzing blood reports.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEditing ? 'Update Profile' : 'Create Profile',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await ProfileFormFields.showDatePickerDialog(
      context,
      initialDate: _selectedDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = ProfileFormFields.formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return ProfileFormFields.formatDate(date);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<ProfileViewModel>();
    bool success;

    if (isEditing) {
      // Update existing profile
      final updatedProfile = widget.profile!.copyWith(
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate?.toIso8601String().split('T')[0],
        gender: _selectedGender,
      );
      success = await viewModel.updateProfile(updatedProfile);
    } else {
      // Create new profile
      success = await viewModel.createProfile(
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate?.toIso8601String().split('T')[0],
        gender: _selectedGender,
      );
    }

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Profile updated successfully'
                : 'Profile created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error ?? 'Failed to save profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
