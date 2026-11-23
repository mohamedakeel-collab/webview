part of '../imports/store_imports.dart';

class _StoreBody extends StatelessWidget {
  const _StoreBody({required this.vc});

  final StoreViewController vc;

  @override
  Widget build(BuildContext context) {
    final current = context.watch<StoreTabCubit>().state;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vc.handleBack(current);
      },
      // Light icons on the dark header colour; the colour itself shows through
      // the SafeArea's top inset, which is the area behind the status bar.
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: AppColors.storeHeader,
          body: SafeArea(
            bottom: false,
            // Rebuilt when Home is ready: the splash fades out and the other
            // tabs join the stack to load in the background.
            child: ValueListenableBuilder<bool>(
              valueListenable: vc.isReady,
              builder: (context, ready, _) => Stack(
                children: [
                  // IndexedStack keeps every opened tab alive: switching tabs
                  // never reloads the page or loses the cart / scroll position.
                  IndexedStack(
                    index: current.index,
                    children: [
                      for (final tab in StoreTab.values)
                        if (!tab.isWeb)
                          _StoreMenuView(vc: vc)
                        else if (vc.isOpened(tab))
                          _StoreTabView(controller: vc.controllerOf(tab))
                        else
                          const SizedBox.shrink(),
                    ],
                  ),
                  _StoreSplashView(visible: !ready),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _StoreBottomBar(
            current: current,
            onSelect: (tab) => vc.select(tab, current: current),
          ),
        ),
      ),
    );
  }
}
