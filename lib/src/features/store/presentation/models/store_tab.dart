part of '../imports/store_imports.dart';

/// One bottom-bar tab. Every tab but [menu] is a storefront section with
/// its own WebView; [menu] is a native screen built from the site's menu.
///
/// Paths are Salla's standard storefront routes, so they work on any Salla
/// store; only [ConstantManager.storeUrl] changes per client.
enum StoreTab {
  home('/', Icons.home_outlined, Icons.home),
  offers('/offers', Icons.local_offer_outlined, Icons.local_offer),
  menu('', Icons.menu, Icons.menu_open),
  account('/account', Icons.person_outline, Icons.person);

  const StoreTab(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  bool get isWeb => this != menu;

  /// `/account` itself 301s, so the tab opens the profile page directly.
  WebUri get initialUrl => WebUri(
    '${ConstantManager.storeUrl}${this == account ? '/account/profile' : path}',
  );

  String get label => switch (this) {
    home => LocaleKeys.storeTabHome,
    offers => LocaleKeys.storeTabOffers,
    menu => LocaleKeys.storeTabMenu,
    account => LocaleKeys.storeTabAccount,
  };

  /// The tab a store link belongs to, or `null` for product / category /
  /// cart / checkout pages, which stay in whichever tab opened them.
  static StoreTab? forPath(String path) {
    if (path.isEmpty || path == home.path) return home;
    for (final tab in [offers, account]) {
      if (path == tab.path || path.startsWith('${tab.path}/')) return tab;
    }
    return null;
  }
}
