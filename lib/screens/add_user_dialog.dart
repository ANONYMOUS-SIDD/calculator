// lib/screens/add_user_dialog.dart

import 'dart:io';

import 'package:calculators/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Dialog for creating new users or editing existing user profiles
///
/// Supports both create and edit modes with image selection and validation
class AddUserDialog extends StatefulWidget {
  final Function(String username, String? imagePath) onUserAdded;
  final User? userToEdit;
  final Function(String username, String? imagePath)? onUserUpdated;

  const AddUserDialog({super.key, required this.onUserAdded, this.userToEdit, this.onUserUpdated});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _errorText;
  bool _hasInteractedWithName = false;
  bool _isInputFocused = false;

  /// Determines if the dialog is in edit mode
  bool get _isEditMode => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill data if in edit mode
    if (_isEditMode) {
      _usernameController.text = widget.userToEdit!.username;
      _pickedImagePath = widget.userToEdit!.profileImagePath;
    }
  }

  /// Validates username input with duplicate checking
  String? _validateUsername(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Please enter a username';
    }

    if (trimmedValue.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmedValue.length > 10) {
      return 'Username must not exceed 10 characters';
    }

    // Check for duplicate usernames (excluding current user in edit mode)
    if (_isUsernameExists(trimmedValue)) {
      return 'Username already exists';
    }

    return null;
  }

  /// Checks if username already exists in the database
  bool _isUsernameExists(String username) {
    final userBox = Hive.box<User>('usersBox');
    final users = userBox.values.toList().cast<User>();

    if (_isEditMode) {
      // In edit mode, exclude current user from duplicate check
      return users.any((user) => user.username.toLowerCase() == username.toLowerCase() && user.username != widget.userToEdit!.username);
    } else {
      // In create mode, check all users
      return users.any((user) => user.username.toLowerCase() == username.toLowerCase());
    }
  }

  /// Capitalizes the first letter of the username
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Handles username input changes and validation
  void _onUsernameChanged(String value) {
    setState(() {
      _hasInteractedWithName = true;
      _errorText = _validateUsername(value);
    });
  }

  /// Determines if the form is valid for submission
  bool get _isFormValid {
    final username = _usernameController.text.trim();
    return username.isNotEmpty && username.length >= 3 && username.length <= 10 && !_isUsernameExists(username) && _pickedImagePath != null;
  }

  /// Opens image picker with permission handling
  Future<void> _pickImage(ImageSource source) async {
    // Request appropriate permissions
    if (source == ImageSource.camera) {
      if (!(await Permission.camera.request().isGranted)) return;
    } else {
      if (!(await Permission.photos.request().isGranted)) return;
    }

    final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);

    if (image != null) {
      setState(() => _pickedImagePath = image.path);
    }

    if (mounted) Navigator.pop(context);
  }

  /// Shows bottom sheet for selecting image source
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: const Color(0xFFF8FAFF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: const Color(0xFF5A6C8A).withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                  ),

                  // Image source options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE1E8F5), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ImageOption(icon: Icons.photo_library, label: 'Gallery', onTap: () => _pickImage(ImageSource.gallery)),
                          ),
                          Container(width: 1, height: 40, color: const Color(0xFFE1E8F5)),
                          Expanded(
                            child: _ImageOption(icon: Icons.camera_alt, label: 'Camera', onTap: () => _pickImage(ImageSource.camera)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Saves user data and calls appropriate callback
  void _saveUser() {
    final username = _usernameController.text.trim();
    final validationError = _validateUsername(username);

    if (validationError != null || _pickedImagePath == null) {
      setState(() {
        _errorText = validationError;
        _hasInteractedWithName = true;
      });
      return;
    }

    // Capitalize username before saving
    final capitalizedUsername = _capitalizeFirstLetter(username);

    if (_isEditMode) {
      widget.onUserUpdated?.call(capitalizedUsername, _pickedImagePath);
    } else {
      widget.onUserAdded(capitalizedUsername, _pickedImagePath);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.12), blurRadius: 25, spreadRadius: 1, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header section with profile picture
              _buildHeaderSection(),
              const SizedBox(height: 16),

              // Username input field
              _buildUsernameInput(),
              const SizedBox(height: 16),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds header section with profile picture and title
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E8F5), width: 1.5),
      ),
      child: Column(
        children: [
          // Profile picture with edit button
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: _pickedImagePath == null ? const Color(0xFFFF6B35).withOpacity(0.3) : const Color(0xFF00B8FF), width: _pickedImagePath == null ? 2 : 2.5),
                  boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(_pickedImagePath == null ? 0.1 : 0.2), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: ClipOval(child: _buildProfileImage()),
              ),

              // Add/Change image button
              Positioned(
                bottom: -1,
                right: -1,
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _pickedImagePath == null ? const Color(0xFFFF6B35) : const Color(0xFF0066FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Icon(_pickedImagePath != null ? Icons.edit_rounded : Icons.add_a_photo_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title based on mode
          Text(
            _isEditMode ? 'Edit Player' : 'Create Player',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
          ),

          const SizedBox(height: 2),

          Text(
            _isEditMode ? 'Update profile picture' : 'Add name and profile picture',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A), fontWeight: FontWeight.w500),
          ),

          // Required profile picture indicator
          if (_pickedImagePath == null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFF6B35).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(
                'Profile picture required',
                style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFFFF6B35), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds username input field with mode-specific behavior
  Widget _buildUsernameInput() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!_isEditMode) {
          setState(() {
            _isInputFocused = hasFocus;
          });
        }
      },
      child: AbsorbPointer(
        absorbing: _isEditMode,
        child: TextField(
          controller: _usernameController,
          enabled: !_isEditMode,
          style: GoogleFonts.poppins(color: _isEditMode ? const Color(0xFF5A6C8A).withOpacity(0.6) : const Color(0xFF1A1D2B), fontWeight: FontWeight.w500, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: GoogleFonts.poppins(color: _isEditMode ? const Color(0xFF5A6C8A).withOpacity(0.5) : (_isInputFocused ? const Color(0xFF0066FF) : const Color(0xFF5A6C8A).withOpacity(0.7)), fontSize: _isInputFocused || _usernameController.text.isNotEmpty ? 12 : 15, fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _isEditMode ? const Color(0xFFE1E8F5).withOpacity(0.5) : const Color(0xFFE1E8F5), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _isEditMode ? const Color(0xFFE1E8F5).withOpacity(0.5) : (_errorText != null && _hasInteractedWithName ? Colors.red : const Color(0xFFE1E8F5)), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _isEditMode ? const Color(0xFFE1E8F5).withOpacity(0.5) : const Color(0xFF0066FF), width: 1.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.person_outline_rounded, size: 20, color: _isEditMode ? const Color(0xFF5A6C8A).withOpacity(0.4) : (_isInputFocused ? const Color(0xFF0066FF) : const Color(0xFF5A6C8A).withOpacity(0.6))),
            ),
            filled: true,
            fillColor: _isEditMode ? const Color(0xFFF8FAFF) : Colors.white,
            errorText: _hasInteractedWithName ? _errorText : null,
            errorStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.red),
            hintText: _isEditMode ? 'Username cannot be changed' : null,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF5A6C8A).withOpacity(0.5), fontStyle: FontStyle.italic),
          ),
          onChanged: _isEditMode ? null : _onUsernameChanged,
          textCapitalization: TextCapitalization.words,
          maxLength: 10,
          buildCounter: (BuildContext context, {required int currentLength, required int? maxLength, required bool isFocused}) => null,
        ),
      ),
    );
  }

  /// Builds action buttons (Cancel and Create/Update)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A6C8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFE1E8F5), width: 1.5),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Create/Update button
        Expanded(
          child: SizedBox(
            height: 44,
            child: Container(
              decoration: BoxDecoration(
                gradient: _isFormValid ? const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isFormValid ? const Color(0xFFFF6B35).withOpacity(0.3) : Colors.grey.shade400, width: 1.5),
                boxShadow: _isFormValid ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
              ),
              child: ElevatedButton(
                onPressed: _isFormValid ? _saveUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEditMode ? Icons.save_rounded : Icons.person_add_alt_1_rounded, size: 15, color: _isFormValid ? Colors.white : Colors.grey.shade600),
                    const SizedBox(width: 5),
                    Text(
                      _isEditMode ? 'Update' : 'Create',
                      style: GoogleFonts.poppins(color: _isFormValid ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds profile image widget with error handling
  Widget _buildProfileImage() {
    if (_pickedImagePath == null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [const Color(0xFFFF6B35).withOpacity(0.1), const Color(0xFFFF8C42).withOpacity(0.05)]),
        ),
        child: Icon(Icons.person_rounded, size: 28, color: const Color(0xFFFF6B35).withOpacity(0.4)),
      );
    }

    try {
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 70,
          height: 70,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage();
          },
        );
      } else {
        return _buildErrorImage();
      }
    } catch (e) {
      return _buildErrorImage();
    }
  }

  /// Builds error state for profile image
  Widget _buildErrorImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [const Color(0xFFFF6B6B).withOpacity(0.1), const Color(0xFFFFE66D).withOpacity(0.1)]),
      ),
      child: Icon(Icons.error_outline, size: 28, color: const Color(0xFFFF6B6B).withOpacity(0.6)),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}

/// Custom widget for image source selection option
class _ImageOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: const Color(0xFF0066FF)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B)),
            ),
          ],
        ),
      ),
    );
  }
}
