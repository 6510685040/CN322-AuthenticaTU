class TOTPKey {
  final String key;
  final String label;
  String? issuer;

  TOTPKey({required this.key, required this.label, this.issuer});
}
