import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box themeBox;

  ThemeBloc(this.themeBox) : super(ThemeState.initial()) {
    on<InitializeTheme>(_onInitializeTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onInitializeTheme(InitializeTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = themeBox.get('isDarkMode', defaultValue: false);
    final themeData = isDarkMode ? ThemeState.darkTheme : ThemeState.lightTheme;
    emit(state.copyWith(isDarkMode: isDarkMode, themeData: themeData));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = !state.isDarkMode;
    themeBox.put('isDarkMode', isDarkMode);
    final themeData = isDarkMode ? ThemeState.darkTheme : ThemeState.lightTheme;
    emit(state.copyWith(isDarkMode: isDarkMode, themeData: themeData));
  }
}
