import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool timerEnabled;

  const SettingsState({this.timerEnabled = true});

  SettingsState copyWith({bool? timerEnabled}) {
    return SettingsState(
      timerEnabled: timerEnabled ?? this.timerEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleTimer() {
    state = state.copyWith(timerEnabled: !state.timerEnabled);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
