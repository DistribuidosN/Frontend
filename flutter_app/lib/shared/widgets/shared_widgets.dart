import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imageflow_flutter/core/theme/app_theme.dart';

enum LuminousBrandTone { onLight, onDark, mono }

class LuminousLogo extends StatelessWidget {
  const LuminousLogo({
    super.key,
    required this.tone,
    this.iconOnly = false,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final LuminousBrandTone tone;
  final bool iconOnly;
  final double? width;
  final double? height;
  final BoxFit fit;

  static const String _assetPath = 'assets/branding/enfok_logo_lossless.svg';
  static const double _assetAspectRatio = 415 / 162;

  @override
  Widget build(BuildContext context) {
    final double resolvedHeight = height ?? (iconOnly ? 44 : 58);
    final double resolvedWidth =
        width ??
        (iconOnly ? resolvedHeight * 1.36 : resolvedHeight * _assetAspectRatio);
    return SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: Semantics(
        label: 'Enfok',
        image: true,
        child: SvgPicture.asset(
          _assetPath,
          width: resolvedWidth,
          height: resolvedHeight,
          fit: fit,
        ),
      ),
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.gradient,
    this.borderColor,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppRadii radii = theme.extension<AppRadii>() ?? AppTheme.radii;
    final AppSpacing spacing =
        theme.extension<AppSpacing>() ?? AppTheme.spacing;

    return Container(
      padding: padding ?? EdgeInsets.all(spacing.xxl),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.surfaceRaised) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius ?? radii.lg),
        border: Border.all(
          color: borderColor ?? AppTheme.outlineVariant,
          width: 1.1,
        ),
        boxShadow: shadow ?? AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

class SectionPanel extends StatelessWidget {
  const SectionPanel({
    super.key,
    required this.title,
    this.description,
    this.action,
    required this.child,
  });

  final String title;
  final String? description;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppSpacing spacing =
        Theme.of(context).extension<AppSpacing>() ?? AppTheme.spacing;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = action != null && constraints.maxWidth < 900;

        return AppSurface(
          radius: AppTheme.radii.xl,
          color: AppTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _SectionHeaderCopy(
                          title: title,
                          description: description,
                        ),
                        SizedBox(height: spacing.lg),
                        action!,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: _SectionHeaderCopy(
                            title: title,
                            description: description,
                          ),
                        ),
                        if (action != null) ...<Widget>[
                          SizedBox(width: spacing.md),
                          action!,
                        ],
                      ],
                    ),
              SizedBox(height: spacing.lg),
              Divider(color: AppTheme.outlineVariant),
              SizedBox(height: spacing.xl),
              child,
            ],
          ),
        );
      },
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.kicker,
    required this.title,
    required this.description,
    this.actions,
  });

  final String kicker;
  final String title;
  final String description;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final AppSpacing spacing =
        Theme.of(context).extension<AppSpacing>() ?? AppTheme.spacing;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = actions != null && constraints.maxWidth < 1080;

        final Widget copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Kicker(text: kicker, icon: Icons.insights_outlined),
            SizedBox(height: spacing.lg),
            Text(title, style: AppTheme.displayStyle(context, size: 32)),
            SizedBox(height: spacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.slate,
                  height: 1.7,
                ),
              ),
            ),
          ],
        );

        return AppSurface(
          radius: AppTheme.radii.xl,
          color: AppTheme.surfaceRaised,
          padding: EdgeInsets.all(spacing.section),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    copy,
                    if (actions != null) ...<Widget>[
                      SizedBox(height: spacing.xl),
                      actions!,
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: copy),
                    if (actions != null) ...<Widget>[
                      SizedBox(width: spacing.xl),
                      actions!,
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.childAspectRatio = 1.2,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double childAspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = math.max(
          1,
          (constraints.maxWidth / minItemWidth).floor(),
        );
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: count,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              letterSpacing: 0.15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    required this.color,
    this.background = AppTheme.border,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: background,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

class RangeField extends StatelessWidget {
  const RangeField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '${value.round()}$suffix',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class TogglePill extends StatelessWidget {
  const TogglePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.navy.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.surfaceContainer : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radii.md),
            border: Border.all(
              color: selected ? AppTheme.secondary : AppTheme.outlineVariant,
            ),
            boxShadow: selected ? AppTheme.softShadow : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.navy),
          ),
        ),
      ),
    );
  }
}

class MiniLabel extends StatelessWidget {
  const MiniLabel({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
            color: AppTheme.slate,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class FilterField extends StatelessWidget {
  const FilterField({
    super.key,
    required this.icon,
    required this.label,
    this.width,
  });

  final IconData icon;
  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width ?? 360, minHeight: 48),
      child: TextField(
        decoration: InputDecoration(hintText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}

class ChipFilter extends StatelessWidget {
  const ChipFilter({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.displayStyle(context, size: 28, color: color),
          ),
        ],
      ),
    );
  }
}

class ImageComparisonCard extends StatelessWidget {
  const ImageComparisonCard({
    super.key,
    required this.label,
    required this.grayscale,
  });

  final String label;
  final bool grayscale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.slate),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.canvasSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 54,
                color: grayscale ? AppTheme.slate : AppTheme.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SmallIconButton extends StatelessWidget {
  const SmallIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radii.sm),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radii.sm),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Icon(icon, size: 18, color: AppTheme.ink),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppTheme.radii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppTheme.ink),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.slate,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderCopy extends StatelessWidget {
  const _SectionHeaderCopy({required this.title, required this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (description != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              description!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.slate),
            ),
          ],
        ],
      ),
    );
  }
}
