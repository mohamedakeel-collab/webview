part of '../imports/store_imports.dart';

/// One entry of the storefront's main menu: a link, or a section whose
/// [children] are links.
class StoreMenuItem {
  const StoreMenuItem({
    required this.title,
    this.url,
    this.children = const [],
  });

  factory StoreMenuItem.fromJson(Map<dynamic, dynamic> json) {
    final url = json['url'];
    final children = json['children'];
    return StoreMenuItem(
      title: json['title']?.toString() ?? '',
      url: url is String && url.isNotEmpty ? WebUri(url) : null,
      children: children is List
          ? children.whereType<Map>().map(StoreMenuItem.fromJson).toList()
          : const [],
    );
  }

  final String title;
  final WebUri? url;
  final List<StoreMenuItem> children;
}
