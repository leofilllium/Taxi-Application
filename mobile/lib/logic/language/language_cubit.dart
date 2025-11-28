import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

/// Cubit for managing app language/locale.
class LanguageCubit extends Cubit<LanguageState> {
  static const String _languageCodeKey = 'language_code';

  LanguageCubit() : super(const LanguageState(isLoading: true));

  /// Load the saved locale from SharedPreferences.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    
    if (languageCode != null) {
      emit(state.copyWith(
        locale: Locale(languageCode),
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Set a new locale and save it to SharedPreferences.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    emit(state.copyWith(locale: locale, isLoading: false));
  }
}
