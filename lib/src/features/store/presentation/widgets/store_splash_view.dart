part of '../imports/store_imports.dart';

/// Covers Home while its products load, so the store appears complete
/// instead of as grey skeletons filling in one by one.
class _StoreSplashView extends StatelessWidget {
  const _StoreSplashView({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: ColoredBox(
          color: AppColors.storeHeader,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSize.sH30,
              children: [
                AppAssets.svg.baseSvg.appIcon.image(width: AppSize.sW140),
                SizedBox.square(
                  dimension: AppSize.sH25,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
