part of '../imports/store_imports.dart';

/// Owns one tab's WebView: loading progress, error state and link routing.
class StoreWebController {
  StoreWebController({
    required this.tab,
    required this.onTabLink,
    required this.cartTracker,
  });

  final StoreTab tab;

  final void Function(StoreTab tab, WebUri url) onTabLink;

  final CartTracker cartTracker;

  bool _disposed = false;

  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<bool> hasError = ValueNotifier(false);

  /// Becomes true once the first page shows its products, not just their
  /// skeletons. Salla's theme only asks for products after its tracking
  /// scripts settle — seconds after the page itself has loaded.
  final ValueNotifier<bool> isReady = ValueNotifier(false);

  /// A pull-to-refresh (or retry) is under way; the page is covered until
  /// its products show again, the same way the splash covers the launch.
  final ValueNotifier<bool> isRefreshing = ValueNotifier(false);

  static const _readyTimeout = Duration(seconds: 10);

  Timer? _readyTimer;

  /// The page on screen and the cart count when it loaded, so a preloaded
  /// tab is shown as-is unless the cart changed since.
  WebUri? _loadedUrl;
  int? _cartCountAtLoad;

  late final PullToRefreshController pullToRefresh = PullToRefreshController(
    settings: PullToRefreshSettings(color: AppColors.brand),
    onRefresh: reload,
  );

  InAppWebViewController? _web;

  /// A link sent here before the WebView exists becomes its first page.
  WebUri? _startUrl;

  WebUri get startUrl => _startUrl ?? tab.initialUrl;

  /// Hosts that should open in their own app instead of inside the store.
  static const _externalHosts = {
    'wa.me',
    'api.whatsapp.com',
    'instagram.com',
    'www.instagram.com',
    'twitter.com',
    'x.com',
    'snapchat.com',
    'www.snapchat.com',
    'tiktok.com',
    'www.tiktok.com',
    'facebook.com',
    'www.facebook.com',
    'maps.google.com',
    'goo.gl',
  };

  /// The storefront footer advertises "download our app" badges, which
  /// make no sense once the user is already inside the app.
  static const _injectedCss =
      '.store-footer__apps { display: none !important; }';

  /// The login modal's social buttons live inside Salla's cross-origin
  /// iframe (accounts.salla.com), which page-level CSS can't reach.
  /// Google / Facebook / Apple OAuth don't work in an embedded WebView,
  /// so this script adds a stylesheet *inside the iframe* hiding them and
  /// the "أو سجل دخولك من خلال" separator. A stylesheet (unlike inline
  /// styles) survives the iframe's re-renders.
  static final userScripts = UnmodifiableListView<UserScript>([
    UserScript(
      source: _hideSocialLoginJs,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: false,
      allowedOriginRules: {'https://accounts.salla.com'},
    ),
    UserScript(
      source: _hideWhatsAppOnLoginJs,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
    ),
  ]);

  /// The store's floating WhatsApp button covers the login modal's
  /// "دخول" button, so it's hidden while the login iframe is on screen.
  static const _hideWhatsAppOnLoginJs = r'''
(function () {
  if (location.hostname === 'accounts.salla.com') return;
  var targets =
    'a[href*="wa.me"], a[href*="whatsapp"],' +
    '[class*="whatsapp" i], [id*="whatsapp" i]';
  function loginOpen() {
    var f = document.querySelector('iframe[src*="accounts.salla.com"]');
    if (!f) return false;
    var r = f.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  }
  // The floating widget is the outermost fixed-position ancestor.
  function floatingRoot(el) {
    var root = null;
    for (var n = el; n && n !== document.body; n = n.parentElement) {
      if (getComputedStyle(n).position === 'fixed') root = n;
    }
    return root;
  }
  function update() {
    var value = loginOpen() ? 'hidden' : '';
    document.querySelectorAll(targets).forEach(function (el) {
      var root = floatingRoot(el);
      if (root && root.style.visibility !== value) {
        root.style.visibility = value;
      }
    });
  }
  new MutationObserver(update).observe(document.documentElement, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ['class', 'style'],
  });
  update();
})();
''';

  static const _hideSocialLoginJs = r'''
(function () {
  if (location.hostname !== 'accounts.salla.com') return;
  var style = document.createElement('style');
  style.textContent =
    '.s-login-modal-social-btn,' +
    '.s-login-modal-social-buttons,' +
    '[class*="s-login-modal-social-separator"]' +
    '{ display: none !important; }';
  function attach() {
    if (!style.isConnected) document.documentElement.appendChild(style);
  }
  attach();
  document.addEventListener('DOMContentLoaded', attach);
})();
''';
  static const _cartTrackerJs = r'''
(function () {
  if (window.top !== window) return;

  if (window.__fuonkhCartTrackerInstalled) return;
  window.__fuonkhCartTrackerInstalled = true;

  var hooked = false;
  var retryTimer = null;
  var attempts = 0;

  function validCount(value) {
    if (typeof value !== 'number' &&
        typeof value !== 'string') {
      return null;
    }

    if (typeof value === 'string' &&
        value.trim() === '') {
      return null;
    }

    var count = Number(value);

    if (!Number.isInteger(count) || count < 0) {
      return null;
    }

    return count;
  }

  function send(count, source) {
    var bridge = window.flutter_inappwebview;

    if (!bridge ||
        typeof bridge.callHandler !== 'function') {
      return;
    }

    bridge.callHandler('FuonkhCart', {
      count: count,
      source: source
    }).catch(function (error) {
      console.warn('[FuonkhCart] bridge error', error);
    });
  }

  function onUpdated(summary) {
    var count = validCount(
      summary && summary.count
    );

    // A failed or unknown reading is not zero.
    if (count === null) return;

    send(count, 'event');
  }

  function readInitial(s) {
    try {
      if (!s.storage ||
          typeof s.storage.get !== 'function') {
        return;
      }

      var count = validCount(
        s.storage.get('cart.summary.count')
      );

      if (count !== null) {
        send(count, 'initial');
      }
    } catch (error) {
      console.warn(
        '[FuonkhCart] initial read failed',
        error
      );
    }
  }

  function attach() {
    if (hooked) return true;

    var s = window.salla;

    if (!s ||
        !s.event ||
        typeof s.event.on !== 'function') {
      return false;
    }

    try {
      s.event.on('cart::updated', onUpdated);

      hooked = true;

      // The order page's URL varies, but Salla always names its
      // template "thank-you"; a finished order means an empty cart.
      var page = s.config && s.config.get && s.config.get('page');
      if (page && page.slug === 'thank-you') {
        send(0, 'event');
        return true;
      }

      readInitial(s);

      return true;
    } catch (error) {
      console.warn('[FuonkhCart] attach failed', error);
      return false;
    }
  }

  document.addEventListener('theme::ready', attach);

  if (!attach()) {
    retryTimer = setInterval(function () {
      attempts += 1;

      if (attach() || attempts >= 30) {
        clearInterval(retryTimer);
        retryTimer = null;
      }
    }, 1000);
  }

  window.addEventListener('pagehide', function () {
    if (retryTimer !== null) {
      clearInterval(retryTimer);
      retryTimer = null;
    }
  });
})();
''';
  /// Reports when the product sliders near the top have their cards.
  /// Sliders far down the page don't hold the page back, and an empty one
  /// gives up after 8 s instead of keeping the splash up.
  static const _readyJs = r'''
(function () {
  if (window.top !== window || window.__storeReadyWatch) return;
  window.__storeReadyWatch = true;
  var started = Date.now();
  var cards =
    'custom-salla-product-card, salla-product-card, .s-product-card-entry';
  function productsShown() {
    var sliders = document.querySelectorAll(
      'salla-products-slider, salla-products-list'
    );
    for (var i = 0; i < sliders.length; i++) {
      var top = sliders[i].getBoundingClientRect().top;
      if (top > window.innerHeight * 2) continue;
      if (!sliders[i].querySelector(cards)) return false;
    }
    return true;
  }
  function check() {
    if (productsShown() || Date.now() - started > 8000) {
      var bridge = window.flutter_inappwebview;
      if (bridge && bridge.callHandler) bridge.callHandler('StoreReady');
      return;
    }
    setTimeout(check, 150);
  }
  check();
})();
''';

  static final settings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    supportMultipleWindows: true,
    javaScriptCanOpenWindowsAutomatically: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowsBackForwardNavigationGestures: true,
  );

  void onCreated(InAppWebViewController controller) {
    _web = controller;

    _readyTimer = Timer(_readyTimeout, _markReady);
    controller.addJavaScriptHandler(
      handlerName: 'StoreReady',
      callback: (_) => _markReady(),
    );

    controller.addJavaScriptHandler(
      handlerName: 'FuonkhCart',
      callback: (args) async {
        if (_disposed || args.isEmpty) return null;

        final currentUrl = await controller.getUrl();

        if (_disposed ||
            currentUrl == null ||
            currentUrl.scheme != 'https' ||
            currentUrl.host != ConstantManager.storeHost) {
          return null;
        }

        final message = args.first;
        if (message is! Map) return null;

        final source = message['source'];

        if (source != 'initial' && source != 'event') {
          return null;
        }

        // Ignore saved snapshots once a count is known.
        if (source == 'initial' && cartTracker.hasCount) {
          return null;
        }

        final count = int.tryParse(
          message['count'].toString(),
        );

        if (count == null || count < 0) return null;

        cartTracker.updateCount(count);

        debugPrint(
          '[FuonkhCart] source=$source, count=$count',
        );

        return null;
      },
    );
  }

  void onProgress(InAppWebViewController _, int value) {
    progress.value = value / 100;
    if (value == 100) pullToRefresh.endRefreshing();
  }

  Future<void> onLoadStop(
      InAppWebViewController controller,
      WebUri? url,
      ) async {
    if (_disposed) return;

    pullToRefresh.endRefreshing();

    await controller.injectCSSCode(
      source: _injectedCss,
    );

    _loadedUrl = url;
    _cartCountAtLoad = cartTracker.count;

    if (_disposed ||
        url == null ||
        url.scheme != 'https' ||
        url.host != ConstantManager.storeHost) {
      _markReady();
      return;
    }

    if (!isReady.value || isRefreshing.value) {
      await controller.evaluateJavascript(source: _readyJs);
    }

    // A finished order empties the cart, but the page after checkout only
    // offers a saved snapshot, which the tracker ignores once a count is
    // known, so the reminder would still fire for a paid cart.
    if (url.path.contains('thank-you')) {
      cartTracker.updateCount(0);
      return;
    }

    try {
      await controller.evaluateJavascript(
        source: _cartTrackerJs,
      );
    } catch (error) {
      debugPrint(
        '[FuonkhCart] injection failed: $error',
      );
    }
  }

  void onLoadStart(InAppWebViewController _, WebUri? _) =>
      hasError.value = false;

  /// Only a failed *page* load swaps in the offline view — a broken image
  /// or tracking script must not hide the whole store.
  void onReceivedError(
    InAppWebViewController _,
    WebResourceRequest request,
    WebResourceError _,
  ) {
    if (request.isForMainFrame ?? true) {
      pullToRefresh.endRefreshing();
      hasError.value = true;
      _markReady();
    }
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    InAppWebViewController _,
    NavigationAction action,
  ) async {
    final url = action.request.url;
    if (url == null) return NavigationActionPolicy.ALLOW;

    if (_opensExternally(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return NavigationActionPolicy.CANCEL;
    }

    // Only user taps switch tabs. Server redirects (e.g. the account page
    // bouncing a guest to "/") must stay in the tab that requested them.
    final tapped =
        action.hasGesture == true ||
        action.navigationType == NavigationType.LINK_ACTIVATED;
    if (tapped &&
        action.isForMainFrame &&
        url.host == ConstantManager.storeHost) {
      final target = StoreTab.forPath(url.path);
      if (target != null && target != tab) {
        onTabLink(target, url);
        return NavigationActionPolicy.CANCEL;
      }
    }

    // Everything else, payment gateways and 3-D Secure pages included,
    // loads inside the WebView.
    return NavigationActionPolicy.ALLOW;
  }

  /// `target="_blank"` links and `window.open` (used by some payment and
  /// social widgets) open in the same WebView instead of being dropped.
  Future<bool> onCreateWindow(
    InAppWebViewController controller,
    CreateWindowAction action,
  ) async {
    final url = action.request.url;
    if (url == null) return false;
    if (_opensExternally(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await controller.loadUrl(urlRequest: URLRequest(url: url));
    }
    return false;
  }

  bool _opensExternally(WebUri url) =>
      !const {
        'http',
        'https',
        'about',
        'data',
        'blob',
        'javascript',
      }.contains(url.scheme) ||
      _externalHosts.contains(url.host);

  Future<void> open(WebUri url) async {
    final web = _web;
    if (web == null) {
      _startUrl = url;
      return;
    }
    await web.loadUrl(urlRequest: URLRequest(url: url));
  }

  Future<void> openRoot() => open(tab.initialUrl);

  /// Whether [url] is already on screen with the cart as it is now — then
  /// switching to this tab needs no reload.
  bool isShowing(WebUri url) =>
      _loadedUrl?.path == url.path &&
      _loadedUrl?.query == url.query &&
      _cartCountAtLoad == cartTracker.count;

  void _markReady() {
    _readyTimer?.cancel();
    if (_disposed) return;
    isReady.value = true;
    isRefreshing.value = false;
  }

  Future<void> reload() async {
    final web = _web;
    if (web == null) return;
    _readyTimer?.cancel();
    _readyTimer = Timer(_readyTimeout, _markReady);
    isRefreshing.value = true;
    await web.reload();
  }

  Future<void> retry() async {
    hasError.value = false;
    await reload();
  }

  /// Returns `true` when the WebView consumed the back press.
  Future<bool> goBack() async {
    final web = _web;
    if (web == null || !await web.canGoBack()) return false;
    await web.goBack();
    return true;
  }

  void dispose() {
    _disposed = true;

    _readyTimer?.cancel();
    _web?.removeJavaScriptHandler(
      handlerName: 'FuonkhCart',
    );
    _web?.removeJavaScriptHandler(handlerName: 'StoreReady');

    progress.dispose();
    hasError.dispose();
    isReady.dispose();
    isRefreshing.dispose();
    pullToRefresh.dispose();
  }
}
