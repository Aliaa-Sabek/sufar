import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../auth/widgets/custom_text_field.dart';
import '../theme/widgets/process_loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({super.key, required this.userModel});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalityController;
  late TextEditingController _dobController;

  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _errorMessage;

  static const _genderOptions = [
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _emailController = TextEditingController(text: widget.userModel.email);
    _phoneController = TextEditingController(
      text: widget.userModel.phone ?? '',
    );
    _nationalityController = TextEditingController(
      text: widget.userModel.nationality ?? '',
    );
    _selectedGender = widget.userModel.gender;
    if (widget.userModel.dateOfBirth != null &&
        widget.userModel.dateOfBirth!.isNotEmpty) {
      try {
        _dateOfBirth = DateTime.parse(widget.userModel.dateOfBirth!);
      } catch (_) {}
    }
    _dobController = TextEditingController(
      text: _dateOfBirth != null
          ? Booking.formatDisplayDate(_dateOfBirth!.toIso8601String())
          : '',
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = Booking.formatDisplayDate(
          picked.toIso8601String(),
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final nationality = _nationalityController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty.');
      return;
    }

    try {
      await ProcessLoadingOverlay.run(
        context: context,
        title: 'Updating Profile',
        steps: ProcessLoadingPresets.profileSave,
        task: (ctrl) async {
          await ctrl.jumpTo(0);

          final result = await ApiService.updateProfile({
            'fullName': name,
            'phone': phone,
            'nationality': nationality,
            if (_dateOfBirth != null)
              'dateOfBirth': _dateOfBirth!.toIso8601String().split('T').first,
            if (_selectedGender != null && _selectedGender!.isNotEmpty)
              'gender': _selectedGender,
          });

          await ctrl.advance();

          final updatedUser = UserModel.fromApiResponse(result);
          if (updatedUser != null) {
            final prefs = await SharedPreferences.getInstance();
            final merged = widget.userModel.mergeWith(updatedUser);
            await prefs.setString(
              'backend_user',
              jsonEncode(merged.toStorageJson()),
            );
            if (merged.email.isNotEmpty) {
              await prefs.setString('logged_in_email', merged.email);
            }
            if (merged.name.isNotEmpty) {
              await prefs.setString('logged_in_name', merged.name);
            }
          }

          return true;
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Color(0xFF0D1C52))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D1C52)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // Profile Picture placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE8F1F6),
                    child: Text(
                      widget.userModel.initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A94C4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).cardColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Form Fields
            CustomTextField(hintText: 'Full Name', controller: _nameController),
            SizedBox(height: 16),

            // Email (disabled/read-only)
            Opacity(
              opacity: 0.5,
              child: IgnorePointer(
                child: CustomTextField(
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(height: 16),

            CustomTextField(
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              controller: _phoneController,
            ),
            SizedBox(height: 16),

            CustomTextField(
              hintText: 'Nationality',
              controller: _nationalityController,
            ),
            SizedBox(height: 16),

            CustomTextField(
              hintText: 'Date of Birth',
              controller: _dobController,
              readOnly: true,
              onTap: _pickDateOfBirth,
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]!
                    : const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue:
                      _selectedGender != null &&
                          _genderOptions.contains(_selectedGender)
                      ? _selectedGender
                      : null,
                  hint: Text(
                    'Gender',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  isExpanded: true,
                  items: _genderOptions
                      .map(
                        (g) =>
                            DropdownMenuItem<String>(value: g, child: Text(g)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
            ),
            SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A94C4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
