import 'package:flutter/material.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';
import 'package:imageflow_flutter/features/shell/domain/app_page.dart';
import 'package:imageflow_flutter/features/upload/domain/upload_file_item.dart';
import 'package:imageflow_flutter/shared/widgets/shared_widgets.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, required this.onNavigate});

  final ValueChanged<AppPage> onNavigate;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final List<UploadFileItem> _files = <UploadFileItem>[];

  void _addFiles() {
    final int start = _files.length;
    setState(() {
      _files.addAll(
        List<UploadFileItem>.generate(
          4,
          (int index) => UploadFileItem(
            id: 'file-${start + index + 1}',
            name: 'image-${(start + index + 1).toString().padLeft(3, '0')}.jpg',
            size: '${(2 + (index * 0.6)).toStringAsFixed(1)} MB',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalSize = _files.length * 3.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Upload Images', style: AppTheme.displayStyle(context, size: 30)),
        const SizedBox(height: 8),
        Text(
          'Upload a batch of images for processing',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _addFiles,
          child: AppSurface(
            padding: const EdgeInsets.all(36),
            child: Column(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.canvasSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(
                    Icons.file_upload_outlined,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop your images here',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'or click to browse from your computer',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _addFiles,
                  child: const Text('Browse Files'),
                ),
                const SizedBox(height: 14),
                Text(
                  'Supports: JPG, PNG, WEBP, TIFF. Max 50MB per file.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                ),
              ],
            ),
          ),
        ),
        if (_files.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          AppSurface(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_files.length} images uploaded',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(_files.clear),
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int crossAxisCount = constraints.maxWidth >= 1200
                        ? 6
                        : constraints.maxWidth >= 900
                        ? 4
                        : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                      children: _files.map((UploadFileItem file) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.canvasSoft,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppTheme.border,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: AppTheme.muted,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _files.removeWhere(
                                          (UploadFileItem item) =>
                                              item.id == file.id,
                                        ),
                                      ),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.danger,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: AppTheme.sand,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              file.size,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Text(
                      'Total size: ${totalSize.toStringAsFixed(1)} MB',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => widget.onNavigate(AppPage.taskBuilder),
                      child: const Text('Continue to Configuration'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
