class Otps {
  final String key;
  final String label;
  String? issuer;

  Otps({required this.key, required this.label, this.issuer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Otps &&
          key == other.key &&
          label == other.label &&
          issuer == other.issuer;

  @override
  int get hashCode => key.hashCode ^ label.hashCode ^ (issuer?.hashCode ?? 0);
}
