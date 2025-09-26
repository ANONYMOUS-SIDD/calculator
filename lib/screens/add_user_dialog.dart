// lib/screens/add_user_dialog.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddUserDialog extends StatefulWidget {
  final Function(String username, String? imagePath) onUserAdded;

  const AddUserDialog({super.key, required this.onUserAdded});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _usernameController = TextEditingController();
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
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
                  // Small rounded rectangle line at top center
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: const Color(0xFF5A6C8A).withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                  ),

                  // Container wrapping the options
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.12), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with profile picture
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E8F5), width: 1.5),
                ),
                child: Column(
                  children: [
                    // Fixed Profile Picture Section - Image will display no matter what
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE1E8F5), width: 2),
                            boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: ClipOval(child: _buildProfileImage()),
                        ),

                        // Add/Change Photo Button
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Icon(_pickedImagePath != null ? Icons.edit : Icons.add, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Create Player',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
                    ),

                    const SizedBox(height: 2),

                    Text('Add name and profile picture', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A))),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Input Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E8F5), width: 1.5),
                ),
                child: Column(
                  children: [
                    // Name Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE1E8F5)),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: GoogleFonts.poppins(color: const Color(0xFF1A1D2B), fontWeight: FontWeight.w500, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter player name',
                          hintStyle: GoogleFonts.poppins(color: const Color(0xFF5A6C8A), fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person_outline, color: const Color(0xFF0066FF), size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons - Cancel and Create
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5A6C8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: const Color(0xFFE1E8F5), width: 1.5),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF00B8FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3), width: 1.5),
                          boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_usernameController.text.trim().isNotEmpty) {
                              widget.onUserAdded(_usernameController.text.trim(), _pickedImagePath);
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed image display method - will display image no matter what
  Widget _buildProfileImage() {
    if (_pickedImagePath == null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [const Color(0xFF0066FF).withOpacity(0.08), const Color(0xFF00B8FF).withOpacity(0.04)]),
        ),
        child: Icon(Icons.person, size: 28, color: const Color(0xFF0066FF).withOpacity(0.5)),
      );
    }

    try {
      // Try to load the image file
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 64,
          height: 64,
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

// Image Option Widget
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: const Color(0xFF0066FF)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF1A1D2B)),
            ),
          ],
        ),
      ),
    );
  }
}
