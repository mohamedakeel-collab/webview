part of '../imports/store_imports.dart';

/// The storefront's main menu as a native screen, in place of the web
/// header's side drawer.
class _StoreMenuView extends StatelessWidget {
  const _StoreMenuView({required this.vc});

  final StoreViewController vc;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.brandSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.storeHeader,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW16,
                vertical: AppPadding.pH12,
              ),
              child: Text(
                LocaleKeys.storeTabMenu,
                style: const TextStyle().setWhiteColor.s18.bold,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<StoreMenuItem>>(
              valueListenable: vc.menu,
              builder: (context, items, _) => items.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.storeHeader,
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) => _StoreMenuTile(
                        item: items[i],
                        onOpen: vc.openFromMenu,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
