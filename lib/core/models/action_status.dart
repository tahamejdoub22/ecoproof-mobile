enum ActionStatus {
  pending,
  verified,
  rejected,
  flagged;

  String get value => name.toUpperCase();

  static ActionStatus? fromString(String value) {
    try {
      return ActionStatus.values.firstWhere(
        (e) => e.value == value.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

