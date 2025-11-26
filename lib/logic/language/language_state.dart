import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// State for language/localization management.
class LanguageState extends Equatable {
  final Locale? locale;
  final bool isLoading;

  const LanguageState({
    this.locale,
    this.isLoading = true,
  });

  LanguageState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [locale, isLoading];
}
