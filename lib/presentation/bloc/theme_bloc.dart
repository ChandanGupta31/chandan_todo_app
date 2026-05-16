import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class ThemeEvent {}
class ToggleThemeEvent extends ThemeEvent {}

// --- States ---
class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

// --- BLoC Engine ---
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ToggleThemeEvent>((event, emit) {
      if (state.themeMode == ThemeMode.light) {
        emit(const ThemeState(ThemeMode.dark));
      } else {
        emit(const ThemeState(ThemeMode.light));
      }
    });
  }
}