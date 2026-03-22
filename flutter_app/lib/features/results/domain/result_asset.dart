class ResultAsset {
  const ResultAsset({
    required this.id,
    required this.name,
    required this.size,
    required this.transforms,
  });

  final int id;
  final String name;
  final String size;
  final List<String> transforms;
}
