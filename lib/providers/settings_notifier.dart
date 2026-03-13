import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameType { digit, symbol }

class SettingsState {
  final bool timerEnabled;
  final bool isDarkMode;
  final GameType gameType;

  const SettingsState({
    this.timerEnabled = true,
    this.isDarkMode = false,
    this.gameType = GameType.digit,
  });

  SettingsState copyWith({
    bool? timerEnabled,
    bool? isDarkMode,
    GameType? gameType,
  }) {
    return SettingsState(
      timerEnabled: timerEnabled ?? this.timerEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      gameType: gameType ?? this.gameType,
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

  void setGameType(GameType type) {
    state = state.copyWith(gameType: type);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
