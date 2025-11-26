import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_colors.dart';
import 'core/config/app_styles.dart';
import 'core/di/service_locator.dart';
import 'generated/app_localizations.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'logic/client/client_bloc.dart';
import 'logic/driver/driver_bloc.dart';
import 'logic/language/language_cubit.dart';
import 'logic/language/language_state.dart';
import 'presentation/screens/auth/language_selection_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/client/client_screen.dart';
import 'presentation/screens/driver/driver_screen.dart';

/// Root app widget that manages global BLoCs and routing.
class TaxiApp extends StatelessWidget {
  const TaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<LanguageCubit>(
          create: (_) => getIt<LanguageCubit>()..loadLocale(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          // Show loading while checking language
          if (langState.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          // Show language selection if no locale is set
          if (langState.locale == null) {
            return const LanguageSelectionScreen();
          }

          // Main app with locale set
          return MaterialApp(
            title: 'Safar One',
            debugShowCheckedModeBanner: false,
            locale: langState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fa', ''),
            ],
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.background,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimary),
                titleTextStyle: AppStyles.body,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppStyles.button,
                  minimumSize: const Size(double.infinity, AppStyles.buttonHeight),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.secondary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                hintStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                // Show loading while checking auth status
                if (authState is AuthInitial || authState is AuthLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Show appropriate screen based on auth state
                if (authState is Authenticated) {
                  // Provide screen-specific BLoCs based on user type
                  if (authState.userType == 'client') {
                    return BlocProvider<ClientBloc>(
                      create: (_) => getIt<ClientBloc>(),
                      child: const ClientScreen(),
                    );
                  } else {
                    return BlocProvider<DriverBloc>(
                      create: (_) => getIt<DriverBloc>(),
                      child: const DriverScreen(),
                    );
                  }
                }

                // Show login screen if not authenticated
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
