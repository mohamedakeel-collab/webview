part of '../imports/store_imports.dart';

/// A menu link, or a section that expands to its links.
class _StoreMenuTile extends StatelessWidget {
  const _StoreMenuTile({required this.item, required this.onOpen});

  final StoreMenuItem item;
  final ValueChanged<WebUri> onOpen;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      item.title,
      style: const TextStyle().setMainTextColor.s16.bold,
    );
    final url = item.url;
    if (item.children.isEmpty) {
      return ListTile(
        title: title,
        trailing: const Icon(Icons.chevron_left, color: AppColors.hintText),
        onTap: url == null ? null : () => onOpen(url),
      );
    }
    return ExpansionTile(
      title: title,
      iconColor: AppColors.brand,
      collapsedIconColor: AppColors.hintText,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        for (final child in item.children)
          if (child.url case final childUrl?)
            ListTile(
              contentPadding: EdgeInsetsDirectional.only(
                start: AppPadding.pW16 * 2,
                end: AppPadding.pW16,
              ),
              title: Text(
                child.title,
                style: const TextStyle().setMainTextColor.s14,
              ),
              onTap: () => onOpen(childUrl),
            ),
      ],
    );
  }
}
