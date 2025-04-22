class TOTPKey {
  final String key;
  final String label;
  String? issuer;

  TOTPKey({required this.key, required this.label, this.issuer});

  @override
  String toString() {
    return 'TOTPKey(key: $key, label: $label, issuer: ${issuer ?? "null"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TOTPKey && other.key == key && other.label == label;
  }

  @override
  int get hashCode => key.hashCode ^ label.hashCode;
}
