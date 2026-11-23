part of '../imports/store_imports.dart';

/// Covers a tab while pull-to-refresh reloads it, so the page comes back
/// complete instead of as grey skeletons. The progress bar above stays
/// visible.
class _StoreRefreshOverlay extends StatelessWidget {
  const _StoreRefreshOverlay({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: ColoredBox(
            color: AppColors.brandSurface,
            child: Center(
              child: SizedBox.square(
                dimension: AppSize.sH25,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.storeHeader,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
