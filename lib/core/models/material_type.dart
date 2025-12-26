enum MaterialType {
  cardboard,
  glass,
  metal,
  paper,
  plastic;

  String get value => name;

  static MaterialType? fromString(String value) {
    try {
      return MaterialType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

