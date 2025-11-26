import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/config/constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/api_service.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';

/// Login and registration screen with BLoC integration
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userType = 'client';

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _vehicleModel = TextEditingController();
  final _vehicleLicense = TextEditingController();
  final _vehicleColor = TextEditingController();
  final _vehicleYear = TextEditingController();
  String _vehicleType = "sedan";

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _vehicleModel.dispose();
    _vehicleLicense.dispose();
    _vehicleColor.dispose();
    _vehicleYear.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final compressedImage = await _compressImage(image);
        if (mounted) setState(() => _profileImage = compressedImage);
      }
    } catch (e) {
      if (mounted) {
        showAppDialog(
          context,
          title: "Image Error",
          content: "Could not select image: ${e.toString()}",
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final Uri url =
        Uri.parse('https://tradingai.academytable.ru/safar-privacy-policy.html');
    if (!await canLaunchUrl(url)) {
      if (mounted) {
        showAppSnackBar(context, 'Could not open the Privacy Policy.',
            isError: true);
      }
    } else {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<XFile?> _compressImage(XFile file) async {
    final filePath = file.path;
    const maxSizeInBytes = 1024 * 1024;
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    int quality = 80;
    XFile? compressedFile;

    while (quality > 10) {
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        tempPath,
        quality: quality,
        minHeight: 600,
        minWidth: 600,
      );
      if (compressedFile != null) {
        final compressedLength = await compressedFile.length();
        if (compressedLength <= maxSizeInBytes) return compressedFile;
      }
      quality -= 10;
    }
    return compressedFile ?? file;
  }

  Future<void> _submit() async {
    // 1. Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // 2. Additional validation for driver registration
    if (!_isLogin && _userType == 'driver' && _profileImage == null) {
      showAppSnackBar(
        context,
        'A profile image is required for driver registration.',
        isError: true,
      );
      return;
    }

    // 3. Call the appropriate AuthCubit method
    if (_isLogin) {
      context.read<AuthCubit>().login(
            email: _email.text,
            password: _password.text,
          );
    } else {
      // Build vehicle data for drivers
      Map<String, dynamic>? vehicleData;
      if (_userType == 'driver') {
        vehicleData = {
          'model': _vehicleModel.text,
          'licensePlate': _vehicleLicense.text,
          'color': _vehicleColor.text,
          'year': int.tryParse(_vehicleYear.text) ?? 2020,
          'type': _vehicleType,
        };
      }

      context.read<AuthCubit>().register(
            email: _email.text,
            password: _password.text,
            name: _name.text,
            phone: _phone.text,
            userType: _userType,
            vehicleData: vehicleData,
            profileImage: _profileImage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Show error dialog if authentication fails
        if (state is AuthError) {
          showAppDialog(
            context,
            title: _isLogin ? "Login Failed" : "Registration Failed",
            content: state.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _isLogin ? l10n.welcomeBack : l10n.createAccount,
                        style: AppStyles.title,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? l10n.signInToContinue : l10n.letsGetYouStarted,
                        style: AppStyles.subtitle,
                      ),
                      const SizedBox(height: 40),
                      if (!_isLogin) ..._buildRegisterFields(l10n),
                      ..._buildCommonFields(l10n),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppStyles.caption1
                                  .copyWith(color: AppColors.textSecondary),
                              children: [
                                TextSpan(text: l10n.byCreatingAccountYouAgree),
                                TextSpan(
                                  text: l10n.privacyPolicy,
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchPrivacyPolicy(context);
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: AppStyles.buttonHeight,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _isLogin
                                      ? l10n.signInButton
                                      : l10n.createAccountButton,
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: CupertinoButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? l10n.dontHaveAccount
                                : l10n.alreadyHaveAccount,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCommonFields(AppLocalizations l10n) {
    return [
      TextFormField(
        controller: _email,
        decoration: InputDecoration(
          labelText: l10n.emailLabel,
          prefixIcon: const Icon(CupertinoIcons.mail),
        ),
        validator: (v) => v!.isEmpty ? l10n.emailValidationError : null,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _password,
        obscureText: true,
        decoration: InputDecoration(
          labelText: l10n.passwordLabel,
          prefixIcon: const Icon(CupertinoIcons.lock),
        ),
        validator: (v) => v!.length < 6 ? l10n.passwordValidationError : null,
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildRegisterFields(AppLocalizations l10n) {
    return [
      TextFormField(
        controller: _name,
        decoration: InputDecoration(
          labelText: l10n.fullNameLabel,
          prefixIcon: const Icon(CupertinoIcons.person),
        ),
        validator: (v) => v!.isEmpty ? l10n.nameValidationError : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phone,
        decoration: InputDecoration(
          labelText: l10n.phoneLabel,
          prefixIcon: const Icon(CupertinoIcons.phone),
        ),
        validator: (v) => v!.isEmpty ? l10n.phoneValidationError : null,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _userType,
        decoration: InputDecoration(
          labelText: l10n.iAmA,
          prefixIcon: const Icon(CupertinoIcons.person_2),
        ),
        items: [
          DropdownMenuItem(value: 'client', child: Text(l10n.userTypeClient)),
          DropdownMenuItem(value: 'driver', child: Text(l10n.userTypeDriver)),
        ],
        onChanged: (v) => setState(() => _userType = v!),
      ),
      const SizedBox(height: 16),
      if (_userType == 'driver') ...[
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.secondary,
              backgroundImage: _profileImage != null
                  ? FileImage(File(_profileImage!.path))
                  : null,
              child: _profileImage == null
                  ? const Icon(
                      CupertinoIcons.camera,
                      color: AppColors.textSecondary,
                      size: 40,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(l10n.profilePicture, style: AppStyles.footnote)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.vehicleDetailsTitle, style: AppStyles.cardTitle),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleModel,
                decoration: InputDecoration(labelText: l10n.vehicleModelLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleLicense,
                decoration: InputDecoration(labelText: l10n.licensePlateLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleColor,
                decoration: InputDecoration(labelText: l10n.colorLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleYear,
                decoration: InputDecoration(labelText: l10n.yearLabel),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: InputDecoration(labelText: l10n.vehicleTypeLabel),
                items: [
                  DropdownMenuItem(
                    value: 'sedan',
                    child: Text(l10n.vehicleTypeSedan),
                  ),
                  DropdownMenuItem(
                    value: 'suv',
                    child: Text(l10n.vehicleTypeSuv),
                  ),
                  DropdownMenuItem(
                    value: 'hatchback',
                    child: Text(l10n.vehicleTypeHatchback),
                  ),
                  DropdownMenuItem(
                    value: 'minivan',
                    child: Text(l10n.vehicleTypeMinivan),
                  ),
                  DropdownMenuItem(
                    value: 'tuk-tuk',
                    child: Text(l10n.vehicleTypeTukTuk),
                  ),
                  DropdownMenuItem(
                    value: 'motorbike',
                    child: Text(l10n.vehicleTypeMotorbike),
                  ),
                ],
                onChanged: (v) => setState(() => _vehicleType = v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ];
  }
}
