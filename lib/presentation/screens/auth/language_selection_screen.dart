import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../logic/language/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Language selection screen shown on first app launch.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 24),
                const Text(
                  "Select Language / ژبه وټاکئ",
                  textAlign: TextAlign.center,
                  style: AppStyles.title,
                ),
                const Spacer(flex: 1),
                _LanguageButton(
                  label: "English",
                  onPressed: () {
                    context.read<LanguageCubit>().setLocale(const Locale('en'));
                  },
                ),
                const SizedBox(height: 16),
                _LanguageButton(
                  label: "دری",
                  onPressed: () {
                    context.read<LanguageCubit>().setLocale(const Locale('fa'));
                  },
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _LanguageButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: AppStyles.headline.copyWith(color: Colors.white)),
      ),
    );
  }
}
