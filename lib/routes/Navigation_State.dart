class NavigationState {
  final List<String> historyStack;
  final DateTime? lastBackPress;
  final int maxHistorySize;

  const NavigationState({
    this.historyStack = const [],
    this.lastBackPress,
    this.maxHistorySize = 10,
  });

  NavigationState copyWith({
    List<String>? historyStack,
    DateTime? lastBackPress,
    int? maxHistorySize,
  }) {
    return NavigationState(
      historyStack: historyStack ?? this.historyStack,
      lastBackPress: lastBackPress,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
    );
  }

  bool get canGoBack => historyStack.length > 1;
}