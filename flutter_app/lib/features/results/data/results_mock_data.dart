import 'package:imageflow_flutter/features/results/domain/result_asset.dart';

final List<ResultAsset> resultAssets = List<ResultAsset>.generate(
  12,
  (int index) => ResultAsset(
    id: index + 1,
    name: 'image-${(index + 1).toString().padLeft(3, '0')}.jpg',
    size: '${(1.1 + (index % 4) * 0.3).toStringAsFixed(1)} MB',
    transforms: const <String>['Grayscale', 'Resize', 'Sharpen'],
  ),
);

const List<String> sampleTransforms = <String>[
  'Grayscale',
  'Resize: 1920x1080',
  'Brightness: +10%',
  'Format: JPG',
];
