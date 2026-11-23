part of '../imports/store_imports.dart';

class _StoreTabView extends StatelessWidget {
  const _StoreTabView({required this.controller});

  final StoreWebController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.hasError,
      // The WebView stays mounted under the offline view so its history
      // survives; IndexedStack just decides which one is visible.
      builder: (context, hasError, webView) => IndexedStack(
        index: hasError ? 1 : 0,
        children: [
          webView!,
          _StoreOfflineView(onRetry: controller.retry),
        ],
      ),
      child: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: controller.progress,
            builder: (context, progress, _) => progress < 1
                ? LinearProgressIndicator(
                    value: progress,
                    minHeight: AppSize.sH2,
                    color: AppColors.brand,
                    backgroundColor: AppColors.brandSurface,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: controller.startUrl),
                  initialSettings: StoreWebController.settings,
                  initialUserScripts: StoreWebController.userScripts,
                  pullToRefreshController: controller.pullToRefresh,
                  onWebViewCreated: controller.onCreated,
                  onLoadStart: controller.onLoadStart,
                  onLoadStop: controller.onLoadStop,
                  onProgressChanged: controller.onProgress,
                  onReceivedError: controller.onReceivedError,
                  shouldOverrideUrlLoading: controller.shouldOverrideUrlLoading,
                  onCreateWindow: controller.onCreateWindow,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.isRefreshing,
                  builder: (context, refreshing, _) =>
                      _StoreRefreshOverlay(visible: refreshing),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
