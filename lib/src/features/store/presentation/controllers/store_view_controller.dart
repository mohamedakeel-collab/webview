part of '../imports/store_imports.dart';

/// Coordinates the four tab WebViews: which ones exist, tab switching,
/// and the Android back button.
class StoreViewController {
  StoreViewController({required this.onSelectTab}) {
    for (final tab in StoreTab.values) {
      _tabs[tab] = StoreWebController(
        tab: tab,
        onTabLink: _openInTab,
        cartTracker: _cartTracker,
      );
    }

    _push.pendingLink.addListener(_openPushLink);
    _openPushLink();
  }

  /// Home's first page is on screen with its products; the splash hides.
  ValueListenable<bool> get isReady => controllerOf(StoreTab.home).isReady;

  final CartTracker _cartTracker = CartTracker();

  final _push = PushNotificationService.instance;

  final ValueChanged<StoreTab> onSelectTab;

  final Map<StoreTab, StoreWebController> _tabs = {};

  /// Launch loads Home alone; another tab's WebView is built on its first
  /// visit, so only the pages the user opens ever load.
  final Set<StoreTab> _opened = {StoreTab.home};

  StoreWebController controllerOf(StoreTab tab) => _tabs[tab]!;

  bool isOpened(StoreTab tab) => _opened.contains(tab);

  /// Tapping the active tab again takes it back to its root page.
  void select(StoreTab tab, {required StoreTab current}) {
    if (tab == current) {
      controllerOf(tab).openRoot();
      return;
    }
    _opened.add(tab);
    onSelectTab(tab);
  }

  /// A link inside one tab pointed at another tab's section.
  void _openInTab(StoreTab tab, WebUri url) {
    final controller = controllerOf(tab);
    final alreadyOpened = _opened.contains(tab);
    _opened.add(tab);
    onSelectTab(tab);
    // A tab built just now loads its own root, and an open one may already
    // show the page — unless the cart changed since, which a server-rendered
    // cart page or header badge wouldn't reflect.
    if (!alreadyOpened && url.path == tab.path) return;
    if (controller.isShowing(url)) return;
    controller.open(url);
  }

  /// A store link opens in the tab it belongs to (product pages in Home);
  /// any other site opens outside the app.
  void _openPushLink() {
    final link = _push.pendingLink.value;
    if (link == null) return;
    _push.pendingLink.value = null;
    if (link.host != ConstantManager.storeHost) {
      launchUrl(link, mode: LaunchMode.externalApplication);
      return;
    }
    final tab = StoreTab.forPath(link.path) ?? StoreTab.home;
    _opened.add(tab);
    onSelectTab(tab);
    controllerOf(tab).open(WebUri.uri(link));
  }

  /// Back walks the WebView history, then returns to Home, then exits.
  Future<void> handleBack(StoreTab current) async {
    if (await controllerOf(current).goBack()) return;
    if (current != StoreTab.home) {
      onSelectTab(StoreTab.home);
      return;
    }
    await SystemNavigator.pop();
  }

  void dispose() {
    _push.pendingLink.removeListener(_openPushLink);
    for (final controller in _tabs.values) {
      controller.dispose();
    }
  }
}
