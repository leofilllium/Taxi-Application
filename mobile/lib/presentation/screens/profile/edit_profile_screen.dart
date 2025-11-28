import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/profile/profile_cubit.dart';
import '../../../logic/profile/profile_state.dart';

/// Edit profile screen for updating user information
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.profileData['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _newImage = image);
      }
    } catch (e) {
      if (mounted) {
        showAppDialog(context, title: "Error", content: "Could not select image");
      }
    }
  }

  void _saveProfile() {
    final fields = {
      'name': _nameController.text,
      'phone': _phoneController.text,
    };
    context.read<ProfileCubit>().updateProfile(fields, _newImage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          showAppSnackBar(context, state.message, isError: true);
        } else if (state is ProfileUpdated) {
          showAppSnackBar(context, l10n.profileUpdatedSuccessfully);
          Navigator.pop(context, true);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.backgroundSecondary,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppColors.background.withOpacity(0.9),
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(l10n.cancel, style: const TextStyle(color: AppColors.accentBlue)),
            onPressed: () => Navigator.pop(context),
          ),
          middle: Text(l10n.editProfile, style: AppStyles.headline),
          trailing: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileUpdating) {
                return const CupertinoActivityIndicator();
              }
              return CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(l10n.save, style: const TextStyle(color: AppColors.accentBlue)),
                onPressed: _saveProfile,
              );
            },
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile image
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.secondary,
                        backgroundImage: _newImage != null
                            ? FileImage(File(_newImage!.path))
                            : (widget.profileData['profileImageUrl'] != null
                                ? NetworkImage(widget.profileData['profileImageUrl'])
                                : const AssetImage('assets/images/logo.png'))
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.camera,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Name field
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: l10n.fullNameLabel,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(CupertinoIcons.person, color: AppColors.textSecondary),
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone field
                CupertinoTextField(
                  controller: _phoneController,
                  placeholder: l10n.phoneLabel,
                  keyboardType: TextInputType.phone,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(CupertinoIcons.phone, color: AppColors.textSecondary),
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
