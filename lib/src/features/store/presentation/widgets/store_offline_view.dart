part of '../imports/store_imports.dart';

class _StoreOfflineView extends StatelessWidget {
  const _StoreOfflineView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pW16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSize.sH16,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: AppSize.sH60,
            color: AppColors.hintText,
          ),
          Text(
            LocaleKeys.storeOfflineTitle,
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s18.bold,
          ),
          Text(
            LocaleKeys.storeOfflineDesc,
            textAlign: TextAlign.center,
            style: const TextStyle().setHintColor.s14,
          ),
          DefaultButton(title: LocaleKeys.storeRetry, onTap: onRetry),
        ],
      ),
    );
  }
}
