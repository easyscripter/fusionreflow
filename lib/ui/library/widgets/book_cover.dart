import 'package:flutter/material.dart';
import 'package:fusionreflow/ui/core/theme/app_dimens.dart';
import 'package:fusionreflow/ui/core/theme/app_text_theme.dart';

/// Обложка-заглушка 2:3: автор сверху, название снизу, цвет из палитры.
class BookCover extends StatelessWidget {
  /// Creates the cover; [title] is already the text to show.
  const new({
    required this.title,
    required this.color,
    this.author,
    this.child,
    super.key,
  });

  final String title;
  final String? author;
  final Color color;

  /// Поверх обложки (затемнение и прогресс импорта).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.cover),
        child: ColoredBox(
          color: color,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      Text(
                        author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(color: Colors.white70),
                      ),
                    const Spacer(),
                    // Flexible: на маленькой обложке название сжимается, а не
                    // вылезает за край.
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          color: Colors.white,
                          fontFamily: AppFonts.book,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}
