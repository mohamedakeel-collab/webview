part of '../imports/store_imports.dart';

/// One bottom-bar tab = one storefront section.
///
/// Paths are Salla's standard storefront routes, so they work on any Salla
/// store; only [ConstantManager.storeUrl] changes per client.
enum StoreTab {
  home('/', Icons.home_outlined, Icons.home),
  offers('/offers', Icons.local_offer_outlined, Icons.local_offer),
  cart('/cart', Icons.shopping_cart_outlined, Icons.shopping_cart),
  account('/account', Icons.person_outline, Icons.person);

  const StoreTab(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  /// `/account` itself 301s, so the tab opens the profile page directly.
  WebUri get initialUrl => WebUri(
    '${ConstantManager.storeUrl}${this == account ? '/account/profile' : path}',
  );

  String get label => switch (this) {
    home => LocaleKeys.storeTabHome,
    offers => LocaleKeys.storeTabOffers,
    cart => LocaleKeys.storeTabCart,
    account => LocaleKeys.storeTabAccount,
  };

  /// The tab a store link belongs to, or `null` for product / category /
  /// checkout pages, which stay in whichever tab opened them.
  static StoreTab? forPath(String path) {
    if (path.isEmpty || path == home.path) return home;
    for (final tab in [offers, cart, account]) {
      if (path == tab.path || path.startsWith('${tab.path}/')) return tab;
    }
    return null;
  }
}
