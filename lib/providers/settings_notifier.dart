import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool timerEnabled;
  final bool isDarkMode;

  const SettingsState({this.timerEnabled = true, this.isDarkMode = false});

  SettingsState copyWith({bool? timerEnabled, bool? isDarkMode}) {
    return SettingsState(
      timerEnabled: timerEnabled ?? this.timerEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleTimer() {
    state = state.copyWith(timerEnabled: !state.timerEnabled);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
